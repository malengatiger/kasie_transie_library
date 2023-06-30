import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:realm/realm.dart' as rm;

import '../data/route_bag.dart';
import '../data/schemas.dart';
import '../providers/kasie_providers.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/parsers.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

final http.Client client = http.Client();
final config = rm.Configuration.local(
  [
    Country.schema,
    City.schema,
    Association.schema,
    Route.schema,
    RoutePoint.schema,
    Position.schema,
    User.schema,
    Landmark.schema,
    RouteInfo.schema,
    CalculatedDistance.schema,
    SettingsModel.schema,
    RouteStartEnd.schema,
    RouteLandmark.schema,
    RouteCity.schema,
    State.schema,
    Vehicle.schema,
    LocationResponse.schema,
    LocationRequest.schema,
  ],
);
final ListApiDog listApiDog = ListApiDog(
    client, appAuth, cacheManager, prefs, errorHandler, rm.Realm(config));

class ListApiDog {
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ ListApiDog: ❤️: ';
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> zipHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/zip',
  };

  late String url;
  static const timeOutInSeconds = 300;

  final http.Client client;
  final AppAuth appAuth;
  final CacheManager cacheManager;
  final Prefs prefsOGx;
  final ErrorHandler errorHandler;
  late rm.Realm realm;

  late rm.User realmUser;
  late rm.App app;
  static const realmAppId = 'application-0-rmusa';
  static const realmPublicKey = 'xtffryvl';
  static const privateKey = 'ff87d3e1-6366-4a9c-9ae0-8065540a8483';

  bool initialized = false;

  ListApiDog(this.client, this.appAuth, this.cacheManager, this.prefsOGx,
      this.errorHandler, this.realm) {
    if (KasieEnvironment.currentStatus == 'dev') {
      url = KasieEnvironment.devUrl;
    } else {
      url = KasieEnvironment.prodUrl;
    }
    initializeRealm();
    getAuthToken();
  }

  Future getAuthToken() async {
    pp('$mm getAuthToken: ...... Getting Firebase token ......');
    var m = await appAuth.getAuthToken();
    if (m == null) {
      pp('$mm Unable to get Firebase token');
      token = 'NoToken';
    } else {
      pp('$mm Firebase token retrieved OK');
      token = m;
    }
  }

  Future<bool> initializeRealm() async {
    pp('$mm ........ initialize Realm with Device Sync ....');
    app = rm.App(rm.AppConfiguration(realmAppId));
    realmUser = app.currentUser ?? await app.logIn(rm.Credentials.anonymous());

    try {
      rm.Realm.logger.level = rm.RealmLogLevel.detail;

      pp('\n\n$mm RealmApp configured  🥬 🥬 🥬 🥬; realmUser : $realmUser'
          '\n🌎🌎state: ${realmUser.state.name} '
          '\n🌎🌎accessToken: ${realmUser.accessToken} '
          '\n🌎🌎id:${realmUser.id} \n🌎🌎name:${realmUser.profile.name}');

      for (final schema in realm.schema) {
        pp('$mm RealmApp configured; schema : 🍎🍎${schema.name}');
      }
      pp('\n$mm RealmApp configured OK  🥬 🥬 🥬 🥬: 🔵 ${realm.schema.length} Realm schemas \n\n');
      initialized = true;
      return initialized;
    } catch (e) {
      pp('$mm ${E.redDot}${E.redDot}${E.redDot}${E.redDot} Problem initializing Realm: $e');
    }
    return false;
  }

  Future<User> getUserById(String userId) async {
    final cmd = '${url}getUserById?userId=$userId';
    final resp = await _sendHttpGET(cmd);
    final user = buildUser(resp);

    pp('$mm getUserById found this user: ${user.name} ');
    myPrettyJsonPrint(resp);
    return user;
  }

  Future<Association> getAssociationById(String associationId) async {
    final res =
        realm.query<Association>('associationId == \$0', [associationId]);
    if (res.isNotEmpty) {
      return res.first;
    }
    final cmd = '${url}getAssociationById?associationId=$associationId';
    final resp = await _sendHttpGET(cmd);
    final ass = buildAssociation(resp);
    realm.write(() {
      realm.add(ass, update: true);
    });
    pp('$mm ... cached association: ${ass.associationName}');
    await prefs.saveAssociation(ass);
    return ass;
  }

  Country? getCountryById(String countryId) {
    final res = realm.query<Country>('countryId == \$0 ', [countryId]);
    if (res.isNotEmpty) {
      prefs.saveCountry(res.first);
      return res.first;
    }
    return null;
  }

  Future<List<State>> getCountryStates(String countryId) async {
    var mList = <State>[];

    final res = realm.all<State>();
    if (res.isNotEmpty) {
      for (var value in res) {
        mList.add(value);
      }
    }
    if (mList.isNotEmpty) {
      return mList;
    }
    final cmd = '${url}getCountryStates?countryId=$countryId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      mList.add(buildState(value));
    }

    realm.write(() {
      realm.addAll(mList);
    });
    pp('$mm cached states: ${mList.length}');

    return mList;
  }

  Future<List<SettingsModel>> getSettings(String associationId) async {
    rm.RealmResults<SettingsModel> results1 = realm.all<SettingsModel>();
    final list1 = <SettingsModel>[];
    if (results1.isNotEmpty) {
      for (var element in results1) {
        list1.add(element);
      }
      return list1;
    }
    final cmd = '${url}getAssociationSettings?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    final list = <SettingsModel>[];
    for (var value in resp) {
      list.add(buildSettingsModel(value));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached settings: ${list.length}');
    return list;
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    rm.RealmResults<Vehicle> results =
        realm.query<Vehicle>("vehicleId == \$0", [vehicleId]);
    final list = <Vehicle>[];
    if (results.isNotEmpty) {
      for (var element in results) {
        list.add(element);
      }
      return list.first;
    }
    return null;
  }

  Future<List<Vehicle>> getAssociationVehicles(
      String associationId, bool refresh) async {
    rm.RealmResults<Vehicle> results = realm.all<Vehicle>();
    final list = <Vehicle>[];
    if (refresh || results.isEmpty) {
      return await getCarsFromBackend(associationId);
    }

    for (var element in results) {
      list.add(element);
    }
    pp('$mm cached association vehicles from realm: ${list.length}');

    return list;
  }

  Future<List<RouteCity>> getAssociationRouteCities(
      String associationId) async {
    final cmd = '${url}getAssociationRouteCities?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    var list = <RouteCity>[];
    for (var mJson in resp) {
      list.add(buildRouteCity(mJson));
    }

    realm.write(() {
      realm.addAll<RouteCity>(list, update: true);
    });
    pp('$mm cached association cities from backend: ${list.length}');
    return list;
  }

  Future<List<RouteLandmark>> getAssociationRouteLandmarks(
      String associationId) async {
    final cmd =
        '${url}getAssociationRouteLandmarks?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in resp) {
      list.add(buildRouteLandmark(mJson));
    }

    realm.write(() {
      realm.addAll<RouteLandmark>(list, update: true);
    });
    pp('$mm cached association routeLandmarks from backend: ${list.length}');
    return list;
  }

  Future<List<RoutePoint>> getAssociationRoutePoints(
      String associationId) async {
    final cmd = '${url}getAssociationRoutePoints?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    var list = <RoutePoint>[];
    for (var mJson in resp) {
      list.add(buildRoutePoint(mJson));
    }

    realm.write(() {
      realm.addAll<RoutePoint>(list, update: true);
    });
    pp('$mm cached association routePoints from backend: ${list.length}');
    return list;
  }

  Future<List<Vehicle>> getCarsFromBackend(String associationId) async {
    final cmd = '${url}getAssociationVehicles?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    var list = <Vehicle>[];
    for (var vehicleJson in resp) {
      list.add(buildVehicle(vehicleJson));
    }

    realm.write(() {
      realm.deleteAll<Vehicle>();
      realm.addAll<Vehicle>(list, update: true);
    });
    pp('$mm cached association vehicles from backend: ${list.length}');
    return list;
  }

  Future<List<Association>> getAssociations() async {
    rm.RealmResults<Association> results = realm.all<Association>();
    final list = <Association>[];
    if (results.isNotEmpty) {
      for (var element in results) {
        list.add(element);
      }
      return list;
    }
    final cmd = '${url}getAssociations';
    List resp = await _sendHttpGET(cmd);
    for (var m in resp) {
      list.add(buildAssociation(m));
    }
    realm.write(() {
      realm.addAll(list, update: true);
    });
    pp('$mm cached associations: ${list.length}');
    return list;
  }

  final StreamController<List<RoutePoint>> _routePointController =
      StreamController.broadcast();

  Stream<List<RoutePoint>> get routePointStream => _routePointController.stream;

  Future<List<RoutePoint>> getRoutePoints(String routeId, bool refresh) async {
    //todo - get points from realm
    var list = _getPointsFromRealm(routeId);
    if (refresh || list.isEmpty) {
      list = await _getPointsFromBackend(routeId);
    }
    _routePointController.sink.add(list);
    pp('$mm cached routePoints inside Realm : ${E.leaf2} ${list.length}');
    return list;
  }

  List<RoutePoint> _getPointsFromRealm(String routeId) {
    pp('$mm getting cached routePoints from realm ...');
    var list = <RoutePoint>[];
    final b = realm.query<RoutePoint>('routeId == \$0', [routeId]);
    list = b.toList();
    pp('$mm cached routePoints returned from Realm : ${E.blueDot} ${list.length}');
    if (list.isNotEmpty) {
      myPrettyJsonPrint(list.last.toJson());
    }
    return list;
  }

  Future<List<RoutePoint>> _getPointsFromBackend(String routeId) async {
    var list = <RoutePoint>[];
    final cmd = '${url}getRoutePoints?routeId=$routeId';

    List resp = await _sendHttpGET(cmd);
    pp('$mm getRoutePoints call returned; before build ...  ${E.blueDot} ${resp.length} routePoints .');

    for (var value in resp) {
      final rp = buildRoutePoint(value);
      list.add(rp);
    }
    pp('$mm getRoutePoints call returned  ${E.blueDot} ${list.length} routePoints .');

    try {
      realm.write(() {
        realm.addAll<RoutePoint>(list, update: true);
      });
      final results = realm.query<RoutePoint>('routeId == \$0', [routeId]);
      final mList = results.toList();
      return mList;
    } catch (e) {
      pp('$mm  ${E.redDot} Realm does not like something? ${E.redDot} $e ${E.redDot} ');
    }
    if (list.isNotEmpty) {
      myPrettyJsonPrint(list.last.toJson());
    }
    pp('$mm cached routePoints returned from Realm : ${E.blueDot} ${list.length}');
    return list;
  }

  final StreamController<List<Route>> _routeController =
      StreamController.broadcast();

  Stream<List<Route>> get routeStream => _routeController.stream;

  final StreamController<List<City>> _cityController =
      StreamController.broadcast();

  Stream<List<City>> get cityStream => _cityController.stream;

  Future<List<RouteLandmark>> getRouteLandmarks(
      String routeId, bool refresh) async {
    pp('$mm .................. getRouteLandmarks refresh: $refresh');

    var localList = <RouteLandmark>[];
    rm.RealmResults<RouteLandmark> results =
        realm.query<RouteLandmark>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm RouteLandmarks from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getRouteLandmarksFromBackend(routeId: routeId);
      pp('$mm RouteLandmarks from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<RouteLandmark>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<Route?> getRoute(String routeId) async {
    pp('$mm .................. getRoute');

    var localList = <Route>[];
    rm.RealmResults<Route> results =
        realm.query<Route>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm Routes from realm:: ${localList.length}, should be 1');
    if (localList.isNotEmpty) {
      return localList.first;
    }

    return null;
  }

  Future<List<CalculatedDistance>> getCalculatedDistances(
      String routeId, bool refresh) async {
    pp('$mm .................. getCalculatedDistances refresh: $refresh');

    var localList = <CalculatedDistance>[];
    rm.RealmResults<CalculatedDistance> results =
        realm.query<CalculatedDistance>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm RouteLandmarks from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getCalculatedDistancesFromBackend(routeId: routeId);
      pp('$mm CalculatedDistances from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<CalculatedDistance>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<RouteBag> refreshRoute(String routeId) async {
    pp('$mm .................. refreshRoute routeId: $routeId');

    final cmd = '${url}refreshRoute?routeId=$routeId';
    final bagMap = await _sendHttpGET(cmd);
    final bag = RouteBag.fromJson(bagMap);

    pp('$mm ... refreshing route and all it\'s babies to realm');
    pp('$mm ... route: ${bag.route!.name!} from ${bag.route!.associationName}');
    pp('$mm ... routePoints: ${bag.routePoints.length}');
    pp('$mm ... routeLandmarks: ${bag.routeLandmarks.length}');
    pp('$mm ... routeCities: ${bag.routeCities.length}');

    realm.write(() {
      realm.add<Route>(bag.route!, update: true);
      realm.addAll(bag.routePoints, update: true);
      realm.addAll(bag.routeLandmarks, update: true);
      realm.addAll(bag.routeCities, update: true);
    });

    pp('\n$mm ... route has been refreshed!\n');
    return bag;
  }

  Future<List<Route>> getRoutes(AssociationParameter param) async {
    pp('$mm .................. getRoutes refresh: ${param.refresh}');

    final localList = <Route>[];
    rm.RealmResults<Route> results = realm.all<Route>();
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm ...... Routes from realm:: ${localList.length}');
    if (!param.refresh && localList.isNotEmpty) {
      _routeController.sink.add(localList);
      return localList;
    }

    final remoteList = await _getRoutesFromBackend(param);
    pp('$mm ... Routes from backend:: ${remoteList.length}');
    _routeController.sink.add(remoteList);
    return remoteList;
  }

  Future<List<Landmark>> findLandmarksByLocation(
      {required double latitude,
      required double longitude,
      required double radiusInKM}) async {
    pp('$mm .................. findLandmarksByLocation; radius: $radiusInKM');

    final list = <Landmark>[];
    final cmd =
        '${url}findLandmarksByLocation?latitude=$latitude&longitude=$longitude&radiusInKM=$radiusInKM';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildLandmark(value);
      list.add(r);
    }

    pp('$mm Landmarks found by location search: ${list.length}');
    return list;
  }

  Future<List<CalculatedDistance>> _getCalculatedDistancesFromBackend(
      {required String routeId}) async {
    pp('$mm .................. _getCalculatedDistancesFromBackend; routeId: $routeId');

    final list = <CalculatedDistance>[];
    final cmd = '${url}getCalculatedDistances?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildCalculatedDistance(value);
      list.add(r);
    }

    pp('$mm Route CalculatedDistances found: ${list.length}');
    return list;
  }

  Future<List<RouteLandmark>> _getRouteLandmarksFromBackend(
      {required String routeId}) async {
    pp('$mm .................. getRouteLandmarks; routeId: $routeId');

    final list = <RouteLandmark>[];
    final cmd = '${url}getRouteLandmarks?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildRouteLandmark(value);
      list.add(r);
    }

    pp('$mm Route Landmarks found: ${list.length}');
    return list;
  }

  Future<List<Route>> _getRoutesFromBackend(AssociationParameter p) async {
    final cmd = '${url}getAssociationRoutes?associationId=${p.associationId}';
    var list = <Route>[];
    List resp = await _sendHttpGET(cmd);

    for (var value in resp) {
      pp('$mm route from backend: ${value['name']}');
      var r = buildRoute(value);
      list.add(r);
    }
    try {
      realm.write(() {
        realm.deleteAll<Route>();
      });
    } catch (e) {
      pp(e);
    }

    pp('$mm routes have been deleted from local realm db ');
    pp('$mm routes from backend : ${list.length}');

    for (var route in list) {
      try {
        realm.write(() {
          realm.add(route);
        });
      } catch (e) {
        pp('$mm ... REALM ERROR: ${E.redDot} $e');
      }
    }
    pp('$mm ......... cached routes: ${list.length}');
    return list;
  }

  Future<List<Route>> findRoutesByLocation(LocationFinderParameter p) async {
    var list = <Route>[];
    final user = await prefs.getUser();

    final cmd = '${url}findRoutesByLocation?latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildRoute(value));
    }
    // realm.write(() {
    //   realm.addAll(list);
    // });
    pp('$mm findRoutesByLocation;  ${E.appleRed} routes found: ${list.length}');

    return list;
  }

  Future<List<Route>> findAssociationRoutesByLocation(
      LocationFinderParameter p) async {
    var list = <Route>[];
    final user = await prefs.getUser();

    final cmd =
        '${url}findAssociationRoutesByLocation?associationId=${p.associationId}'
        '&latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildRoute(value));
    }

    pp('$mm findAssociationRoutesByLocation;  ${E.appleRed} routes found: ${list.length}');

    return list;
  }

  Future<List<City>> findCitiesByLocation(LocationFinderParameter p) async {
    var list = <City>[];
    final user = await prefs.getUser();
    final cmd = '${url}findCitiesByLocation?latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}&limit=${p.limit}';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildCity(value));
    }

    pp('$mm findCitiesByLocation;  ${E.appleRed} cities found: ${list.length}');

    return list;
  }

  Future<List<City>> getCountryCities(String countryId) async {
    final list = <City>[];
    rm.RealmResults<City> results = realm.all<City>();
    if (results.isNotEmpty) {
      for (var element in results) {
        list.add(element);
      }
      pp('$mm country cities from realm: ${list.length}');
      return list;
    }
    rm.RealmResults<City>? realmResults;
    realmResults = realm.query('countryId == \$0', [countryId]);
    final list1 = realmResults.toList();
    //todo remove after test
    if (realmResults.toList().isNotEmpty) {
      pp('$mm country cities found in local Realm: ${list1.length}');
      final c = list1.last;
      // myPrettyJsonPrint(c.toJson());
      return list1;
    }
    final cmd = '${url}getCountryCities?countryId=$countryId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildCity(value));
    }
    realm.write(() {
      realm.addAll<City>(list);
    });
    pp('$mm cached country cities: ${list.length}');
    _cityController.sink.add(list);
    return list;
  }

  Future removeRoutePoint(String routePointId) async {
    realm.write(() {
      rm.RealmResults list =
          realm.query<RoutePoint>('routePointId == \$0', [routePointId]);
      RoutePoint? point;
      if (list.isNotEmpty) {
        point = list.toList().first as RoutePoint;
        realm.delete<RoutePoint>(point);
        pp('$mm ... routePoint deleted from Realm ...');
      }
    });
    //
    getRoutePoints(routePointId, true);
  }

  Future<List<User>> getAssociationUsers(String associationId) async {
    final list = <User>[];
    rm.RealmResults<User> results = realm.all<User>();
    if (results.isNotEmpty) {
      for (var element in results) {
        list.add(element);
      }
      return list;
    }
    final cmd = '${url}getAssociationUsers?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildUser(value));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached users: ${list.length}');
    return list;
  }

  Future<List<Country>> getCountries() async {
    rm.RealmResults<Country>? realmResults;
    realmResults = realm.all<Country>();
    final list1 = realmResults.toList();
    //todo remove after test
    if (realmResults.toList().isNotEmpty) {
      pp('$mm countries found in local Realm: ${list1.length}');
      final c = list1.last;
      myPrettyJsonPrint(c.toJson());
      return list1;
    }

    final cmd = '${url}getCountries';
    List resp = await _sendHttpGET(cmd);
    final list = <Country>[];
    for (var value in resp) {
      list.add(buildCountry(value));
    }

    await realm.writeAsync(() {
      realm.addAll(list);
    });
    rm.RealmResults? results;
    results = realm.all<Country>();
    pp('\n\n$mm cached countries in local Realm database: '
        '${results.length} \n');
    return list;
  }

  Future ping() async {
    var result = await _sendHttpGET('${url}ping');
    pp('$mm result of ping: $result');
  }

  static const xz = '🌎🌎🌎🌎🌎🌎 ListApiDog: ';

  String token = 'NoTokenYet';

  Future _sendHttpGET(String mUrl) async {
    pp('$xz _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    headers['Authorization'] = 'Bearer $token';
    try {
      var resp = await client
          .get(
            Uri.parse(mUrl),
            headers: headers,
          )
          .timeout(const Duration(seconds: timeOutInSeconds));
      pp('$xz http GET call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
      var end = DateTime.now();
      pp('$xz http GET call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

      if (resp.body.contains('not found')) {
        return false;
      }

      if (resp.statusCode == 403) {
        var msg =
            '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
        pp(msg);
        final gex = KasieException(
            message: 'Forbidden call',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
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
        errorHandler.handleError(exception: gex);
        throw gex;
      }
      var mJson = json.decode(resp.body);
      return mJson;
    } on SocketException {
      pp('$xz SocketException, really means that server cannot be reached 😑');
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on HttpException {
      pp("$xz HttpException occurred 😱");
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.httpException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on FormatException {
      pp("$xz Bad response format 👎");
      final gex = KasieException(
          message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.formatException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on TimeoutException {
      pp("$xz No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
      final gex = KasieException(
          message: 'No Internet connection. Request timed out',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
  }
}
