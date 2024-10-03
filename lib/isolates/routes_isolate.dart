import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';
import 'package:sembast_web/sembast_web.dart';

import '../bloc/list_api_dog.dart';
import '../bloc/sem_cache.dart';
import '../data/data_schemas.dart';
import '../data/route_bag.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;


class RoutesIsolate {
  final xy = '☕️☕️☕️☕️☕️ Routes Isolate Functions: 🍎🍎';


  Future<int> countRoutePoints(String routeId) async {
    // final res = listApiDog.realm.query<RoutePoint>('routeId == \$0', [routeId]);
    // return res.length;
    return 0;
  }

  Future<int> countRouteLandmarks(String routeId) async {
    // final res =
    //     listApiDog.realm.query<RouteLandmark>('routeId == \$0', [routeId]);
    // return res.length;
    return 0;
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId, bool refresh) async {
    final token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('Auth token not found');
    }
    ListApiDog listApiDog = GetIt.instance<ListApiDog>();
    var mList = listApiDog.getPointsFromRealm(routeId);
    if (refresh || mList.isEmpty) {
      mList = await _handlePoints(routeId, token);
    }
    mList.sort((a, b) => a.index!.compareTo(b.index!));
    pp('$xy routePoints found for $routeId  == ${mList.length} points ');

    return mList;
  }

  Future<List<RoutePoint>> deleteRoutePoints(
      {required String routeId,
      required double latitude,
      required double longitude}) async {
    final mList = <RoutePoint>[];
    try {
      final rootToken = ServicesBinding.rootIsolateToken!;
      final token = await appAuth.getAuthToken();
      if (token == null) {
        throw Exception('No token');
      }
      final aString = await Isolate.run(() async =>
          _heavyTaskForDeletingRoutePoints(
              routeId: routeId,
              latitude: latitude,
              longitude: longitude,
              token: token,
              rootToken: rootToken));

      List mJson = jsonDecode(aString);
      for (var p in mJson) {
        mList.add(RoutePoint.fromJson(p));
      }
      // _cachePoints(mList);
    } catch (e, stack) {
      pp('$xy _handlePoints ... FUCKUP! $e - $stack');
    }
    return mList;
  }



  Future<List<RoutePoint>> _handlePoints(String routeId, String token) async {
    List<RoutePoint> mList = [];
    try {
      final rootToken = ServicesBinding.rootIsolateToken!;
      final aString = await Isolate.run(
          () => _heavyTaskForZippedRoutePoints(routeId, token, rootToken));
      List mJson = jsonDecode(aString);
      for (var p in mJson) {
        mList.add(RoutePoint.fromJson(p));
      }

    } catch (e, stack) {
      pp('$xy _handlePoints ... FUCKUP! $e - $stack');
    }
    return mList;
  }

  Future<List<RouteLandmark>> getRouteLandmarksCached(String routeId) async {
    pp('$xy get getRouteLandmarks for $routeId  ...');
    // var mList = <RouteLandmark>[];
    //
    // final res =
    //     listApiDog.realm.query<RouteLandmark>('routeId == \$0', [routeId]);
    // mList = res.toList();
    // pp('$xy get getRouteLandmarks found ${mList.length}  ... ');
    //
    // mList.sort((a, b) => a.index!.compareTo(b.index!));
    // pp('$xy RouteLandmarks for $routeId  == ${mList.length} ... ');

    //return res.toList();
    return [];
  }

  Future<List<RouteLandmark>> getAllRouteLandmarksCached() async {
    pp('$xy get getRouteLandmarks all routes  ...');
    // var mList = <RouteLandmark>[];
    //
    // final res = listApiDog.realm.all<RouteLandmark>();
    // mList = res.toList();
    // pp('$xy get getRouteLandmarks found ${mList.length}  ... ');
    //
    // mList.sort((a, b) => a.index!.compareTo(b.index!));

    // return res.toList();
    return [];
  }

  Future refreshRoute(String routeId) async {
    pp('$xy get landmarks and routePoints, etc. for $routeId  ... ');

    final token = await appAuth.getAuthToken();
    if (token != null) {
      final rootToken = ServicesBinding.rootIsolateToken!;

      final string = await Isolate.run(
          () async => _heavyTaskForSingleRoute(routeId, token, rootToken));
      final mJson = jsonDecode(string);
      final routeBag = RouteBag.fromJson(mJson);
      pp('$xy back from isolate ... writing the bag to realm  ${routeBag.route!.name}  ... ');


      pp('\n\n\n$xy ..... done getting route ....${E.leaf} '
          'returning ${routeBag.route!.name} ${E.leaf2} fresh and new!\n\n');
      return routeBag.route!;
    }
  }

  Future<List<Route>> getRoutesMappable(
      String associationId, bool refresh) async {
    final mRoutes = await getRoutes(associationId, refresh);
    final fRoutes = <Route>[];
    for (var value in mRoutes) {
      final marks = await getRouteLandmarksCached(value.routeId!);
      if (marks.length > 1) {
        fRoutes.add(value);
      }
    }

    return fRoutes;
  }

  Future<List<Route>> getRoutes(String associationId, bool refresh) async {
    final mRoutes = []; //istApiDog.realm.all<Route>();
    pp('\n$xy getRoutes: ... routes already in cache: ${mRoutes.length}');
    if (refresh || mRoutes.isEmpty) {
      pp('\n$xy getRoutes: ... getting routes from backend ....');
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final rootToken = ServicesBinding.rootIsolateToken!;
        final s = await Isolate.run(() async =>
            _heavyTaskForZippedRoutes(associationId, token, rootToken));

        final data = jsonDecode(s);
        pp(data);
        //todo - cache the routes here ---
        List routesJson = jsonDecode(data['routes']);
        List routePointsJson = jsonDecode(data['routePoints']);
        List landmarksJson = jsonDecode(data['landmarks']);
        List citiesJson = jsonDecode(data['cities']);
        final routes = <Route>[];
        final routePoints = <RoutePoint>[];
        final landmarks = <RouteLandmark>[];
        final cities = <RouteCity>[];

        for (var value in routesJson) {
          routes.add(Route.fromJson(value));
        }
        for (var map in routePointsJson) {
          routePoints.add(RoutePoint.fromJson(map));
        }
        for (var map in landmarksJson) {
          landmarks.add(RouteLandmark.fromJson(map));
        }
        for (var map in citiesJson) {
          cities.add(RouteCity.fromJson(map));
        }
        await cacheBag(
            routes: routes,
            routePoints: routePoints,
            landmarks: landmarks,
            cities: cities);

        return routes;
      }
    }

    return [];
  }

  Future cacheBag(
      {required List<Route> routes,
      required List<RoutePoint> routePoints,
      required List<RouteLandmark> landmarks,
      required List<RouteCity> cities}) async {
    pp('$xy ... cacheBag - cache all the data for ${routes.length} routes ......... ');
    //


    //
    pp('$xy ... 🌼🌼 ..... Routes, points, landmarks & cities cached: ${routes.length}');
  }

  Future<List<City>> getCities(String countryId, bool refresh) async {
    pp('\n\n\n$xy ............................ getting routes using isolate ....');
    final mRoutes = <City>[]; //todo - fix!
    if (refresh || mRoutes.isEmpty) {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final rootToken = ServicesBinding.rootIsolateToken!;
        final s = await Isolate.run(
            () async => _heavyTaskForZippedCities(countryId, token, rootToken));
        List<City> mCities = [];
        List json = jsonDecode(s);
        for (var value in json) {
          mCities.add(City.fromJson(value));
        }
        return mCities;
      }
    }

    return mRoutes.toList();
  }

  Future<List<lib.User>> getUsers(String associationId, bool refresh) async {
    pp('\n\n\n$xy ............................ getting users using isolate ....');
    final mRoutes =  <lib.User>[]; //listApiDog.realm.all<User>();
    if (refresh || mRoutes.isEmpty) {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final s = await Isolate.run(() async =>
            _heavyTaskForUsers(associationId: associationId, token: token));
        List<lib.User> mCities = [];
        List json = jsonDecode(s);
        for (var value in json) {
          mCities.add(lib.User.fromJson(value));
        }
        return mCities;
      }
    }

    return mRoutes.toList();
  }

  Future<List<Country>> getCountries(bool refresh) async {
    pp('\n\n\n$xy ............................ getting countries using isolate ....');
    final list =  <Country>[]; //listApiDog.realm.all<Country>();
    if (refresh || list.isEmpty) {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final s =
            await Isolate.run(() async => _heavyTaskCountries(token: token));
        List<Country> mCountries = [];
        List json = jsonDecode(s);
        for (var value in json) {
          mCountries.add(Country.fromJson(value));
        }
        return mCountries;
      }
    }

    return list.toList();
  }
}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForRoutes: 🍎🍎';
const xyz1 = '😎😎😎😎😎😎😎😎 HeavyTaskForRouteLandmarks: 🍎🍎';
const xyz4 = '😎😎😎😎😎😎😎😎 heavyTaskForDeletingRoutePoints: 🍎🍎';
const xyz2 = '🍟🍟🍟🍟🍟🍟 HeavyTaskForRoutePoints: 🍟🍟';
const xyz3 = '🌸🌸🌸🌸🌸🌸🌸🌸🌸 HeavyTaskForRouteCities: 🌸🌸🌸';

@pragma('vm:entry-point')
Future<String> _heavyTaskForDeletingRoutePoints(
    {required String routeId,
    required double latitude,
    required double longitude,
    required String token,
    required RootIsolateToken rootToken}) async {
  pp('\n\n$xyz4 _heavyTaskForDeletingRoutePoints 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.deleteRoutePoints() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();
  final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
  final SemCache semCache = GetIt.instance<SemCache>();
  final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
  return await zipHandler.deleteRoutePoints(
      routeId: routeId, token: token, latitude: latitude, longitude: longitude);
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForRoutes(DonkeyBag bag) async {
  pp('$xyz _heavyTaskForRoutes starting ................. ${bag.url}');

  List resp = await _httpGet(bag.url, bag.token);
  final jsonList = jsonEncode(resp);
  pp('$xyz _heavyTaskForRoutes returning raw string .................');

  return jsonList;
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForZippedRoutes(
    String associationId, String token, RootIsolateToken rootToken) async {
  pp('\n\n$xyz _heavyTaskForZippedRoutes 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.getRouteBags() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();
  final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
  final SemCache semCache = GetIt.instance<SemCache>();

  final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
  final res =
      await zipHandler.getRouteDataString(associationId: associationId, token: token);
  pp('🅿️ 🅿️ 🅿️ 🅿️ 🅿️ 🅿️ .... do we get here, Jack? 🅿️ 🅿️ 🅿️ ${res.length} bytes in string');
  return res;
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForZippedCities(
    String userId, String token, RootIsolateToken rootToken) async {
  pp('\n\n$xyz _heavyTaskForZippedCities 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.getCities() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();
  final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
  final SemCache semCache = GetIt.instance<SemCache>();
  final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
  return await zipHandler.getCitiesString(userId, token);
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForUsers({
  required String associationId,
  required String token,
}) async {
  pp('$xyz2 _heavyTaskForUsers starting ................associationId:  $associationId .');
  final cmd =
      '${KasieEnvironment.getUrl()}getAssociationUsers?associationId=$associationId';

  final users = <lib.User>[];
  List resp = await _httpGet(cmd, token);
  for (var map in resp) {
    users.add(lib.User.fromJson(map));
  }
  pp('$xyz2  Users found: ${users.length}');
  final s = jsonEncode(users);
  return s;
}

//getRoutePointsZipped
@pragma('vm:entry-point')
Future<String> _heavyTaskForZippedRoutePoints(
    String routeId, String token, RootIsolateToken rootToken) async {
  pp('\n\n$xyz _heavyTaskForZippedRoutePoints 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.getRoutePoints() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();
  final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
  final SemCache semCache = GetIt.instance<SemCache>();
  final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
  return await zipHandler.getRoutePoints(routeId: routeId, token: token);
}

@pragma('vm:entry-point')
Future<String> _heavyTaskCountries({
  required String token,
}) async {
  pp('$xyz2 _heavyTaskCountriess starting ................');
  final cmd = '${KasieEnvironment.getUrl()}getCountries';

  final countries = <Country>[];
  List resp = await _httpGet(cmd, token);
  for (var map in resp) {
    countries.add(Country.fromJson(map));
  }
  pp('$xyz2  Countries found: ${countries.length}');
  final s = jsonEncode(countries);
  return s;
}
// @pragma('vm:entry-point')
// Future<String> _heavyTaskForRoutePoints(RoutePointsBag bag) async {
//   pp('$xyz2 _heavyTaskForRoutePoints starting ................routeIds:  ${bag.routeIds.length} .');
//
//   final points = [];
//   final token = bag.token;
//   for (var id in bag.routeIds) {
//     points.addAll(await _processRoute(id, bag.url, token));
//     pp('$xyz2 RoutePoints for routes processed so far ... ${E.appleGreen} total: ${points.length}');
//   }
//
//   final jsonList = jsonEncode(points);
//   pp('$xyz2  RoutePoints for route(s): ${points.length}');
//
//   return jsonList;
// }

// Future<List> _processRoute(String routeId, String url, String token) async {
//   pp('\n\n$xyz _processRoute routeId: $routeId');
//
//   int page = 0;
//   bool stop = false;
//   final points = [];
//   Map<String, String> headers = {
//     'Content-type': 'application/json',
//     'Accept': 'application/json',
//   };
//   headers['Authorization'] = 'Bearer $token';
//
//   while (stop == false) {
//     final mUrl = '${url}getRoutePoints?routeId=$routeId&page=$page';
//     List resp = await httpGet(mUrl, token, headers);
//     pp('$xyz page of RoutePoints for routeId: $routeId: ${resp.length}');
//
//     if (resp.isEmpty) {
//       stop = true;
//     }
//     points.addAll(resp);
//     page++;
//     pp('$xyz .... sleeping for .5 second ...');
//     await Future.delayed(const Duration(milliseconds: 500));
//   }
//
//   pp('$xyz RoutePoints for routeId: $routeId: ${points.length}\n\n');
//   return points;
// }

@pragma('vm:entry-point')
Future<String> _heavyTaskForRouteLandmarks(BunnyBag bag) async {
  pp('$xyz1 _heavyTaskForRouteLandmarks starting .................associationId: ${bag.associationId} .');

  final routeLandmarks = [];
  final token = bag.token;

  List resp = await _httpGet(bag.url, token);
  routeLandmarks.addAll(resp);
  final jsonList = jsonEncode(routeLandmarks);
  pp('$xyz1 Association RouteLandmarks for all routes: ${routeLandmarks.length}');
  return jsonList;
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForRouteCities(BunnyBag bag) async {
  pp('$xyz3 _heavyTaskForRouteCities starting ................. associationId; ${bag.associationId} .');

  final routeCities = [];
  final token = bag.token;

  List resp = await _httpGet(bag.url, token);
  routeCities.addAll(resp);
  final jsonList = jsonEncode(routeCities);
  pp('$xyz3  RouteCities for all routes: ${routeCities.length}');
  return jsonList;
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForSingleRoute(
    String routeId, String token, RootIsolateToken rootToken) async {
  pp('$xyz _heavyTaskForSingleRoute starting ................. routeId; $routeId ');

  final start = DateTime.now();
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();
  final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
  final SemCache semCache = GetIt.instance<SemCache>();

  final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
  RouteBag? routeBag =
      await zipHandler.refreshRoute(routeId: routeId, token: token);
  pp('$xyz Route refreshed ${E.nice} for ${routeBag!.route!.name} '
      '\n routeLandmarks: ${routeBag.routeLandmarks.length}'
      '\n routePoints: ${routeBag.routePoints.length}'
      '\n routeCities: ${routeBag.routeCities.length}');
  final s = routeBag.toJson();
  final jsonList = jsonEncode(s);
  final end = DateTime.now();
  pp('$xyz Elapsed time for route refresh: ${end.difference(start).inSeconds} seconds');
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
        .timeout(const Duration(seconds: 600));
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

    if (resp.statusCode > 201) {
      var msg =
          '😡 😡 The response is not 200 or 201; it is ${resp.statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
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

class RoutePointsBag {
  late List<String> routeIds;
  late String url, token;

  RoutePointsBag(this.routeIds, this.url, this.token);
}

class BunnyBag {
  late String associationId;
  late String url, token;

  BunnyBag(this.associationId, this.url, this.token);
}

class BirdieBag {
  late String associationId, routeId;
  late String url, token;

  BirdieBag(this.associationId, this.routeId, this.url, this.token);
}
