import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/data/vehicle_list.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';

import '../data/calculated_distance_list.dart';
import '../data/data_schemas.dart';
import '../data/generation_request.dart';
import '../data/route_assignment_list.dart';
import '../data/route_point_list.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

class DataApiDog {
  static const mm = '🌎🌎🌎🌎🌎🌎 DataApiDog: 🌎🌎';

  final StreamController<RouteLandmark> _routeLandmarkController =
      StreamController.broadcast();

  Stream<RouteLandmark> get routeLandmarkStream =>
      _routeLandmarkController.stream;

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> zipHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/zip',
  };

  late String url;
  static const timeOutInSeconds = 360;

  final http.Client client;
  final AppAuth appAuth;
  final CacheManager cacheManager;
  final Prefs prefs;
  final ErrorHandler errorHandler;

  DataApiDog(this.client, this.appAuth, this.cacheManager, this.prefs,
      this.errorHandler) {
    url = KasieEnvironment.getUrl();
  }

  Future<List<RouteAssignment>> addRouteAssignments(
      RouteAssignmentList assignments) async {
    final bag = assignments.toJson();
    final cmd = '${url}addRouteAssignments';
    List res = await _callPost(cmd, bag);
    var list = <RouteAssignment>[];
    for (var value in res) {
      final lr = RouteAssignment.fromJson(value);
      list.add(lr);
    }

    pp('$mm RouteAssignments added to database and cached on realm: ${list.length}');
    return list;
  }

  Future<CommuterRequest> addCommuterRequest(CommuterRequest request) async {
    final bag = request.toJson();
    final cmd = '${url}addCommuterRequest';
    final res = await _callPost(cmd, bag);
    final lr = CommuterRequest.fromJson(res);

    pp('$mm CommuterRequest added to database: $res');
    return lr;
  }

  Future<LocationRequest> addLocationRequest(LocationRequest request) async {
    final bag = request.toJson();
    final cmd = '${url}addLocationRequest';
    final res = await _callPost(cmd, bag);
    final lr = LocationRequest.fromJson(res);
    pp('$mm LocationRequest added to database: $res');
    return lr;
  }

  Future<LocationResponse> addLocationResponse(
      LocationResponse response) async {
    final bag = response.toJson();
    final cmd = '${url}addLocationResponse';
    final res = await _callPost(cmd, bag);
    pp('$mm LocationResponse added to database: $res');
    final lr = LocationResponse.fromJson(res);
    return lr;
  }

  Future addVehicle(Vehicle vehicle) async {
    final bag = vehicle.toJson();
    final cmd = '${url}addVehicle';
    final res = await _callPost(cmd, bag);
    pp('$mm vehicle added to database: $res');
  }

  Future addUserGeofenceEvent(UserGeofenceEvent event) async {
    final bag = event.toJson();
    final cmd = '${url}addUserGeofenceEvent';
    final res = await _callPost(cmd, bag);
    pp('$mm UserGeofenceEvent added to database: $res');
  }

  Future addDispatchRecord(DispatchRecord dispatchRecord) async {
    try {
      final bag = dispatchRecord.toJson();
      final cmd = '${url}addDispatchRecord';
      final res = await _callPost(cmd, bag);
      final r = DispatchRecord.fromJson(res);

      pp('$mm DispatchRecord added to database');
      return r;
    } catch (e) {
      await cacheManager.saveDispatchRecord(dispatchRecord);
      pp(e);
    }
  }

  Future addVehicleArrival(VehicleArrival event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleArrival';
    final res = await _callPost(cmd, bag);
    pp('$mm VehicleArrival added to database');
  }

  Future addVehicleDeparture(VehicleDeparture event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleDeparture';
    final res = await _callPost(cmd, bag);
    pp('$mm VehicleDeparture added to database');
  }

  Future addVehicleHeartbeat(VehicleHeartbeat event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleHeartbeat';
    final res = await _callPost(cmd, bag);
    pp('$mm .......... VehicleHeartbeat added to database');
  }

  Future sendRouteUpdateMessage(RouteUpdateRequest req) async {
    final cmd = '${url}addRouteUpdateRequest';
    final res = await _callPost(cmd, req.toJson());
    pp('$mm .......... Route Update Message sent: $res, response 0 means GOOD!');
  }

  Future<Landmark> addLandmark(Landmark landmark) async {
    pp('$mm landmark to BE added to database ...');
    final bag = landmark.toJson();
    final cmd = '${url}addBasicLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm landmark added to database ...');
    myPrettyJsonPrint(res);
    final m = Landmark.fromJson(res);
    return m;
  }

  Future addRoutePoints(RoutePointList routePointList) async {
    pp('$mm ... adding routePoints to database ...${routePointList.routePoints.length}');
    final cmd = '${url}routes/addRoutePoints';
    var res = await _callPost(cmd, routePointList.toJson());
    pp('$mm routePoints added to database: $res');
    return res as int;
  }

  Future<List<CalculatedDistance>> addCalculatedDistances(
      CalculatedDistanceList calculatedDistanceList) async {
    pp('$mm ... adding CalculatedDistances to database ...');

    final cmd = '${url}addCalculatedDistances';
    List res = await _callPost(cmd, calculatedDistanceList.toJson());
    pp('$mm CalculatedDistances added to database: ${res.length}');
    final items = <CalculatedDistance>[];
    for (var cd in res) {
      items.add(CalculatedDistance.fromJson(cd));
    }

    pp('$mm calc distances cached: ${items.length}');
    return items;
  }

  Future<Route> addRoute(Route route) async {
    final bag = route.toJson();
    final cmd = '${url}routes/addRoute';
    final res = await _callPost(cmd, bag);
    pp('$mm route added to database ...');
    myPrettyJsonPrint(res);
    final r = Route.fromJson(res);
    return r;
  }

  Future addAppError(AppError error) async {
    final bag = error.toJson();
    final cmd = '${url}addAppError';
    final res = await _callPost(cmd, bag);
    pp('$mm AppError added to database ...');
    myPrettyJsonPrint(res);

    return 0;
  }

  Future addAppErrors(AppErrors errors) async {
    final bag = errors.toJson();
    final cmd = '${url}addAppErrors';
    List res = await _callPost(cmd, bag);
    pp('$mm AppErrors added to database ... ${res.length} errors');

    return 0;
  }

  Future<Commuter> addCommuter(Commuter commuter) async {
    final bag = commuter.toJson();
    final cmd = '${url}addCommuter';
    final res = await _callPost(cmd, bag);
    pp('$mm Commuter added to database ...');
    myPrettyJsonPrint(res);

    final r = Commuter.fromJson(res);
    prefs.saveCommuter(r);
    return r;
  }

  Future<User> updateUser(User user) async {
    pp('$mm .................................'
        'user to be updated on mongo database ${E.redDot} '
        'check that user is passed ...');

    myPrettyJsonPrint(user.toJson());
    final cmd = '${url}updateUser';
    final res = await _callPost(cmd, user.toJson());
    pp('$mm user updated on mongo database ... ${E.redDot} '
        'check if password present');
    myPrettyJsonPrint(res);
    final r = User.fromJson(res);

    return r;
  }

  Future<Vehicle> updateVehicle(Vehicle car) async {
    pp('$mm .................................'
        'car to be updated on mongo database ${E.redDot} '
        'check that car is passed ...');
    myPrettyJsonPrint(car.toJson());

    final cmd = '${url}updateVehicle';
    final res = await _callPost(cmd, car.toJson());
    pp('$mm car updated on mongo database ... ${E.redDot} '
        'check if owner fields present');
    myPrettyJsonPrint(res);
    final r = Vehicle.fromJson(res);

    return r;
  }

  Future<City> addCity(City city) async {
    final bag = city.toJson();
    final cmd = '${url}addCity';
    final res = await _callPost(cmd, bag);
    pp('$mm City added to database ...');
    myPrettyJsonPrint(res);
    final r = City.fromJson(res);

    return r;
  }

  Future<Route> updateRouteColor(
      {required String routeId, required String color}) async {
    final cmd = '${url}routes/updateRouteColor?routeId=$routeId&color=$color';
    var res = await _sendHttpGET(cmd);
    final route = Route.fromJson(res);

    pp('$mm route with updated color cached ... ${route.name} - color: ${route.color}');
    myPrettyJsonPrint(route.toJson());
    return route;
  }

  void addRouteLandmarkToStream(RouteLandmark route) async {
    _routeLandmarkController.sink.add(route);
  }

  Future<RouteLandmark> addRouteLandmark(RouteLandmark route) async {
    final bag = route.toJson();
    final cmd = '${url}routes/addRouteLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm RouteLandmark added to database ...');
    myPrettyJsonPrint(res);
    final r = RouteLandmark.fromJson(res);
    _routeLandmarkController.sink.add(r);
    return r;
  }

  Future<List<RouteLandmark>> updateAssociationRouteLandmarks(
      String associationId) async {
    final cmd =
        '${url}updateAssociationRouteLandmarks?associationId=$associationId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(RouteLandmark.fromJson(mJson));
    }

    pp('$mm Association RouteLandmarks: ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<List<RouteLandmark>> updateRouteLandmarks(String routeId) async {
    final cmd = '${url}updateRouteLandmarks?routeId=$routeId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(RouteLandmark.fromJson(mJson));
    }

    pp('$mm Route Landmarks ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<RouteCity> addRouteCity(RouteCity routeCity) async {
    final bag = routeCity.toJson();
    final cmd = '${url}routes/addRouteCity';
    try {
      final res = await _callPost(cmd, bag);
      pp('$mm RouteCity added to database ...');
      myPrettyJsonPrint(res);
      final r = RouteCity.fromJson(res);
      return r;
    } catch (e) {
      pp('$mm error writing route city, probable dup key error; ignoring!');

      return routeCity;
    }
  }

  Future deleteRoutePoint(String routePointId) async {
    final cmd = '${url}routes/deleteRoutePoint?routePointId=$routePointId';
    final res = await _sendHttpGET(cmd);
    pp('$mm deleteRoutePoint happened ...');

    return res;
  }

  Future<List<RoutePoint>> deleteRoutePointsFromIndex(
      String routeId, int index) async {
    final cmd =
        '${url}routes/deleteRoutePointsFromIndex?routeId=$routeId&index=$index';
    List res = await _sendHttpGET(cmd);
    pp('$mm deleteRoutePointsFromIndex happened ... returned ');
    List<RoutePoint> routePoints = [];

    routePoints.clear();
    for (var value in res) {
      routePoints.add(RoutePoint.fromJson(value));
    }

    return routePoints;
  }

  Future deleteLandmark(String landmarkId) async {
    final cmd = '${url}deleteLandmark?landmarkId=$landmarkId';
    final res = await _sendHttpGET(cmd);
    pp('$mm deleteLandmark happened ...');

    try {
      //listApiDog.removeRoutePoint(routePointId);
      pp('$mm deleteRoutePoint for Realm happened ...');
    } catch (e) {
      pp(e);
    }

    return res;
  }

  Future registerAssociation(Association association) async {
    final bag = association.toJson();
    final cmd = '${url}registerAssociation';

    final res = await _callPost(cmd, bag);
    RegistrationBag rBag = RegistrationBag.fromJson(res);
    prefs.saveAssociation(rBag.association!);
    prefs.saveUser(rBag.user!);

    var cred = await appAuth.firebaseAuth?.signInWithEmailAndPassword(
        email: rBag.user!.email!, password: rBag.user!.password!);

    pp('$mm administrator authed;! 🍎${cred.toString()}');
    pp('$mm association registered! added to cache: 🍎${rBag.association!.toJson()}');
    pp('$mm administrator registered! added to cache: 🍎${rBag.user!.toJson()}');
  }

  Future<SettingsModel> addSettings(SettingsModel settings) async {
    final bag = settings.toJson();
    final cmd = '${url}addSettingsModel';

    final res = await _callPost(cmd, bag);
    final r = SettingsModel.fromJson(res);

    pp('$mm settings added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehiclePhoto> addVehiclePhoto(VehiclePhoto vehiclePhoto) async {
    final bag = vehiclePhoto.toJson();
    final cmd = '${url}addVehiclePhoto';

    final res = await _callPost(cmd, bag);
    final r = VehiclePhoto.fromJson(res);

    pp('$mm VehiclePhoto added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehicleMediaRequest> addVehicleMediaRequest(
      VehicleMediaRequest vehicleMediaRequest) async {
    final bag = vehicleMediaRequest.toJson();
    final cmd = '${url}addVehicleMediaRequest';

    final res = await _callPost(cmd, bag);
    final r = VehicleMediaRequest.fromJson(res);
    pp('$mm VehicleMediaRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<RouteUpdateRequest> addRouteUpdateRequest(
      RouteUpdateRequest routeUpdateRequest) async {
    final bag = routeUpdateRequest.toJson();
    final cmd = '${url}addRouteUpdateRequest';

    final res = await _callPost(cmd, bag);
    final r = RouteUpdateRequest.fromJson(res);

    pp('$mm RouteUpdateRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehicleVideo> addVehicleVideo(VehicleVideo vehicleVideo) async {
    final bag = vehicleVideo.toJson();
    final cmd = '${url}addVehicleVideo';

    final res = await _callPost(cmd, bag);
    final r = VehicleVideo.fromJson(res);
    pp('$mm vehicleVideo added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<AmbassadorCheckIn> addAmbassadorCheckIn(
      AmbassadorCheckIn checkIn) async {
    final bag = checkIn.toJson();
    final cmd = '${url}addAmbassadorCheckIn';

    final res = await _callPost(cmd, bag);
    final r = AmbassadorCheckIn.fromJson(res);

    pp('$mm AmbassadorCheckIn added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<AmbassadorPassengerCount> addAmbassadorPassengerCount(
      AmbassadorPassengerCount count) async {
    final bag = count.toJson();
    final cmd = '${url}addAmbassadorPassengerCount';

    try {
      final res = await _callPost(cmd, bag);
      final r = AmbassadorPassengerCount.fromJson(res);
      pp('$mm AmbassadorPassengerCount added to database ...');
      myPrettyJsonPrint(res);
      return r;
    } catch (e) {
      pp(e);
      cacheManager.saveAmbassadorPassengerCount(count);
    }
    return count;
  }

//
  Future<List<DispatchRecord>> generateDispatchRecords(
      String associationId, int numberOfCars, int intervalInSeconds) async {
    final cmd = '${url}generateDispatchRecords?associationId=$associationId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <DispatchRecord>[];
    for (var mJson in res) {
      list.add(DispatchRecord.fromJson(mJson));
    }

    pp('$mm DispatchRecords: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

//
  Future generateRouteDispatchRecords(GenerationRequest request) async {
    final cmd = '${url}generateRouteDispatchRecords';
    final res = await _callPost(cmd, request.toJson());

    pp('\n\n$mm generateRouteDispatchRecords: Demo Vehicles: ${request.vehicleIds.length}  $res ${E.leaf}${E.leaf}');

    return res;
  }

  //
  Future<List<Vehicle>> generateRouteDispatchRecordsForCars(
      {required VehicleList vehicleList}) async {
    final cmd = '${url}generateRouteDispatchRecordsForCars';
    List res = await _callPost(cmd, vehicleList.toJson());
    var list = <Vehicle>[];
    for (var value in res) {
      list.add(Vehicle.fromJson(value));
    }
    pp('\n\n$mm generateRouteDispatchRecordsForCars sent: cars: ${list.length}  ${E.leaf}${E.leaf}');

    return list;
  }

//
  Future<List<CommuterRequest>> generateCommuterRequests(String associationId,
      int numberOfCommuters, int intervalInSeconds) async {
    final cmd = '${url}generateCommuterRequests?associationId=$associationId'
        '&numberOfCommuters=$numberOfCommuters&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <CommuterRequest>[];
    for (var mJson in res) {
      list.add(CommuterRequest.fromJson(mJson));
    }

    pp('$mm CommuterRequests: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future generateRouteCommuterRequests(String routeId) async {
    final cmd = '${url}generateRouteCommuterRequests?routeId=$routeId';
    final res = await _sendHttpGET(cmd);
    pp('$mm CommuterRequests: $res ${E.leaf}${E.leaf}');
    return res;
  }

  Future<List<AmbassadorPassengerCount>> generateAmbassadorPassengerCounts(
      String associationId, int numberOfCars, int intervalInSeconds) async {
    final cmd =
        '${url}generateAmbassadorPassengerCounts?associationId=$associationId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <AmbassadorPassengerCount>[];
    for (var mJson in res) {
      list.add(AmbassadorPassengerCount.fromJson(mJson));
    }

    pp('$mm AmbassadorPassengerCounts: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>> generateRoutePassengerCounts(
      String routeId, int numberOfCars, int intervalInSeconds) async {
    final cmd = '${url}generateRoutePassengerCounts?routeId=$routeId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <AmbassadorPassengerCount>[];
    for (var mJson in res) {
      list.add(AmbassadorPassengerCount.fromJson(mJson));
    }
    pp('$mm AmbassadorPassengerCounts: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future generateRouteHeartbeats(GenerationRequest request) async {
    final cmd = '${url}generateRouteHeartbeats';
    final bag = request.toJson();
    final res = await _callPost(cmd, bag);

    pp('$mm VehicleHeartbeats: $res  ${E.leaf}${E.leaf}');
    return res;
  }

  Future _callPost(String mUrl, dynamic bag) async {
    String? mBag;
    mBag = json.encode(bag);
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('No fucking token!');
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .post(
              Uri.parse(mUrl),
              body: mBag,
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          pp('$mm  _callWebAPIPost RESPONSE: 💙💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
        } else {
          pp('$mm  👿👿👿_callWebAPIPost: 🔆 statusCode: 👿👿👿 ${resp.statusCode} 🔆🔆🔆 for $mUrl');
          pp(resp.body);
          throw KasieException(
              message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
              url: mUrl,
              translationKey: 'serverProblem',
              errorType: KasieException.socketException);
        }
        var end = DateTime.now();
        pp('$mm  _callWebAPIPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
        try {
          var mJson = json.decode(resp.body);
          return mJson;
        } catch (e) {
          pp("$mm 👿👿👿👿👿👿👿 json.decode failed, returning response body");
          return resp.body;
        }
      } on SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }

  Future _sendHttpGET(String mUrl) async {
    pp('$mm _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var token = await appAuth.getAuthToken();
    if (token != null) {
      // pp('$mm _sendHttpGET: 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 ');
    } else {
      pp('$mm Firebase token missing ${E.redDot}${E.redDot}${E.redDot}${E.redDot}');
      final gex = KasieException(
          message: 'Firebase Authentication token missing',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .get(
              Uri.parse(mUrl),
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        pp('$mm http GET call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
        var end = DateTime.now();
        pp('$mm http GET call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

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
      } on SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }
}
