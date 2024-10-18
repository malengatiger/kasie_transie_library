import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/counter_bag.dart';
import 'package:kasie_transie_library/data/vehicle_bag.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:kasie_transie_library/utils/route_distance_calculator.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';

import '../data/big_bag.dart';
import '../data/data_schemas.dart';
import '../data/route_bag.dart';
import '../isolates/local_finder.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

class ListApiDog {
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ ListApiDog: ❤️: ';
  final ZipHandler zipHandler;
  final SemCache semCache;

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> zipHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/zip',
  };

  late String url, databaseString;
  static const timeOutInSeconds = 300;

  final http.Client client;
  final AppAuth appAuth;
  final Prefs prefs;
  final ErrorHandler errorHandler;
  bool initialized = false;
  String? token;

  ListApiDog(
    this.client,
    this.appAuth,
    this.prefs,
    this.errorHandler,
    this.zipHandler,
    this.semCache,
  ) {
    url = KasieEnvironment.getUrl();
    databaseString = KasieEnvironment.getUrl();
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
    return token;
  }

  Future<User?> getUserById(String userId) async {
    final cmd = '${url}user/getUserById?userId=$userId';
    try {
      final resp = await _sendHttpGET(cmd);
      pp('$mm getUserById: ........ response: $resp');
      if (resp is String) {
        if (resp.contains('not found')) {
          throw Exception('User not found');
        }
      }
      final user = User.fromJson(resp);

      pp('$mm getUserById found this user: ${user.name} ');
      myPrettyJsonPrint(resp);
      return user;
    } catch (e, s) {
      pp('$e $s');
      throw Exception('User fucked: $e');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final cmd = '${url}getUserByEmail?email=$email';
    try {
      final resp = await _sendHttpGET(cmd);
      final user = User.fromJson(resp);

      pp('$mm getUserByEmail found this user: ${user.name} ');
      myPrettyJsonPrint(resp);
      return user;
    } catch (e) {
      pp(e);
      rethrow;
    }
  }

  Future<Association?> getAssociationById(String associationId) async {
    final cmd =
        '${url}association/getAssociationById?associationId=$associationId';
    try {
      final resp = await _sendHttpGET(cmd);
      final ass = Association.fromJson(resp);
      pp('$mm getAssociationById found: ${ass.associationName} ');
      myPrettyJsonPrint(resp);
      return ass;
    } catch (e) {
      pp(e);
      return null;
    }
  }

  Country? getCountryById(String countryId) {
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

    final cmd = '${url}getCountryStates?countryId=$countryId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      mList.add(StateProvince.fromJson(value));
    }

    return mList;
  }

  Future<List<SettingsModel>> getSettings(
      String associationId, bool refresh) async {
    List<SettingsModel> list1 = [];
    if (refresh) {
      final cmd = '${url}getAssociationSettings?associationId=$associationId';
      List resp = await _sendHttpGET(cmd);
      list1.clear();
      for (var value in resp) {
        list1.add(SettingsModel.fromJson(value));
      }
    }
    pp('$mm cached settings: ${list1.length}');
    return list1;
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    return null;
  }

  final StreamController<List<Vehicle>> _vehiclesStreamController =
      StreamController.broadcast();

  Stream<List<Vehicle>> get vehiclesStream => _vehiclesStreamController.stream;

  Future<List<Vehicle>> getOwnerVehicles(String userId, bool refresh) async {
    final list = <Vehicle>[];
    // if (refresh) {
    //   var vehicleIsolate = GetIt.instance<SemCache>();
    //   final nList = await vehicleIsolate.get(userId);
    //   _vehiclesStreamController.sink.add(nList);
    //   return nList;
    // }

    return list;
  }

  Future<List<DispatchRecord>> getMarshalDispatchRecords(
      {required String userId,
      required bool refresh,
      required int days}) async {
    final list = <DispatchRecord>[];
    if (refresh) {
      return await getMarshalDispatchesFromBackend(userId, days);
    }

    return list;
  }

  Future<List<RouteAssignment>> getVehicleRouteAssignments(
      String vehicleId, bool refresh) async {
    final list = <RouteAssignment>[];

    return await getVehicleRouteAssignmentsFromBackend(vehicleId);
  }

  Future<List<RouteAssignment>> getRouteAssignments(
      String routeId, bool refresh) async {
    final list = <RouteAssignment>[];
    return await getRouteAssignmentsFromBackend(routeId);
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
      list.add(RouteCity.fromJson(mJson));
    }
    await semCache.saveRouteCities(list);
    return list;
  }

  Future<List<RouteLandmark>> getAssociationRouteLandmarks(
      String associationId, bool refresh) async {
    var landmarks = <RouteLandmark>[];
    var list = <RouteLandmark>[];

    final cmd =
        '${url}routes/getAssociationRouteLandmarks?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    list.clear();
    for (var mJson in resp) {
      list.add(RouteLandmark.fromJson(mJson));
    }
    await semCache.saveRouteLandmarks(list, associationId);
    return list;
  }

  Future<List<RoutePoint>> getAssociationRoutePoints(
      String associationId) async {
    return [];
  }

  Future<int> countAssociationRoutePoints() async {
    return 0;
  }

  Future<List<Vehicle>> getAssociationCars(
      String associationId, bool refresh) async {
    var cachedList = await semCache.getVehicles(associationId);
    if (refresh || cachedList.isEmpty) {
      final cmd =
          '${url}association/getAssociationVehicles?associationId=$associationId';
      List resp = await _sendHttpGET(cmd);
      var list = <Vehicle>[];
      for (var vehicleJson in resp) {
        list.add(Vehicle.fromJson(vehicleJson));
      }
      pp('$mm ... cars found on Atlas: ${list.length}');
      await semCache.saveVehicles(list);
      return list;
    } else {
      pp('$mm ... cars found on sembast cache: ${cachedList.length}');
      return cachedList;
    }
  }

  Future<List<Vehicle>> getCarsFromBackend(String associationId) async {
    final cmd =
        '${url}association/getAssociationVehicles?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    var list = <Vehicle>[];
    for (var vehicleJson in resp) {
      list.add(Vehicle.fromJson(vehicleJson));
    }
    pp('$mm ... cars found: ${list.length}');
    await semCache.saveVehicles(list);
    return list;
  }

  Future<List<Vehicle>> getOwnerCarsFromBackend(String userId) async {
    final cmd = '${url}vehicle/getOwnerVehicles?userId=$userId';

    List resp = await _sendHttpGET(cmd);
    var list = <Vehicle>[];
    for (var vehicleJson in resp) {
      list.add(Vehicle.fromJson(vehicleJson));
    }

    return list;
  }

  Future<List<RouteAssignment>> getVehicleRouteAssignmentsFromBackend(
      String vehicleId) async {
    final cmd = '${url}vehicle/getVehicleRouteAssignments?vehicleId=$vehicleId';

    List resp = await _sendHttpGET(cmd);
    var list = <RouteAssignment>[];
    for (var json in resp) {
      list.add(RouteAssignment.fromJson(json));
    }
    return list;
  }

  Future<List<RouteAssignment>> getRouteAssignmentsFromBackend(
      String routeId) async {
    final cmd = '${url}getRouteAssignments?routeId=$routeId';

    List resp = await _sendHttpGET(cmd);
    var list = <RouteAssignment>[];
    for (var json in resp) {
      list.add(RouteAssignment.fromJson(json));
    }

    pp('$mm cached routeAssignments from backend: ${list.length}');
    return list;
  }

  Future<List<DispatchRecord>> getMarshalDispatchesFromBackend(
      String userId, int days) async {
    final startDate = DateTime.now().toUtc().subtract(Duration(days: days));
    final cmd =
        '${url}getMarshalDispatchRecords?marshalId=$userId&startDate=$startDate';
    List resp = await _sendHttpGET(cmd);
    var list = <DispatchRecord>[];
    for (var vehicleJson in resp) {
      list.add(DispatchRecord.fromJson(vehicleJson));
    }

    pp('$mm cached marshal dispatches from backend: ${list.length}');
    return list;
  }

  Future<List<Association>> getAssociations(bool refresh) async {
    final cmd = '${url}association/getAssociations';
    List<Association> list = await semCache.getAssociations();;
    if (refresh || list.isEmpty) {
      List resp = await _sendHttpGET(cmd);
      list.clear();
      for (var m in resp) {
        list.add(Association.fromJson(m));
      }

      pp('$mm associations from atlas: ${list.length} - refresh: $refresh');
      await semCache.saveAssociations(list);
      return list;
    }

    pp('$mm associations from cache: ${list.length} - refresh: $refresh');
    return list;
  }

  final StreamController<List<RoutePoint>> _routePointController =
      StreamController.broadcast();

  Stream<List<RoutePoint>> get routePointStream => _routePointController.stream;

  List<RoutePoint> getPointsFromRealm(String routeId) {
    pp('$mm getting cached routePoints from realm ...');
    return [];
  }

  final StreamController<List<Route>> _routeController =
      StreamController.broadcast();

  Stream<List<Route>> get routeStream => _routeController.stream;

  void putRouteInStream(List<Route> routes) {
    _routeController.sink.add(routes);
  }

  final StreamController<List<City>> _cityController =
      StreamController.broadcast();

  Stream<List<City>> get cityStream => _cityController.stream;

  Future<List<RouteLandmark>> getRouteLandmarks(
      String routeId, bool refresh, String associationId) async {
    List<RouteLandmark> localList =
        await semCache.getRouteLandmarks(routeId, associationId);

    try {
      if (refresh || localList.isEmpty) {
        localList = await _getRouteLandmarksFromBackend(routeId: routeId);
        pp('$mm RouteLandmarks from backend:: ${localList.length}');
      }
    } catch (e) {
      pp(e);
    }

    //

    return localList;
  }

  Future<List<RoutePoint>> getRoutePoints(
      String routeId, bool refresh, String associationId) async {
    List<RoutePoint> localList =
        await semCache.getRoutePoints(routeId, associationId);

    if (localList.isEmpty || refresh) {
      try {
        final token = await appAuth.getAuthToken();
        final s = await zipHandler.getRoutePoints(routeId: routeId);
        List m = jsonDecode(s);
        for (var r in m) {
          localList.add(RoutePoint.fromJson(r));
        }
        pp('$mm RoutePoints from backend via zip: ${localList.length}');
      } catch (e) {
        pp(e);
        rethrow;
      }
    }
    //

    return localList;
  }

  Future getAllPhotosAndVideos({Association? association}) async {
    association ?? prefs.getAssociation();
    if (association == null) {
      pp('$mm Association is null ... quitting!');
      return;
    }
    List<Vehicle> cars = await getCarsFromBackend(association.associationId!);
    pp('$mm getAllPhotosAndVideos: ... cars: ${cars.length} from association: ${association.associationName}');
    var totalPhotos = 0;
    var totalVideos = 0;
    for (var car in cars) {
      var listP = await _getVehiclePhotosFromBackend(vehicleId: car.vehicleId!);
      var listV = await _getVehicleVideosFromBackend(vehicleId: car.vehicleId!);
      car.photos = listP;
      car.videos = listV;

      totalPhotos += listP.length;
      totalVideos += listV.length;

      await semCache.saveVehicles([car]);
    }

    pp('$mm getAllPhotosAndVideos completed: ${cars.length} cars and totalPhotos: $totalPhotos and totalVideos: $totalVideos');
  }

  Future getVehicleMedia(Vehicle car, bool refresh) async {
    var listP = await _getVehiclePhotosFromBackend(vehicleId: car.vehicleId!);
    var listV = await _getVehicleVideosFromBackend(vehicleId: car.vehicleId!);
    car.photos = listP;
    car.videos = listV;
    pp('$mm car media found for ${car.vehicleReg} photos: ${listP.length} videos: ${listV.length}');
  }

  Future<List<VehiclePhoto>> getVehiclePhotos(
      Vehicle vehicle, bool refresh) async {
    var localList = <VehiclePhoto>[];
    //
    try {
      localList =
          await _getVehiclePhotosFromBackend(vehicleId: vehicle.vehicleId!);
      pp('$mm VehiclePhotos from backend: vehicleId: ${vehicle.vehicleReg} found: ${localList.length} photos');
      vehicle.photos = localList;
      await semCache.saveVehicles([vehicle]);
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleVideo>> getVehicleVideos(
      Vehicle vehicle, bool refresh) async {
    var localList = <VehicleVideo>[];
    //
    try {
      localList =
          await _getVehicleVideosFromBackend(vehicleId: vehicle.vehicleId!);
      pp('$mm VehicleVideos from backend: vehicleId: ${vehicle.vehicleReg} found: ${localList.length} photos');
      vehicle.videos = localList;
      await semCache.saveVehicles([vehicle]);
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

    //
    try {
      localList = await _getVehicleAmbassadorPassengerCountsFromBackend(
          vehicleId: vehicleId, startDate: startDate);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
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

    try {
      localList = await _getUserAmbassadorPassengerCountsFromBackend(
          userId: userId, startDate: startDate);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationCommuterRequests?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getCommuterRequestsFromBackend(url: url);
      pp('$mm CommuterRequests from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationDispatchRecords?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getDispatchRecordsFromBackend(url: url);
      pp('$mm DispatchRecord from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationAmbassadorPassengerCounts?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getPassengerCountsFromBackend(url: url);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getRoutePassengerCounts?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getPassengerCountsFromBackend(url: url);
      pp('$mm AmbassadorPassengerCounts from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getAssociationVehicleArrivals?associationId=$associationId'
          '&startDate=$startDate';
      localList = await _getVehicleArrivalsFromBackend(url: url);
      pp('$mm VehicleArrivals from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteVehicleArrivals?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getVehicleArrivalsFromBackend(url: url);
      pp('$mm VehicleArrivals from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteDispatchRecords?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getDispatchRecordsFromBackend(url: url);
      pp('$mm DispatchRecord from backend:: ${localList.length}');
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

    try {
      final url =
          '${KasieEnvironment.getUrl()}getRouteCommuterRequests?routeId=$routeId'
          '&startDate=$startDate';
      localList = await _getCommuterRequestsFromBackend(url: url);
      pp('$mm CommuterRequests from backend:: ${localList.length}');
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleMediaRequest>> getVehicleMediaRequests(
      String vehicleId, bool refresh) async {
    var localList = <VehicleMediaRequest>[];

    try {
      localList = await _getVehicleMediaRequestsFromBackend(
          vehicleId: vehicleId, associationId: null, startDate: null);
      pp('$mm VehicleMediaRequests from backend:: ${localList.length}');
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<VehicleMediaRequest>> getAssociationVehicleMediaRequests(
      String associationId, String startDate, bool refresh) async {
    var localList = <VehicleMediaRequest>[];

    try {
      localList = await _getVehicleMediaRequestsFromBackend(
          vehicleId: null, associationId: associationId, startDate: startDate);
      pp('$mm VehicleMediaRequests from backend, caching to realm: ${localList.length}');
    } catch (e) {
      pp(e);
    }
    return localList;
  }

  Future<List<RouteUpdateRequest>> getRouteUpdateRequests(
      String routeId, bool refresh) async {
    var localList = <RouteUpdateRequest>[];

    try {
      localList = await _getRouteUpdateRequestsFromBackend(routeId: routeId);
      pp('$mm RouteUpdateRequests from backend:: ${localList.length}');
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
      var r = CommuterRequest.fromJson(value);
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
      var r = DispatchRecord.fromJson(value);
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
      var r = VehicleArrival.fromJson(value);
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
      var r = AmbassadorPassengerCount.fromJson(value);
      list.add(r);
    }

    pp('$mm AmbassadorPassengerCount found: ${list.length}');
    return list;
  }

  Future<List<VehiclePhoto>> _getVehiclePhotosFromBackend(
      {required String vehicleId}) async {
    final list = <VehiclePhoto>[];
    final cmd = '${url}vehicle/getVehiclePhotos?vehicleId=$vehicleId';
    List resp = await _sendHttpGET(cmd);
    pp('$mm VehiclePhotos found: ${resp.length}');

    for (var value in resp) {
      var r = VehiclePhoto.fromJson(value);
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
      var r = VehicleMediaRequest.fromJson(value);
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
      var r = RouteUpdateRequest.fromJson(value);
      list.add(r);
    }

    pp('$mm RouteUpdateRequests found: ${list.length}');
    return list;
  }

  Future<List<VehicleVideo>> _getVehicleVideosFromBackend(
      {required String vehicleId}) async {
    final list = <VehicleVideo>[];
    final cmd = '${url}vehicle/getVehicleVideos?vehicleId=$vehicleId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = VehicleVideo.fromJson(value);
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
      var r = AmbassadorPassengerCount.fromJson(value);
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
      var r = AmbassadorPassengerCount.fromJson(value);
      list.add(r);
    }

    pp('$mm user AmbassadorPassengerCounts found: ${list.length}');
    return list;
  }

  Future<Route?> getRoute(String routeId) async {
    var localList = <Route>[];

    return null;
  }

  Future<List<CalculatedDistance>> getCalculatedDistances(
      String routeId, String associationId, bool refresh) async {
    pp('$mm .................. getCalculatedDistances refresh: $refresh');
    RouteDistanceCalculator routeDistanceCalculator =
        GetIt.instance<RouteDistanceCalculator>();

    var localList = <CalculatedDistance>[];

    try {
      localList = await _getCalculatedDistancesFromBackend(routeId: routeId);
      pp('$mm CalculatedDistances from backend:: ${localList.length}');

      pp('$mm CalculatedDistances cached in realm:: ${localList.length}');
    } catch (e, stack) {
      pp('$mm $e - $stack');
    }

    if (localList.isEmpty) {
      localList = await routeDistanceCalculator.calculateRouteDistances(
          routeId, associationId);
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

    pp('\n$mm ... route has been refreshed!\n');
    return bag;
  }

  Future<List<Route>> getRoutesFilteredByAssignments(
      {required String associationId, required String vehicleId}) async {
    final assignments = await getVehicleRouteAssignments(vehicleId, false);

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
        final route = await getRoute(routeId);
        if (route != null) {
          routes.add(route);
        }
      }
    }
    return routes;
  }

  Future<List<Route>> getAssociationRoutes(
      String associationId, bool refresh) async {
    final list = <Route>[];
    final cmd =
        '${url}routes/getAssociationRoutes?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = Route.fromJson(value);
      list.add(r);
    }

    pp('$mm Routes found: ${list.length}');
    return list;
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
      var r = Landmark.fromJson(value);
      list.add(r);
    }

    pp('$mm Landmarks found by location search: ${list.length}');
    return list;
  }

  Future<List<CalculatedDistance>> _getCalculatedDistancesFromBackend(
      {required String routeId}) async {
    pp('$mm .................. _getCalculatedDistancesFromBackend; routeId: $routeId');

    final list = <CalculatedDistance>[];
    final cmd = '${url}routes/getCalculatedDistances?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = CalculatedDistance.fromJson(value);
      list.add(r);
    }

    pp('$mm Route CalculatedDistances found: ${list.length}');
    return list;
  }

  Future<List<RouteLandmark>> _getRouteLandmarksFromBackend(
      {required String routeId}) async {
    final list = <RouteLandmark>[];
    final cmd = '${url}routes/getRouteLandmarks?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      var r = RouteLandmark.fromJson(value);
      list.add(r);
    }

    pp('$mm Route Landmarks found: ${list.length}');
    return list;
  }

  Future<List<Route>> findRoutesByLocation(LocationFinderParameter p) async {
    var list = <Route>[];
    final user = prefs.getUser();

    final cmd = '${url}findRoutesByLocation?latitude=${p.latitude}'
        '&longitude=${p.longitude}&radiusInKM=${p.radiusInKM}';

    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(Route.fromJson(value));
    }

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
      list.add(Route.fromJson(value));
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
      list.add(Route.fromJson(value));
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
      list.add(RouteLandmark.fromJson(value));
    }

    pp('$mm findRouteLandmarksByLocation;  ${E.appleRed} routeLandmarks found: ${list.length}');

    return list;
  }

  Future<List<City>> findCitiesByLocation(LocationFinderParameter p) async {
    var list = <City>[];
    pp('$mm findCitiesByLocation: 🍎🍎lat: ${p.latitude} lng: ${p.longitude} 🍎🍎 radiusInKM: ${p.radiusInKM} 🍎🍎associationId: ${p.associationId}');
    final cmd = '${url}city/findCitiesByLocation?latitude=${p.latitude}'
        '&longitude=${p.longitude}&maxDistanceInMetres=${p.radiusInKM}&limit=${p.limit}';

    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(City.fromJson(value));
    }

    pp('$mm findCitiesByLocation;  ${E.appleRed} cities found: ${list.length}');

    return list;
  }

  Future<int> countCountryCities(String countryId) async {
    var semCache = GetIt.instance<SemCache>();
    final list = await semCache.getCities();
    return list.length;
  }

  Future removeRoutePoint(String routePointId) async {
    //todo - remove from mongo
  }

  Future<List<User>> getAssociationUsers(
      String associationId, bool refresh) async {
    var list = <User>[];
    await _getUsersFromBackEnd(associationId, list);
    // await semCache.saveUsers(list);
    return list;
  }

  Future<List<User>> _getUsersFromBackEnd(
      String associationId, List<User> list) async {
    final cmd =
        '${url}association/getAssociationUsers?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    for (var value in resp) {
      list.add(User.fromJson(value));
    }

    return list;
  }

  Future<List<Commuter>> getRandomCommuters(int limit) async {
    final cmd = '${url}getRandomCommuters?limit=$limit';
    List resp = await _sendHttpGET(cmd);
    final list = <Commuter>[];
    for (var value in resp) {
      list.add(Commuter.fromJson(value));
    }
    pp('\n\n$mm random commuters found: '
        '${list.length} \n');
    return list;
  }

  Future<List<Country>> getCountries() async {
    final cmd = '${url}country/getCountries';
    List resp = await _sendHttpGET(cmd);
    final list = <Country>[];
    for (var value in resp) {
      list.add(Country.fromJson(value));
    }

    return list;
  }

  Future ping() async {
    var result = await _sendHttpGET('${url}ping');
    pp('$mm result of ping: $result');
  }

  static const xz = '🌎🌎🌎🌎🌎🌎 ListApiDog: ';

  Future _sendHttpGET(String mUrl) async {
    pp('$xz _sendHttpGET: 🔆 🔆 🔆 ...... calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    token ??= await getAuthToken();
    if (token == null) {
      throw Exception('Firebase auth token is null');
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
        throw Exception('The request is forbidden, sorry!');
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
        throw Exception('The status is BAD, Boss!');
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
      throw Exception('Server cannot be reached');
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
      pp("$xz ............ Bad response format 👎");
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
