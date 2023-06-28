import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final RoutesIsolate routesIsolate = RoutesIsolate();

class RoutesIsolate {
  final xy = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ Routes Isolate Functions: 🍎🍎';

  Future<int> getRoutes(String associationId) async {
    pp('\n\n\n$xy ............................ getting routes ....');
    final token = await appAuth.getAuthToken();

    if (token != null) {
      final bag = DonkeyBag(associationId, KasieEnvironment.getUrl(), token);
      List mRoutes = await _handleRoutes(bag);
      pp('$xy hey Joe, do yo know where you are? ${E.redDot} ');

      final routeIds = <String>[];
      for (var value1 in mRoutes) {
        routeIds.add(value1.routeId!);
      }
      pp('$xy get landmarks and routePoints for ${routeIds.length} routes ... ');

      await _handleRouteLandmarks(routeIds, bag);
      await _handleRoutePoints(routeIds, bag);
      await _handleRouteCities(routeIds, bag);

      pp('\n\n\n$xy ..... done getting routes ....\n\n');
    } else {
      pp('$xy ${E.redDot}${E.redDot}${E.redDot}${E.redDot} no Firebase token found!!!! ${E.redDot}');
    }
    return 0;
  }

  Future<List<Route>> _handleRoutes(DonkeyBag bag) async {
    pp('$xy ................ _handleRoutes .... ');
    final start = DateTime.now();

    final s = await Isolate.run(() async => _heavyTaskForRoutes(bag));
    final list = jsonDecode(s);
    var mRoutes = <Route>[];
    for (var value in list) {
      mRoutes.add(buildRoute(value));
    }
    pp('$xy _handleRoutes attempting to cache ${mRoutes.length} route.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<Route>(mRoutes, update: true);
    });
    var end = DateTime.now();
    pp('$xy should have cached ${mRoutes.length} Routes in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return mRoutes;
  }

  Future<List<RouteLandmark>> _handleRouteLandmarks(
      List<String> routeIds, DonkeyBag bag) async {
    //get all route landmarks
    pp('$xy ......... _handleRouteLandmarks .... ');
    final start = DateTime.now();
    var bunny = BunnyBag(bag.associationId, bag.url, bag.token);
    final st =
        await Isolate.run(() async => _heavyTaskForRouteLandmarks(bunny));
    var mRouteLandmarks = <RouteLandmark>[];
    final list3 = jsonDecode(st);
    for (var value in list3) {
      mRouteLandmarks.add(buildRouteLandmark(value));
    }
    pp('$xy _handleRouteLandmarks attempting to cache ${mRouteLandmarks.length} routeLandmarks.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<RouteLandmark>(mRouteLandmarks, update: true);
    });
    final end = DateTime.now();

    pp('$xy RouteLandmarks cached in realm : '
        '💙 ${mRouteLandmarks.length}  elapsed rime: ${end.difference(start).inSeconds} seconds 💙');
    return mRouteLandmarks;
  }

  Future<List<RoutePoint>> _handleRoutePoints(
      List<String> routeIds, DonkeyBag bag) async {
    pp('$xy ................ _handleRoutePoints .... ');
    final start = DateTime.now();

    var bunny = BunnyBag(bag.associationId, bag.url, bag.token);
    final sx = await Isolate.run(() async => _heavyTaskForRoutePoints(bunny));
    var mRoutePoints = <RoutePoint>[];
    final list2 = jsonDecode(sx);
    for (var value in list2) {
      mRoutePoints.add(buildRoutePoint(value));
    }
    pp('$xy _handleRoutePoints attempting to cache ${mRoutePoints.length} routePoints.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<RoutePoint>(mRoutePoints, update: true);
    });

    final end2 = DateTime.now();
    pp('$xy routePoints cached in realm : '
        '💙 ${mRoutePoints.length}  💙 time elapsed: ${end2.difference(start).inSeconds} seconds');
    return mRoutePoints;
  }

  Future<List<RouteCity>> _handleRouteCities(
      List<String> routeIds, DonkeyBag bag) async {
    pp('$xy .............. _handleRouteCities .... ');
    final start = DateTime.now();

    var bunny = BunnyBag(bag.associationId, bag.url, bag.token);
    final sx = await Isolate.run(() async => _heavyTaskForRouteCities(bunny));
    var mRouteCities = <RouteCity>[];
    final list2 = jsonDecode(sx);
    for (var value in list2) {
      mRouteCities.add(buildRouteCity(value));
    }
    pp('$xy _handleRouteCities attempting to cache ${mRouteCities.length} routePoints.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<RouteCity>(mRouteCities, update: true);
    });

    final end2 = DateTime.now();
    pp('$xy RouteCities cached in realm : '
        '💙 ${mRouteCities.length}  💙 time elapsed: ${end2.difference(start).inSeconds} seconds');
    return mRouteCities;
  }
}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForRoutes: 🍎🍎';

Future<String> _heavyTaskForRoutes(DonkeyBag bag) async {
  pp('$xyz _heavyTaskForRoutes starting .................');

  final cmd =
      '${bag.url}getAssociationRoutes?associationId=${bag.associationId}';
  List resp = await _httpGet(cmd, bag.token);
  final jsonList = jsonEncode(resp);
  pp('$xyz _heavyTaskForRoutes returning raw string .................');

  return jsonList;
}

Future<String> _heavyTaskForRoutePoints(BunnyBag bag) async {
  pp('$xyz _heavyTaskForRoutePoints starting ................associationId:  ${bag.associationId} .');

  final points = [];
  final token = bag.token;
  final cmd =
      '${bag.url}getAssociationRoutePoints?associationId=${bag.associationId}';
  List resp = await _httpGet(cmd, token);
  points.addAll(resp);
  final jsonList = jsonEncode(points);
  pp('$xyz Association RoutePoints for all routes: ${points.length}');
  pp('$xyz _heavyTaskForRoutePoints returning raw string .................');

  return jsonList;
}

Future<String> _heavyTaskForRouteLandmarks(BunnyBag bag) async {
  pp('$xyz _heavyTaskForRouteLandmarks starting .................associationId: ${bag.associationId} .');

  final routeLandmarks = [];
  final token = bag.token;

  final cmd =
      '${bag.url}getAssociationRouteLandmarks?associationId=${bag.associationId}';
  List resp = await _httpGet(cmd, token);
  routeLandmarks.addAll(resp);
  final jsonList = jsonEncode(routeLandmarks);
  pp('$xyz Association RouteLandmarks for all routes: ${routeLandmarks.length}');
  return jsonList;
}

Future<String> _heavyTaskForRouteCities(BunnyBag bag) async {
  pp('$xyz _heavyTaskForRouteCities starting ................. associationId; ${bag.associationId} .');

  final routeCities = [];
  final token = bag.token;

  final cmd =
      '${bag.url}getAssociationRouteCities?associationId=${bag.associationId}';
  List resp = await _httpGet(cmd, token);
  routeCities.addAll(resp);
  final jsonList = jsonEncode(routeCities);
  pp('$xyz Association RouteCities for all routes: ${routeCities.length}');
  return jsonList;
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

class DonkeyBag {
  late String associationId, url, token;

  DonkeyBag(this.associationId, this.url, this.token);
}

class BunnyBag {
  late String associationId;
  late String url, token;

  BunnyBag(this.associationId, this.url, this.token);
}
