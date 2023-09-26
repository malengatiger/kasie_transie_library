import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';

import '../providers/kasie_providers.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final LandmarkIsolate landmarkIsolate = LandmarkIsolate();

class LandmarkParameters {
  late double radius, latitude, longitude;
  late String landmarkName;
  late String associationId;
  late String routeName, routeId, authToken, routePointId;
  late int limit, index, routePointIndex;

  LandmarkParameters(
      {required this.radius,
      required this.latitude,
      required this.longitude,
      required this.landmarkName,
      required this.associationId,
      required this.routeName,
      required this.routeId,
      required this.limit,
      required this.routePointIndex,
      required this.index,
      required this.routePointId,
      required this.authToken});
}

class LandmarkIsolate {
  final StreamController<List<lib.RouteLandmark>> _compController =
      StreamController.broadcast();
  Stream<List<lib.RouteLandmark>> get completionStream =>
      _compController.stream;

  Future<List<lib.RouteLandmark>> deleteRouteLandmark(
      String routeLandmarkId) async {
    pp('\n\n$xyz deleteRouteLandmark (in main thread) starting ..............');

    var token = await appAuth.getAuthToken();
    if (token == null) {
      pp('$xyz ${E.redDot} - Firebase token no show!');
      throw Exception('no token');
    }
    List<lib.RouteLandmark> list = [];
    ///build the async isolate and run it
    final longString = await Isolate.run(() async => _heavyTaskForLandmarkDelete(routeLandmarkId, token));
    List mJson = jsonDecode(longString);
    _cacheLandmarks(mJson, list, routeLandmarkId);
    pp('$xyz LandmarkIsolate completed the job. 🔷🔷🔷🔷 ${E.heartOrange}\n\n');

    return list;
  }

Future<List<lib.RouteLandmark>> addRouteLandmark(
    lib.RouteLandmark routeLandmark) async {
  pp('\n\n$xyz addRouteLandmark (in main thread) starting ..............');

  var token = await appAuth.getAuthToken();
  if (token == null) {
    pp('$xyz ${E.redDot} - Firebase token no show!');
    throw Exception('no token');
  }
  List<lib.RouteLandmark> list = [];
  ///build the async isolate and run it
  final map = routeLandmark.toJson();
  final longString = await Isolate.run(() async => _heavyTaskForLandmark(map, token));
  List mJson = jsonDecode(longString);
  _cacheLandmarks(mJson, list, routeLandmark.routeId!);
  pp('$xyz LandmarkIsolate completed the job. 🔷🔷🔷🔷 ${E.heartOrange}\n\n');

  return list;
}

void _cacheLandmarks(List<dynamic> mJson, List<lib.RouteLandmark> list, String routeId) {
   for (var map in mJson) {
    list.add(buildRouteLandmark(map));
  }
  final items = listApiDog.realm.query<lib.RouteLandmark>('routeId == \$0', [routeId]);
  listApiDog.realm.write(() {
    listApiDog.realm.deleteMany(items);
    listApiDog.realm.addAll(list, update: true);
  });
   final items2 = listApiDog.realm.query<lib.RouteLandmark>('routeId == \$0', [routeId]);

  pp('$xyz _cacheLandmarks completed the job. 🔷🔷🔷🔷 newly cached landmarks: ${items2.length}! ${E.heartOrange}\n\n');
  _compController.sink.add(list);
}
}

/// Landmark processing isolate
///
@pragma('vm:entry-point')
Future<String> _heavyTaskForLandmark(Map routeLandmarkJson, String token) async {
  pp('\n$xyz ............ _heavyTaskForLandmark starting ...');

  final res = await _processNewLandmark(
      routeLandmark: buildRouteLandmark(routeLandmarkJson), token: token);
  return res;
}
@pragma('vm:entry-point')
Future<String> _heavyTaskForLandmarkDelete(String routeLandmarkId, String token) async {
  pp('\n$xyz ............ _heavyTaskForLandmarkDelete starting ...');

  var url = KasieEnvironment.getUrl();
  final marks = await _deleteRouteLandmark(routeLandmarkId, url, token);
  final res = jsonEncode(marks);
  return res;
}

Future<String> _processNewLandmark(
    {required lib.RouteLandmark routeLandmark, required token}) async {
  pp('\n\n$xyz _processNewLandmark: routeLandmark: '
      ' ${routeLandmark.landmarkName}  🔆 🔆 🔆to be sent to backend');

  var url = KasieEnvironment.getUrl();
  final marks = await _addRouteLandmark(routeLandmark, url, token);
  pp('$xyz RouteLandmark added?  ............. ${marks.length} total landmarks');
  return marks;
}

Future<List<lib.City>> findCitiesByLocation(
    LocationFinderParameter p, String url, String token) async {
  pp('$xyz _findCitiesByLocation looking for places ... limit: ${p.limit}');
  final cmd = '${url}findCitiesByLocation?latitude=${p.latitude}'
      '&longitude=${p.longitude}'
      '&radiusInKM=${p.radiusInKM}&limit=${p.limit}';

  List res = await _httpGet(cmd, token);
  final list = <lib.City>[];
  for (var value in res) {
    final c = buildCity(value);
    list.add(c);
  }
  pp('$xyz _findCitiesByLocation found ${list.length} cities ...');

  return list;
}

Future<String> _addRouteLandmark(
    lib.RouteLandmark routeLandmark, url, token) async {
  List<lib.RouteLandmark> marks = [];
  final bag = routeLandmark.toJson();
  final cmd = '${url}addRouteLandmark';
  List res = await _httpPost(cmd, bag, token);
  pp('$xyz RouteLandmark added to database ...');
  for (var value in res) {
    final r = buildRouteLandmark(value);
    marks.add(r);
  }

  return jsonEncode(marks);
}
Future<List<lib.RouteLandmark>> _deleteRouteLandmark(
    String routeLandmarkId, url, token) async {
  List<lib.RouteLandmark> marks = [];
  final cmd = '${url}deleteRouteLandmark?routeLandmarkId=$routeLandmarkId';
  List res = await _httpGet(cmd, token);
  pp('$xyz RouteLandmark removed from database ... returning ${res.length} landmarks');
  for (var value in res) {
    final r = buildRouteLandmark(value);
    marks.add(r);
  }

  return marks;
}

Map<String, String> headers = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
};

Future _httpGet(String mUrl, String token) async {
  pp('$xyz _httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
  var start = DateTime.now();

  headers['Authorization'] = 'Bearer $token';
  try {
    final http.Client client = http.Client();
    var resp = await client
        .get(
          Uri.parse(mUrl),
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));
    pp('$xyz _httpGet call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
    var end = DateTime.now();
    pp('$xyz _httpGet call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

    if (resp.body.contains('not found')) {
      return false;
    }

    if (resp.statusCode == 403) {
      var msg =
          '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
      pp(msg);
      // final gex = KasieException(
      //     message: 'Forbidden call',
      //     url: mUrl,
      //     translationKey: 'serverProblem',
      //     errorType: KasieException.httpException);
      // //errorHandler.handleError(exception: gex);
      // throw gex;
    }

    if (resp.statusCode != 200) {
      var msg =
          '😡 😡 The response is not 200; it is ${resp.statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
      pp(msg);
      final gex = KasieException(
          message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
      ////errorHandler.handleError(exception: gex);
      throw gex;
    }
    var mJson = json.decode(resp.body);
    return mJson;
  } on SocketException {
    pp('$xyz SocketException, really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$xyz HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$xyz Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$xyz No Internet connection. Request has timed out in 120 seconds 👎");
    final gex = KasieException(
        message: 'No Internet connection. Request timed out',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  }
}

final http.Client client = http.Client();

Future _httpPost(String mUrl, Map? bag, String token) async {
  String? mBag;
  if (bag != null) {
    mBag = json.encode(bag);
  }
  var start = DateTime.now();
  headers['Authorization'] = 'Bearer $token';
  try {
    var resp = await client
        .post(
          Uri.parse(mUrl),
          body: mBag,
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      pp('$xyz  _httpPost RESPONSE: 💙💙 statusCode: 👌👌👌 '
          '${resp.statusCode} 👌👌👌 💙 for $mUrl');
    } else {
      pp('$xyz  👿👿👿_httpPost: 🔆 statusCode: 👿👿👿 '
          '${resp.statusCode} 🔆🔆🔆 for $mUrl');
      pp(resp.body);
      throw KasieException(
          message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
    }
    var end = DateTime.now();
    pp('$xyz  _httpPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
    try {
      var mJson = json.decode(resp.body);
      return mJson;
    } catch (e) {
      pp("$xyz 👿👿👿👿👿👿👿 json.decode failed, returning response body");
      return resp.body;
    }
  } on SocketException {
    pp('$xyz  SocketException: really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$xyz  HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$xyz  Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$xyz  No Internet connection. Request has timed out in 120 seconds 👎");
    final gex = KasieException(
        message: 'Request timed out. No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  }
}

const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 Landmark Isolated Functions: 🍎🍎';
