import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/data/counter_bag.dart';
import 'package:kasie_transie_library/data/vehicle_bag.dart';
import 'package:kasie_transie_library/isolates/country_cities_isolate.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:realm/realm.dart' as rm;

import '../data/big_bag.dart';
import '../data/route_bag.dart';
import '../data/schemas.dart';
import '../isolates/vehicles_isolate.dart';
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
    StateProvince.schema,
    Vehicle.schema,
    LocationResponse.schema,
    LocationRequest.schema,
    DispatchRecord.schema,
    VehiclePhoto.schema,
    VehicleVideo.schema,
    VehicleMediaRequest.schema,
    RouteUpdateRequest.schema,
    AmbassadorPassengerCount.schema,
    AmbassadorCheckIn.schema,
    CommuterRequest.schema,
    Commuter.schema,
    VehicleHeartbeat.schema,
    VehicleArrival.schema,
    RouteAssignment.schema,
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
    url = KasieEnvironment.getUrl();
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
    pp('$mm ........ initialize Realm without Device Sync ....');
    app = rm.App(rm.AppConfiguration(realmAppId));
    realmUser = app.currentUser ?? await app.logIn(rm.Credentials.anonymous());

    try {
      rm.Realm.logger.level = rm.RealmLogLevel.detail;

      pp('\n\n$mm RealmApp configured  🥬 🥬 🥬 🥬; realmUser : ${realmUser.app.toString()}'
          '\n🌎🌎state: ${realmUser.state.name} '
          '\n🌎🌎accessToken: ${realmUser.accessToken} '
          '\n🌎🌎id:${realmUser.id} '
          '\n🌎🌎name:${realmUser.profile.name}');

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

  Future<User?> getUserById(String userId) async {
    final cmd = '${url}getUserById?userId=$userId';
    final resp = await _sendHttpGET(cmd);
    pp('$mm getUserById: ........ response: $resp');
    if (resp is String) {
      if (resp.contains('not found')) {
        throw Exception('User not found');
      }
    }
    final user = buildUser(resp);

    pp('$mm getUserById found this user: ${user.name} ');
    myPrettyJsonPrint(resp);
    return user;
  }

  Future<User?> getUserByEmail(String email) async {
    final cmd = '${url}getUserByEmail?email=$email';
    try {
      final resp = await _sendHttpGET(cmd);
      final user = buildUser(resp);

      pp('$mm getUserByEmail found this user: ${user.name} ');
      myPrettyJsonPrint(resp);
      return user;
    } catch (e) {
      pp(e);
      rethrow;
    }
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

  Future<BigBag> getOwnersBag(String userId, String startDate) async {
    pp('$mm ............................ getOwnersBag, userId: $userId startDate: $startDate ....');
    final url = KasieEnvironment.getUrl();
    final cmd = '${url}getOwnersBag?userId=$userId&startDate=$startDate';
    final resp = await _sendHttpGET(cmd);
    final bag = BigBag.fromJson(resp);

    pp('$mm .......... getOwnersBag returned: '
        '\n ${E.broc} vehicleHeartbeats: ${bag.vehicleHeartbeats.length} '
        '\n ${E.broc} vehicleArrivals: ${bag.vehicleArrivals.length} '
        '\n ${E.broc} dispatchRecords: ${bag.dispatchRecords.length} '
        '\n ${E.broc} passengerCounts: ${bag.passengerCounts.length} '
        '\n ${E.broc} vehicleDepartures: ${bag.vehicleDepartures.length}');

    return bag;
  }

  Future<VehicleBag> getVehicleBag(String vehicleId, String startDate) async {
    final cmd = '${url}getVehicleBag?vehicleId=$vehicleId&startDate=$startDate';
    final resp = await _sendHttpGET(cmd);
    final bag = VehicleBag.fromJson(resp);

    pp('$mm VehicleBag: '
        '\n${E.appleRed} vehicleHeartbeats: ${bag.heartbeats.length} '
        '\n vehicleArrivals: ${bag.arrivals.length} '
        '\n dispatchRecords: ${bag.dispatchRecords.length} '
        '\n passengerCounts: ${bag.passengerCounts.length} '
        '\n vehicleDepartures: ${bag.departures.length}');

    return bag;
  }

  Future<List<StateProvince>> getCountryStates(String countryId) async {
    var mList = <StateProvince>[];

    final res = realm.all<StateProvince>();
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

  Future<List<SettingsModel>> getSettings(
      String associationId, bool refresh) async {
    rm.RealmResults<SettingsModel> results1 = realm.all<SettingsModel>();
    final list1 = <SettingsModel>[];
    if (results1.isNotEmpty) {
      for (var element in results1) {
        list1.add(element);
      }
    }
    if (list1.isEmpty || refresh) {
      final cmd = '${url}getAssociationSettings?associationId=$associationId';
      List resp = await _sendHttpGET(cmd);
      list1.clear();
      for (var value in resp) {
        list1.add(buildSettingsModel(value));
      }
      realm.write(() {
        realm.addAll<SettingsModel>(list1, update: true);
      });
    }
    pp('$mm cached settings: ${list1.length}');
    return list1;
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
      return await vehicleIsolate.getVehicles(associationId);
    }

    for (var element in results) {
      list.add(element);
    }
    pp('$mm cached association vehicles from realm: ${list.length}');

    return list;
  }

  final StreamController<List<Vehicle>> _vehiclesStreamController = StreamController.broadcast();
  Stream<List<Vehicle>> get vehiclesStream => _vehiclesStreamController.stream;

  Future<List<Vehicle>> getOwnerVehicles(String userId, bool refresh) async {
    rm.RealmResults<Vehicle> results =
        realm.query<Vehicle>('ownerId == \$0', [userId]);

    final list = <Vehicle>[];
    if (refresh || results.isEmpty) {
      final nList = await vehicleIsolate.getOwnerVehicles(userId);
      _vehiclesStreamController.sink.add(nList);
      return nList;
    }

    for (var element in results) {
      list.add(element);
    }

    pp('$mm cached owner vehicles from realm: ${list.length}');

    return list;
  }

  Future<List<DispatchRecord>> getMarshalDispatchRecords(
      {required String userId,
      required bool refresh,
      required int days}) async {
    rm.RealmResults<DispatchRecord> results =
        realm.query<DispatchRecord>('marshalId == \$0', [userId]);
    final list = <DispatchRecord>[];
    if (refresh || results.isEmpty) {
      return await getMarshalDispatchesFromBackend(userId, days);
    }

    for (var element in results) {
      list.add(element);
    }
    pp('$mm cached dispatches from realm: ${list.length}');

    return list;
  }

  Future<List<RouteAssignment>> getVehicleRouteAssignments(
      String vehicleId, bool refresh) async {
    rm.RealmResults<RouteAssignment> results =
        realm.query<RouteAssignment>('vehicleId == \$0', [vehicleId]);
    final list = <RouteAssignment>[];
    if (refresh || results.isEmpty) {
      return await getVehicleRouteAssignmentsFromBackend(vehicleId);
    }

    for (var element in results) {
      list.add(element);
    }
    return list;
  }
  Future<List<RouteAssignment>> getRouteAssignments(
      String routeId, bool refresh) async {
    final cmd = '${url}getRouteAssignments?routeId=$routeId';
    rm.RealmResults<RouteAssignment> results =
    realm.query<RouteAssignment>('routeId == \$0', [routeId]);
    final list = <RouteAssignment>[];
    if (refresh || results.isEmpty) {
      return await getRouteAssignmentsFromBackend(routeId);
    }

    for (var element in results) {
      list.add(element);
    }
    return list;
  }

  Future<List<CounterBag>> getVehicleCounts(String vehicleId) async {
    final cmd = '${url}getVehicleCounts?vehicleId=$vehicleId';
    List resp = await _sendHttpGET(cmd);
    var list = <CounterBag>[];
    for (var mJson in resp) {
      list.add(CounterBag.fromJson(mJson));
    }

    pp('$mm getVehicleCounts from mongo: ${list.length}');
    return list;
  }

  Future<List<CounterBag>> getVehicleCountsByDate(
      String vehicleId, String startDate) async {
    final cmd =
        '${url}getVehicleCountsByDate?vehicleId=$vehicleId&startDate=$startDate';
    List resp = await _sendHttpGET(cmd);
    var list = <CounterBag>[];
    for (var mJson in resp) {
      list.add(CounterBag.fromJson(mJson));
    }

    pp('$mm getVehicleCountsByDate from mongo: ${list.length}');
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
      String associationId, bool refresh) async {
    var landmarks = realm.all<RouteLandmark>();
    var list = <RouteLandmark>[];
    landmarks.forEach((element) {
      list.add(element);
    });
    if (list.isEmpty || refresh) {
      final cmd =
          '${url}getAssociationRouteLandmarks?associationId=$associationId';
      List resp = await _sendHttpGET(cmd);
      list.clear();
      for (var mJson in resp) {
        list.add(buildRouteLandmark(mJson));
      }
      realm.write(() {
        realm.addAll<RouteLandmark>(list, update: true);
      });
      pp('$mm cached association routeLandmarks from backend: ${list.length}');
    }
    return list;
  }

  Future<List<RoutePoint>> getAssociationRoutePoints(
      String associationId) async {
    final res =
        realm.query<RoutePoint>('associationId == \$0', [associationId]);
    var list = <RoutePoint>[];

    for (var value in res) {
      list.add(value);
    }
    pp('$mm cached association routePoints from cache: ${list.length}');
    return list;
  }

  Future<int> countAssociationRoutePoints() async {
    final res = realm.all<RoutePoint>();
    pp('$mm cached association routePoints from cache: ${res.length}');
    return res.length;
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

  Future<List<Vehicle>> getOwnerCarsFromBackend(String userId) async {
    final cmd = '${url}getOwnerVehicles?userId=$userId';

    List resp = await _sendHttpGET(cmd);
    var list = <Vehicle>[];
    for (var vehicleJson in resp) {
      list.add(buildVehicle(vehicleJson));
    }

    realm.write(() {
      realm.deleteAll<Vehicle>();
      realm.addAll<Vehicle>(list, update: true);
    });
    pp('$mm cached owner vehicles from backend: ${list.length}');
    return list;
  }

  Future<List<RouteAssignment>> getVehicleRouteAssignmentsFromBackend(
      String vehicleId) async {
    final cmd = '${url}getVehicleRouteAssignments?vehicleId=$vehicleId';

    List resp = await _sendHttpGET(cmd);
    var list = <RouteAssignment>[];
    for (var json in resp) {
      list.add(buildRouteAssignment(json));
    }

    realm.write(() {
      realm.addAll<RouteAssignment>(list, update: true);
    });
    pp('$mm cached routeAssignments from backend: ${list.length}');
    return list;
  }

  Future<List<RouteAssignment>> getRouteAssignmentsFromBackend(
      String routeId) async {
    final cmd = '${url}getRouteAssignments?routeId=$routeId';

    List resp = await _sendHttpGET(cmd);
    var list = <RouteAssignment>[];
    for (var json in resp) {
      list.add(buildRouteAssignment(json));
    }

    realm.write(() {
      realm.addAll<RouteAssignment>(list, update: true);
    });
    pp('$mm cached routeAssignments from backend: ${list.length}');
    return list;
  }

  Future<List<DispatchRecord>> getMarshalDispatchesFromBackend(
      String userId, int days) async {
    final startDate = DateTime.now().toUtc().subtract(Duration(days: days));
    final cmd =
        '${url}getMarshalDispatchRecords?userId=$userId&startDate=$startDate';
    List resp = await _sendHttpGET(cmd);
    var list = <DispatchRecord>[];
    for (var vehicleJson in resp) {
      list.add(buildDispatchRecord(vehicleJson));
    }

    realm.write(() {
      realm.addAll<DispatchRecord>(list, update: true);
    });
    pp('$mm cached marshal dispatches from backend: ${list.length}');
    return list;
  }

  Future<List<Association>> getAssociations(bool refresh) async {
    rm.RealmResults<Association> results = realm.all<Association>();
    final list = <Association>[];
    if (results.isNotEmpty) {
      for (var element in results) {
        list.add(element);
      }
    }
    if (list.isEmpty || refresh) {
      final cmd = '${url}getAssociations';
      List resp = await _sendHttpGET(cmd);
      for (var m in resp) {
        list.add(buildAssociation(m));
      }
      realm.write(() {
        realm.addAll<Association>(list, update: true);
      });
    }
    pp('$mm cached associations: ${list.length}');
    return list;
  }

  final StreamController<List<RoutePoint>> _routePointController =
      StreamController.broadcast();

  Stream<List<RoutePoint>> get routePointStream => _routePointController.stream;

  List<RoutePoint> getPointsFromRealm(String routeId) {
    pp('$mm getting cached routePoints from realm ...');
    var list = <RoutePoint>[];
    final b = realm.query<RoutePoint>('routeId == \$0', [routeId]);
    list = b.toList();
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
    var localList = <RouteLandmark>[];
    rm.RealmResults<RouteLandmark> results =
        realm.query<RouteLandmark>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm RouteLandmarks from realm:: ${localList.length}');
    if (localList.isEmpty || refresh) {
      try {
        localList = await _getRouteLandmarksFromBackend(routeId: routeId);
        pp('$mm RouteLandmarks from backend:: ${localList.length}');
        realm.write(() {
          realm.addAll<RouteLandmark>(localList, update: true);
        });
      } catch (e) {
        pp(e);
      }
    }
    //

    return localList;
  }

  Future<List<VehiclePhoto>> getVehiclePhotos(
      String vehicleId, bool refresh) async {
    var localList = <VehiclePhoto>[];
    rm.RealmResults<VehiclePhoto> results =
        realm.query<VehiclePhoto>("vehicleId == \$0", [vehicleId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm VehiclePhotos from realm:: ${localList.length} refresh: $refresh');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getVehiclePhotosFromBackend(vehicleId: vehicleId);
      pp('$mm VehiclePhoto from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<VehiclePhoto>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleVideo>> getVehicleVideos(
      String vehicleId, bool refresh) async {
    var localList = <VehicleVideo>[];
    rm.RealmResults<VehicleVideo> results =
        realm.query<VehicleVideo>("vehicleId == \$0", [vehicleId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm VehicleVideos from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getVehicleVideosFromBackend(vehicleId: vehicleId);
      pp('$mm VehicleVideos from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<VehicleVideo>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<AmbassadorPassengerCount>> getAmbassadorPassengerCountsByVehicle(
      {required String vehicleId,
      required bool refresh,
      required String startDate}) async {
    var localList = <AmbassadorPassengerCount>[];
    rm.RealmResults<AmbassadorPassengerCount> results =
        realm.query<AmbassadorPassengerCount>("vehicleId == \$0", [vehicleId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm AmbassadorPassengerCounts from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getVehicleAmbassadorPassengerCountsFromBackend(
          vehicleId: vehicleId, startDate: startDate);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<AmbassadorPassengerCount>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<AmbassadorPassengerCount>> getAmbassadorPassengerCountsByUser(
      {required String userId,
      required bool refresh,
      required String startDate}) async {
    var localList = <AmbassadorPassengerCount>[];
    rm.RealmResults<AmbassadorPassengerCount> results =
        realm.query<AmbassadorPassengerCount>("userId == \$0", [userId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm AmbassadorPassengerCounts from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getUserAmbassadorPassengerCountsFromBackend(
          userId: userId, startDate: startDate);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<AmbassadorPassengerCount>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<CommuterRequest>> getAssociationCommuterRequests(
      {required String associationId,
      required bool refresh,
      required String startDate}) async {
    var localList = <CommuterRequest>[];
    rm.RealmResults<CommuterRequest> results =
        realm.query<CommuterRequest>("associationId == \$0", [associationId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm CommuterRequests from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationCommuterRequests?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getCommuterRequestsFromBackend(url: url);
      pp('$mm CommuterRequests from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<CommuterRequest>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<DispatchRecord>> getAssociationDispatchRecords(
      {required String associationId,
      required bool refresh,
      required String startDate}) async {
    var localList = <DispatchRecord>[];
    rm.RealmResults<DispatchRecord> results =
        realm.query<DispatchRecord>("associationId == \$0", [associationId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm DispatchRecords from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationDispatchRecords?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getDispatchRecordsFromBackend(url: url);
      pp('$mm DispatchRecord from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<DispatchRecord>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<AmbassadorPassengerCount>>
      getAssociationAmbassadorPassengerCounts(
          {required String associationId,
          required bool refresh,
          required String startDate}) async {
    var localList = <AmbassadorPassengerCount>[];
    rm.RealmResults<AmbassadorPassengerCount> results = realm
        .query<AmbassadorPassengerCount>(
            "associationId == \$0", [associationId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm AmbassadorPassengerCounts from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationAmbassadorPassengerCounts?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getPassengerCountsFromBackend(url: url);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<AmbassadorPassengerCount>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<AmbassadorPassengerCount>> getRoutePassengerCounts(
      {required String routeId,
      required bool refresh,
      required String startDate}) async {
    var localList = <AmbassadorPassengerCount>[];
    rm.RealmResults<AmbassadorPassengerCount> results = realm
        .query<AmbassadorPassengerCount>("associationId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm AmbassadorPassengerCounts from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getRoutePassengerCounts?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getPassengerCountsFromBackend(url: url);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<AmbassadorPassengerCount>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleArrival>> getAssociationVehicleArrivals(
      {required String associationId,
      required bool refresh,
      required String startDate}) async {
    var localList = <VehicleArrival>[];
    rm.RealmResults<VehicleArrival> results =
        realm.query<VehicleArrival>("associationId == \$0", [associationId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm VehicleArrivals from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationVehicleArrivals?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getVehicleArrivalsFromBackend(url: url);
      pp('$mm VehicleArrivals from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<VehicleArrival>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleArrival>> getRouteVehicleArrivals(
      {required String routeId,
      required bool refresh,
      required String startDate}) async {
    var localList = <VehicleArrival>[];
    rm.RealmResults<VehicleArrival> results =
        realm.query<VehicleArrival>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm VehicleArrivals from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteVehicleArrivals?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getVehicleArrivalsFromBackend(url: url);
      pp('$mm VehicleArrivals from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<VehicleArrival>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<DispatchRecord>> getRouteDispatchRecords(
      {required String routeId,
      required bool refresh,
      required String startDate}) async {
    var localList = <DispatchRecord>[];
    rm.RealmResults<DispatchRecord> results =
        realm.query<DispatchRecord>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm DispatchRecords from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteDispatchRecords?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getDispatchRecordsFromBackend(url: url);
      pp('$mm DispatchRecord from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<DispatchRecord>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<CommuterRequest>> getRouteCommuterRequests(
      {required String routeId,
      required bool refresh,
      required String startDate}) async {
    var localList = <CommuterRequest>[];
    rm.RealmResults<CommuterRequest> results =
        realm.query<CommuterRequest>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        //todo - filter by date
        localList.add(element);
      }
    }
    pp('$mm CommuterRequests from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteCommuterRequests?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getCommuterRequestsFromBackend(url: url);
      pp('$mm CommuterRequests from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<CommuterRequest>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleMediaRequest>> getVehicleMediaRequests(
      String vehicleId, bool refresh) async {
    var localList = <VehicleMediaRequest>[];
    rm.RealmResults<VehicleMediaRequest> results =
        realm.query<VehicleMediaRequest>("vehicleId == \$0", [vehicleId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm VehicleMediaRequest from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getVehicleMediaRequestsFromBackend(
          vehicleId: vehicleId, associationId: null, startDate: null);
      pp('$mm VehicleMediaRequests from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<VehicleMediaRequest>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleMediaRequest>> getAssociationVehicleMediaRequests(
      String associationId, String startDate, bool refresh) async {
    var localList = <VehicleMediaRequest>[];
    rm.RealmResults<VehicleMediaRequest> results = realm
        .query<VehicleMediaRequest>("associationId == \$0", [associationId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm VehicleMediaRequest from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getVehicleMediaRequestsFromBackend(
          vehicleId: null, associationId: associationId, startDate: startDate);
      pp('$mm VehicleMediaRequests from backend, caching to realm: ${localList.length}');
      realm.write(() {
        realm.addAll<VehicleMediaRequest>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<RouteUpdateRequest>> getRouteUpdateRequests(
      String routeId, bool refresh) async {
    var localList = <RouteUpdateRequest>[];
    rm.RealmResults<RouteUpdateRequest> results =
        realm.query<RouteUpdateRequest>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm RouteUpdateRequest from realm:: ${localList.length}');
    if (localList.isNotEmpty && !refresh) {
      return localList;
    }
    //
    try {
      localList = await _getRouteUpdateRequestsFromBackend(routeId: routeId);
      pp('$mm RouteUpdateRequests from backend:: ${localList.length}');
      realm.write(() {
        realm.addAll<RouteUpdateRequest>(localList, update: true);
      });
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<CommuterRequest>> _getCommuterRequestsFromBackend(
      {required String url}) async {
    final list = <CommuterRequest>[];
    List resp = await _sendHttpGET(url);
    for (var value in resp) {
      var r = buildCommuterRequest(value);
      list.add(r);
    }

    pp('$mm CommuterRequests found: ${list.length}');
    return list;
  }

  Future<List<DispatchRecord>> _getDispatchRecordsFromBackend(
      {required String url}) async {
    final list = <DispatchRecord>[];
    List resp = await _sendHttpGET(url);
    for (var value in resp) {
      var r = buildDispatchRecord(value);
      list.add(r);
    }

    pp('$mm DispatchRecords found: ${list.length}');
    return list;
  }

  Future<List<VehicleArrival>> _getVehicleArrivalsFromBackend(
      {required String url}) async {
    final list = <VehicleArrival>[];
    List resp = await _sendHttpGET(url);
    for (var value in resp) {
      var r = buildVehicleArrival(value);
      list.add(r);
    }

    pp('$mm VehicleArrivals found: ${list.length}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>> _getPassengerCountsFromBackend(
      {required String url}) async {
    final list = <AmbassadorPassengerCount>[];
    List resp = await _sendHttpGET(url);
    for (var value in resp) {
      var r = buildAmbassadorPassengerCount(value);
      list.add(r);
    }

    pp('$mm AmbassadorPassengerCount found: ${list.length}');
    return list;
  }

  Future<List<VehiclePhoto>> _getVehiclePhotosFromBackend(
      {required String vehicleId}) async {
    final list = <VehiclePhoto>[];
    final cmd = '${url}getVehiclePhotos?vehicleId=$vehicleId';
    List resp = await _sendHttpGET(cmd);
    pp('$mm VehiclePhotos found: ${resp.length}');

    for (var value in resp) {
      var r = buildVehiclePhoto(value);
      list.add(r);
    }

    pp('$mm VehiclePhotos found: ${list.length}');
    return list;
  }

  Future<List<VehicleMediaRequest>> _getVehicleMediaRequestsFromBackend(
      {required String? associationId,
      required String? vehicleId,
      required String? startDate}) async {
    final list = <VehicleMediaRequest>[];
    var command = '';
    if (associationId != null) {
      command =
          '${url}getAssociationVehicleMediaRequests?associationId=$associationId&startDate=$startDate';
    }
    if (vehicleId != null) {
      command = '${url}getVehicleMediaRequests?vehicleId=$vehicleId';
    }
    List resp = await _sendHttpGET(command);
    for (var value in resp) {
      var r = buildVehicleMediaRequest(value);
      list.add(r);
    }

    pp('$mm RouteUpdateRequests found: ${list.length}');
    return list;
  }

  Future<List<RouteUpdateRequest>> _getRouteUpdateRequestsFromBackend(
      {required String routeId}) async {
    final list = <RouteUpdateRequest>[];
    final cmd = '${url}getRouteUpdateRequests?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildRouteUpdateRequest(value);
      list.add(r);
    }

    pp('$mm RouteUpdateRequests found: ${list.length}');
    return list;
  }

  Future<List<VehicleVideo>> _getVehicleVideosFromBackend(
      {required String vehicleId}) async {
    final list = <VehicleVideo>[];
    final cmd = '${url}getVehicleVideos?vehicleId=$vehicleId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildVehicleVideo(value);
      list.add(r);
    }

    pp('$mm VehicleVideos found: ${list.length}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>>
      _getVehicleAmbassadorPassengerCountsFromBackend(
          {required String vehicleId, required String startDate}) async {
    final list = <AmbassadorPassengerCount>[];
    final cmd =
        '${url}getVehicleAmbassadorPassengerCounts?vehicleId=$vehicleId&startDate=$startDate';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildAmbassadorPassengerCount(value);
      list.add(r);
    }

    pp('$mm vehicle AmbassadorPassengerCounts found: ${list.length}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>>
      _getUserAmbassadorPassengerCountsFromBackend(
          {required String userId, required String startDate}) async {
    final list = <AmbassadorPassengerCount>[];
    final cmd =
        '${url}getUserAmbassadorPassengerCounts?userId=$userId&startDate=$startDate';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = buildAmbassadorPassengerCount(value);
      list.add(r);
    }

    pp('$mm user AmbassadorPassengerCounts found: ${list.length}');
    return list;
  }

  Future<Route?> getRoute(String routeId) async {
    var localList = <Route>[];
    rm.RealmResults<Route> results =
        realm.query<Route>("routeId == \$0", [routeId]);
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
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
    pp('$mm CalculatedDistances from realm:: ${localList.length}');
    if (localList.isEmpty || refresh) {
      try {
        localList = await _getCalculatedDistancesFromBackend(routeId: routeId);
        pp('$mm CalculatedDistances from backend:: ${localList.length}');
        realm.write(() {
          realm.addAll<CalculatedDistance>(localList, update: true);
        });
      } catch (e) {
        pp(e);
      }
    }
    //

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

  Future<List<Route>> getRoutesFilteredByAssignments({required String associationId, required String vehicleId}) async {
    final assignments = await listApiDog.getVehicleRouteAssignments(
        vehicleId, false);

    pp('$mm ... getRoutesFilteredByAssignments found ${assignments.length} assignments');

    var hash = HashMap<String, String>();
    var routes = <Route>[];
    if (assignments.isNotEmpty) {
      for (var a in assignments) {
        hash[a.routeId!] = a.routeId!;
      }
      final list = hash.keys.toList();
      pp('$mm ... getRoutesFilteredByAssignments found ${list.length} route ids from route assignments');

      for (var routeId in list) {
        final route = await listApiDog.getRoute(routeId);
        if (route != null) {
          routes.add(route);
        }
      }
    }
    return routes;
  }
  Future<List<Route>> getRoutes(AssociationParameter param) async {
    final localList = <Route>[];
    rm.RealmResults<Route> results = realm.all<Route>();
    if (results.isNotEmpty) {
      for (var element in results) {
        localList.add(element);
      }
    }
    pp('$mm ...... Routes from realm:: ${localList.length}');

    if (param.refresh || localList.isEmpty) {
      final remoteList =
      await routesIsolate.getRoutes(param.associationId, param.refresh);
      pp('$mm ... Routes from backend:: ${remoteList.length}');
      _routeController.sink.add(remoteList);
      return remoteList;
    }

    return localList;
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
    pp('$mm .......... getAssociationRoutes; _getRoutesFromBackend: ... : ${p.associationId}');

    final cmd = '${url}getAssociationRoutes?associationId=${p.associationId}';
    var list = <Route>[];
    List resp = await _sendHttpGET(cmd);

    pp('$mm .......... raw payload: $list');
    for (var value in resp) {
      pp('$mm route from backend: ${value['name']}');
      var r = buildRoute(value);
      list.add(r);
    }

    pp('$mm ....... routes from backend : ${list.length}');
    try {
      realm.write(() {
        realm.addAll<Route>(list, update: true);
      });
    } catch (e) {
      pp('$mm ... REALM ERROR: ${E.redDot} $e');
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
    realm.write(() {
      realm.addAll<Route>(list, update: true);
    });

    pp('$mm findRoutesByLocation;  ${E.appleRed} routes found: ${list.length}');
    return list;
  }

  Future<List<Route>> findAssociationRoutesByLocation(
      LocationFinderParameter p) async {
    var list = <Route>[];

    final cmd =
        '${url}findAssociationRoutesByLocation?associationId=${p.associationId}'
        '&latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildRoute(value));
    }

    pp('$mm findAssociationRoutesByLocation;  ${E.appleRed} routes found: ${list.length}');
    myPrettyJsonPrint(list.first.toJson());
    return list;
  }

  Future<List<Route>> findAssociationRouteLandmarksByLocation(
      LocationFinderParameter p) async {
    var list = <Route>[];

    final cmd =
        '${url}findAssociationRouteLandmarksByLocation?associationId=${p.associationId}'
        '&latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildRoute(value));
    }

    pp('$mm findAssociationRouteLandmarksByLocation;  ${E.appleRed} found: ${list.length}');
    myPrettyJsonPrint(list.first.toJson());
    return list;
  }

  Future<List<RouteLandmark>> findRouteLandmarksByLocation(
      LocationFinderParameter p) async {
    var list = <RouteLandmark>[];

    final cmd = '${url}findRouteLandmarksByLocation?latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';
    //
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(buildRouteLandmark(value));
    }
    realm.write(() {
      realm.addAll<RouteLandmark>(list, update: true);
    });

    pp('$mm findRouteLandmarksByLocation;  ${E.appleRed} routeLandmarks found: ${list.length}');

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
    realm.write(() {
      realm.addAll<City>(list, update: true);
    });
    pp('$mm findCitiesByLocation;  ${E.appleRed} cities found: ${list.length}');

    return list;
  }

  Future<int> countCountryCities(String countryId, bool refresh) async {
    final list = <City>[];
    rm.RealmResults<City>? realmResults;
    realmResults = realm.query('countryId == \$0', [countryId]);
    final list1 = realmResults.toList();
    if (realmResults.toList().isEmpty || refresh) {
      pp('$mm country cities found in local Realm: ${list1.length}');
      return await countryCitiesIsolate.getCountryCities(countryId);
    }

    pp('$mm cached country cities: ${list1.length}');
    _cityController.sink.add(list);
    return list1.length;
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
    //todo - remove from mongo
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
      realm.addAll(list, update: true);
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
      realm.addAll(list, update: true);
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
    pp('$xz _sendHttpGET: 🔆 🔆 🔆 ...... calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('Token not found');
    }
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
        return resp.body;
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
      // pp("$xz ........ response body: ${resp.body}");
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
