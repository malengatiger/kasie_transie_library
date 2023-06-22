import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';

import '../providers/kasie_providers.dart';
import 'emojis.dart';
import 'functions.dart';
import 'kasie_exception.dart';

final LandmarkIsolate landmarkIsolate = LandmarkIsolate();

class LandmarkParameters {
  late double radius, latitude, longitude;
  late String landmarkName;
  late String associationId;
  late String routeName, routeId, authToken;
  late int limit;

  LandmarkParameters({required this.radius,
    required this.latitude,
    required this.longitude,
    required this.landmarkName,
    required this.associationId,
    required this.routeName,
    required this.routeId,
    required this.limit,
    required this.authToken});
}

class LandmarkIsolate {
  Future startIsolate(LandmarkParameters parameters) async {
    pp('\n\n$xyz startIsolate (in main thread) starting ...');
    var token = await appAuth.getAuthToken();
    if (token == null) {
      pp('$xyz ${E.redDot} - Firebase token no show!');
      return;
    }
    parameters.authToken = token;
    await Isolate.run(() async => _heavyTaskInsideIsolate(parameters));
    pp('$xyz LandmarkIsolate completed the job. 🔷🔷🔷🔷 Yay!\n\n');
  }
}

/// Landmark processing isolate
///

Future<int> _heavyTaskInsideIsolate(LandmarkParameters parameters) async {
  pp('\n$xyz ............ _heavyTaskInsideIsolate starting ...');
  final url = KasieEnvironment.getUrl();
  final finderParams = LocationFinderParameter(
    latitude: parameters.latitude,
    longitude: parameters.longitude,
    limit: parameters.limit,
    radiusInKM: parameters.radius.toDouble(),
  );
  final cities = await _findCitiesByLocation(
      finderParams, url, parameters.authToken);
  pp('$xyz _heavyTaskInsideIsolate found ${cities.length} by location ...');

  final routeInfo = lib.RouteInfo(
    routeId: parameters.routeId,
    routeName: parameters.routeName,
  );
  final landmark = lib.Landmark(
    ObjectId(),
    landmarkId: Uuid.v4().toString(),
    landmarkName: parameters.landmarkName,
    position: lib.Position(
      type: point,
      coordinates: [parameters.longitude, parameters.latitude],
      latitude: parameters.latitude,
      longitude: parameters.longitude,
    ),
    routeDetails: [routeInfo],
  );
  final routeLandmark = lib.RouteLandmark(ObjectId(),
      routeId: parameters.routeId,
      routeName: parameters.routeName,
      landmarkName: landmark.landmarkName,
      landmarkId: landmark.landmarkId,
      associationId: parameters.associationId,
      created: DateTime.now().toUtc().toIso8601String(),
      position: lib.Position(
        type: point,
        coordinates: [parameters.longitude, parameters.latitude],
        latitude: parameters.latitude,
        longitude: parameters.longitude,
      ));
  //
  final res = await _processNewLandmark(
      landmark: landmark,
      routeLandmark: routeLandmark,
      cities: cities,
      token: parameters.authToken);
  return res;
}

Future<int> _processNewLandmark({required lib.Landmark landmark,
  required lib.RouteLandmark routeLandmark,
  required List<lib.City> cities,
  required token}) async {
  pp('\n\n$xyz _processNewLandmark: landmark and routeLandmark '
      'and ${cities.length} routeCity 🔆 🔆 🔆records to be sent to backend');

  var url = KasieEnvironment.getUrl();
  var b = await _addLandmark(landmark, url, token);
  pp('$xyz landmark added? found? ');
  myPrettyJsonPrint(b.toJson());
  // final bResult = await dataApiDog.addRouteLandmark(routeLandmark);
  final mark = await _addRouteLandmark(routeLandmark, url, token);

  int cnt = 1;
  for (var city in cities) {
    final rc = lib.RouteCity(ObjectId(),
        routeId: routeLandmark.routeId,
        routeName: routeLandmark.routeName,
        created: DateTime.now().toUtc().toIso8601String(),
        cityId: city.cityId,
        cityName: city.name,
        associationId: routeLandmark.associationId,
        position: city.position);

    final result = await _addRouteCity(rc, url, token);
    pp('$xyz routeCity #$cnt added? ${result.cityName} added to ${result
        .routeName}');
    myPrettyJsonPrint(result.toJson());
    cnt++;

    //sleep; for avoiding rate limit on backend
    pp('$xyz ....... sleeping for 3 seconds ... ${DateTime.now()
        .toIso8601String()}');
    sleep(Duration(seconds: 3));
    pp('$xyz ....... woke up from my slumber: ... ${DateTime.now()
        .toIso8601String()}');
  }
  return 0;
}

Future<List<lib.City>> _findCitiesByLocation(LocationFinderParameter p,
    String url, String token) async {
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

Future<lib.RouteLandmark> _addRouteLandmark(lib.RouteLandmark routeLandmark,
    url, token) async {
  final bag = routeLandmark.toJson();
  final cmd = '${url}addRouteLandmark';
  final res = await _httpPost(cmd, bag, token);
  pp('$xyz RouteLandmark added to database ...');
  final r = buildRouteLandmark(res);
  pp('$xyz routeLandmark added? ');
  myPrettyJsonPrint(r.toJson());
  return r;
}

Future<lib.Landmark> _addLandmark(lib.Landmark landmark, url, token) async {
  final bag = landmark.toJson();
  final cmd = '${url}addBasicLandmark';
  final res = await _httpPost(cmd, bag, token);
  pp('$xyz Landmark added to database ...');
  final r = buildLandmark(res);
  pp('$xyz Landmark added? ');
  myPrettyJsonPrint(r.toJson());
  return r;
}

Future<lib.RouteCity> _addRouteCity(lib.RouteCity routeCity, url, token) async {
  final bag = routeCity.toJson();
  final cmd = '${url}addRouteCity';
  try {
    final res = await _httpPost(cmd, bag, token);
    pp('$xyz RouteCity added to database ...');
    final r = buildRouteCity(res);
    pp('$xyz RouteCity added? ');
    myPrettyJsonPrint(r.toJson());
    return r;
  } catch (e) {
    pp('$xyz error adding RouteCity; probable dup');
    if (e.toString().contains('duplicate')) {
      pp('$xyz it is indeed a DUPLICATE!');
      return routeCity;
    } else {
      rethrow;
    }
  }
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
    pp('$xyz _httpGet call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp
        .statusCode} 👌👌👌 💙 for $mUrl');
    var end = DateTime.now();
    pp('$xyz _httpGet call: 🔆 elapsed time for http: ${end
        .difference(start)
        .inSeconds} seconds 🔆 \n\n');

    if (resp.body.contains('not found')) {
      return false;
    }

    if (resp.statusCode == 403) {
      var msg =
          '😡 😡 status code: ${resp
          .statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
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
          '😡 😡 The response is not 200; it is ${resp
          .statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
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
    if (resp.statusCode == 200) {
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
    pp('$xyz  _httpPost: 🔆 elapsed time: ${end
        .difference(start)
        .inSeconds} seconds 🔆');
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
