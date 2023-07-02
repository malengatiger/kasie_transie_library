import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final DispatchIsolate dispatchIsolate = DispatchIsolate();

class DispatchIsolate {
  final xy = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ DispatchIsolate Isolate Functions: 🍎🍎';

  Future<List<DispatchRecord>> addDispatchRecords() async {
    pp('\n\n\n$xy ............................ addDispatchRecords ....');
    final token = await appAuth.getAuthToken();

    if (token != null) {
      final list = await cacheManager.getDispatchRecordString();

      final bag = DispatchesBag(list, KasieEnvironment.getUrl(), token);
      pp('$xy  save cached dispatches to backend; using isolate ... ');
      final m = await _handleDispatches(bag);
      await cacheManager.deleteDispatchRecords();
      pp('\n\n\n$xy ..... done saving ${m.length} dispatch records ....\n\n');
      return m;

    } else {
      pp('$xy ${E.redDot}${E.redDot}${E.redDot}${E.redDot} no Firebase token found!!!! ${E.redDot}');
    }

    return [];
  }

  Future<DispatchRecord> addDispatchRecord(DispatchRecord dispatchRecord) async {
    pp('\n\n\n$xy ............................ addDispatchRecord ....');
    final token = await appAuth.getAuthToken();

    if (token != null) {
      final mJson = dispatchRecord.toJson();
      final string = jsonEncode(mJson);
      final bag = DispatchBag(string, KasieEnvironment.getUrl(), token);
      pp('$xy  save new dispatch to backend; using isolate ... ');
      final m = await _handleDispatch(bag);
      pp('\n\n\n$xy ..... done saving ${m.vehicleReg} dispatch record ....\n\n');
      return m;

    } else {
      pp('$xy ${E.redDot}${E.redDot}${E.redDot}${E.redDot} no Firebase token found!!!! ${E.redDot}');
    }
    throw Exception('Failed to add DispatchRecord');
  }

  Future<List<DispatchRecord>> _handleDispatches(DispatchesBag bag) async {
    pp('$xy ................ _handleRoutes .... ');
    final start = DateTime.now();

    final s = await Isolate.run(() async => _heavyTaskForDispatches(bag));
    final list = jsonDecode(s);
    var dispatches = <DispatchRecord>[];
    for (var value in list) {
      dispatches.add(buildDispatchRecord(value));
    }
    pp('$xy _handleDispatches attempting to cache ${dispatches.length} route.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<DispatchRecord>(dispatches, update: true);
    });
    var end = DateTime.now();
    pp('$xy should have cached ${dispatches.length} DispatchRecords in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return dispatches;
  }

  Future<DispatchRecord> _handleDispatch(DispatchBag bag) async {
    pp('$xy ................ _handleDispatch .... ');
    final start = DateTime.now();
    final s = await Isolate.run(() async => _heavyTaskForDispatch(bag));
    final mJson = jsonDecode(s);
    final dispatch = buildDispatchRecord(mJson);

    pp('$xy _handleDispatches attempting to cache ${dispatch.vehicleReg} dispatch.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.add<DispatchRecord>(dispatch, update: true);
    });
    var end = DateTime.now();
    pp('$xy should have cached ${dispatch.vehicleReg} DispatchRecords in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return dispatch;
  }

}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForDispatches: 🍎🍎';

Future<String> _heavyTaskForDispatches(DispatchesBag dispatchBag) async {
  pp('$xyz _heavyTaskForDispatches starting ................. ${dispatchBag.url} ${dispatchBag.token}');

  final bag = jsonDecode(dispatchBag.dispatchesJson);
  final cmd =
      '${dispatchBag.url}addDispatchRecords';
  List resp = await _httpPost(cmd, bag, dispatchBag.token);
  final jsonList = jsonEncode(resp);
  pp('$xyz _heavyTaskForDispatches returning raw string .................');

  return jsonList;
}
Future<String> _heavyTaskForDispatch(DispatchBag dispatchBag) async {
  pp('$xyz _heavyTaskForDispatch starting .................');

  final bag = jsonDecode(dispatchBag.dispatchJson);
  final cmd =
      '${dispatchBag.url}addDispatchRecord';
  final resp = await _httpPost(cmd, bag, dispatchBag.token);
  final jsonList = jsonEncode(resp);
  pp('$xyz _heavyTaskForDispatch returning raw string .................');

  return jsonList;
}

Future _httpPost(String mUrl, Map? bag, String token) async {
  String? mBag;
  if (bag != null) {
    mBag = json.encode(bag);
  }
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
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


Future _httpGet(String mUrl, String token) async {
  pp('$xyz _httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
  var start = DateTime.now();
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
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

class DispatchesBag {
  late String dispatchesJson, url, token;
  DispatchesBag(this.dispatchesJson, this.url, this.token);
}

class DispatchBag {
  late String dispatchJson, url, token;
  DispatchBag(this.dispatchJson, this.url, this.token);
}


