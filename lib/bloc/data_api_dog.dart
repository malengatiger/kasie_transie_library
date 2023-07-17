import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';

import '../data/calculated_distance_list.dart';
import '../data/route_point_list.dart';
import '../data/schemas.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/parsers.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

final http.Client client = http.Client();
final DataApiDog dataApiDog =
    DataApiDog(client, appAuth, cacheManager, prefs, errorHandler);

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
  static const timeOutInSeconds = 120;

  final http.Client client;
  final AppAuth appAuth;
  final CacheManager cacheManager;
  final Prefs prefsOGx;
  final ErrorHandler errorHandler;

  DataApiDog(this.client, this.appAuth, this.cacheManager, this.prefsOGx,
      this.errorHandler) {
    if (KasieEnvironment.currentStatus == 'dev') {
      url = KasieEnvironment.devUrl;
    } else {
      url = KasieEnvironment.prodUrl;
    }
  }

  Future<LocationRequest> addLocationRequest(LocationRequest request) async {
    final bag = request.toJson();
    final cmd = '${url}addLocationRequest';
    final res = await _callPost(cmd, bag);
    final lr = buildLocationRequest(res);
    pp('$mm LocationRequest added to database: $res');
    return lr;
  }

  Future <LocationResponse>addLocationResponse(LocationResponse response) async {
    final bag = response.toJson();
    final cmd = '${url}addLocationResponse';
    final res = await _callPost(cmd, bag);
    pp('$mm LocationResponse added to database: $res');
    final lr = buildLocationResponse(res);
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
      final r = buildDispatchRecord(res);
      listApiDog.realm.write(() {
        listApiDog.realm.add<DispatchRecord>(r, update: true);
      });
      pp('$mm DispatchRecord added to database: $res');
      myPrettyJsonPrint(res);
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
    pp('$mm VehicleArrival added to database: $res');
  }

  Future addVehicleDeparture(VehicleDeparture event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleDeparture';
    final res = await _callPost(cmd, bag);
    pp('$mm VehicleDeparture added to database: $res');
  }

  Future addVehicleHeartbeat(VehicleHeartbeat event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleHeartbeat';
    final res = await _callPost(cmd, bag);
    pp('$mm .......... VehicleHeartbeat added to database: $res');
  }

  Future sendRouteUpdateMessage(String associationId, String routeId) async {
    final cmd =
        '${url}sendRouteUpdateMessage?associationId=$associationId&routeId=$routeId';
    final res = await _sendHttpGET(cmd);
    pp('$mm .......... Route Update Message sent: $res, response 0 means GOOD!');
  }

  Future<Landmark> addLandmark(Landmark landmark) async {
    pp('$mm landmark to BE added to database ...');
    final bag = landmark.toJson();
    final cmd = '${url}addBasicLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm landmark added to database ...');
    myPrettyJsonPrint(res);
    final m = buildLandmark(res);
    return m;
  }

  Future addRoutePoints(RoutePointList routePointList) async {
    pp('$mm ... adding routePoints to database ...');

    final pointsJson = routePointList.toJson();

    final cmd = '${url}addRoutePoints';
    var res = await _callPost(cmd, pointsJson);
    pp('$mm routePoints added to database: $res');
    return res as int;
  }

  Future<List<CalculatedDistance>> addCalculatedDistances(
      CalculatedDistanceList calculatedDistanceList) async {
    pp('$mm ... adding CalculatedDistances to database ...');

    final pointsJson = calculatedDistanceList.toJson();

    final cmd = '${url}addCalculatedDistances';
    List res = await _callPost(cmd, pointsJson);
    pp('$mm CalculatedDistances added to database: ${res.length}');
    final items = <CalculatedDistance>[];
    for (var cd in res) {
      items.add(buildCalculatedDistance(cd));
    }
    listApiDog.realm.write(() {
      listApiDog.realm.addAll<CalculatedDistance>(items);
    });
    pp('$mm calc distances cached: ${items.length}');
    return items;
  }

  Future<Route> addRoute(Route route) async {
    final bag = route.toJson();
    final cmd = '${url}addRoute';
    final res = await _callPost(cmd, bag);
    pp('$mm route added to database ...');
    myPrettyJsonPrint(res);
    final r = buildRoute(res);
    listApiDog.getRoutes(AssociationParameter(route.associationId!, true));
    return r;
  }

  Future<User> updateUser(User user) async {
    pp('$mm .................................'
        'user to be updated on mongo database ${E.redDot} check that user is passed ...');

    myPrettyJsonPrint(user.toJson());
    final cmd = '${url}updateUser';
    final res = await _callPost(cmd, user.toJson());
    pp('$mm user updated on mongo database ... ${E.redDot} check if password present');
    myPrettyJsonPrint(res);
    final r = buildUser(res);
    return r;
  }

  Future<City> addCity(City city) async {
    final bag = city.toJson();
    final cmd = '${url}addCity';
    final res = await _callPost(cmd, bag);
    pp('$mm City added to database ...');
    myPrettyJsonPrint(res);
    final r = buildCity(res);
    listApiDog.realm.write(() {
      listApiDog.realm.add<City>(r);
      pp('$mm new city cached in Realm ... ${r.name}');
    });

    return r;
  }

  Future<Route> updateRouteColor(
      {required String routeId, required String color}) async {
    final cmd = '${url}updateRouteColor?routeId=$routeId&color=$color';
    var res = await _sendHttpGET(cmd);
    final route = buildRoute(res);
    listApiDog.realm.write(() {
      listApiDog.realm.add<Route>(route, update: true);
    });
    pp('$mm route with updated color cached ... ${route.name} - color: ${route.color}');
    myPrettyJsonPrint(route.toJson());
    return route;
  }

  void addRouteLandmarkToStream(RouteLandmark route) async {
    _routeLandmarkController.sink.add(route);
  }

  Future<RouteLandmark> addRouteLandmark(RouteLandmark route) async {
    final bag = route.toJson();
    final cmd = '${url}addRouteLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm RouteLandmark added to database ...');
    myPrettyJsonPrint(res);
    final r = buildRouteLandmark(res);
    _routeLandmarkController.sink.add(r);
    return r;
  }

  Future<List<RouteLandmark>> updateAssociationRouteLandmarks(String associationId) async {
    final cmd = '${url}updateAssociationRouteLandmarks?associationId=$associationId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(buildRouteLandmark(mJson));
    }
    listApiDog.realm.write(() {
      listApiDog.realm.addAll(list, update: true);
    });

    pp('$mm Association RouteLandmarks: ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<List<RouteLandmark>> updateRouteLandmarks(String routeId) async {
    final cmd = '${url}updateRouteLandmarks?routeId=$routeId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(buildRouteLandmark(mJson));
    }
    listApiDog.realm.write(() {
      listApiDog.realm.addAll(list, update: true);
    });
    pp('$mm Route Landmarks ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<RouteCity> addRouteCity(RouteCity routeCity) async {
    final bag = routeCity.toJson();
    final cmd = '${url}addRouteCity';
    try {
      final res = await _callPost(cmd, bag);
      pp('$mm RouteCity added to database ...');
      myPrettyJsonPrint(res);
      final r = buildRouteCity(res);
      return r;
    } catch (e) {
      pp('$mm error writing route city, probable dup key error; ignoring!');

      return routeCity;
    }
  }

  Future deleteRoutePoint(String routePointId) async {
    final cmd = '${url}deleteRoutePoint?routePointId=$routePointId';
    final res = await _sendHttpGET(cmd);
    pp('$mm deleteRoutePoint happened ...');

    try {
      listApiDog.removeRoutePoint(routePointId);
      pp('$mm deleteRoutePoint for Realm happened ...');
    } catch (e) {
      pp(e);
    }

    return res;
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
    pp('$mm association registration added to database: $res');
  }

  Future<SettingsModel> addSettings(SettingsModel settings) async {
    final bag = settings.toJson();
    final cmd = '${url}addSettingsModel';

    final res = await _callPost(cmd, bag);
    final r = buildSettingsModel(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<SettingsModel>(r);
    });
    pp('$mm settings added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehiclePhoto> addVehiclePhoto(VehiclePhoto vehiclePhoto) async {
    final bag = vehiclePhoto.toJson();
    final cmd = '${url}addVehiclePhoto';

    final res = await _callPost(cmd, bag);
    final r = buildVehiclePhoto(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<VehiclePhoto>(r, update: true);
    });
    pp('$mm VehiclePhoto added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }
  Future<VehicleMediaRequest> addVehicleMediaRequest(VehicleMediaRequest vehicleMediaRequest) async {
    final bag = vehicleMediaRequest.toJson();
    final cmd = '${url}addVehicleMediaRequest';

    final res = await _callPost(cmd, bag);
    final r = buildVehicleMediaRequest(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<VehicleMediaRequest>(r, update: true);
    });
    pp('$mm VehicleMediaRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<RouteUpdateRequest> addRouteUpdateRequest (RouteUpdateRequest routeUpdateRequest) async {
    final bag = routeUpdateRequest.toJson();
    final cmd = '${url}addRouteUpdateRequest';

    final res = await _callPost(cmd, bag);
    final r = buildRouteUpdateRequest(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<RouteUpdateRequest>(r, update: true);
    });
    pp('$mm RouteUpdateRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehicleVideo> addVehicleVideo(VehicleVideo vehicleVideo) async {
    final bag = vehicleVideo.toJson();
    final cmd = '${url}addVehicleVideo';

    final res = await _callPost(cmd, bag);
    final r = buildVehicleVideo(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<VehicleVideo>(r, update: true);
    });
    pp('$mm vehicleVideo added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<AmbassadorCheckIn> addAmbassadorCheckIn(AmbassadorCheckIn checkIn) async {
    final bag = checkIn.toJson();
    final cmd = '${url}addAmbassadorCheckIn';

    final res = await _callPost(cmd, bag);
    final r = buildAmbassadorCheckIn(res);

    listApiDog.realm.write(() {
      listApiDog.realm.add<AmbassadorCheckIn>(r, update: true);
    });
    pp('$mm AmbassadorCheckIn added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }
  Future<AmbassadorPassengerCount> addAmbassadorPassengerCount(AmbassadorPassengerCount count) async {
    final bag = count.toJson();
    final cmd = '${url}addAmbassadorPassengerCount';

    try {
      final res = await _callPost(cmd, bag);
      final r = buildAmbassadorPassengerCount(res);
      listApiDog.realm.write(() {
            listApiDog.realm.add<AmbassadorPassengerCount>(r, update: true);
          });
      pp('$mm AmbassadorPassengerCount added to database ...');
      myPrettyJsonPrint(res);
      return r;

    } catch (e) {
      pp(e);
      cacheManager.saveAmbassadorPassengerCount(count);
    }
    return count;
  }




  Future _callPost(String mUrl, Map? bag) async {
    String? mBag;
    if (bag != null) {
      mBag = json.encode(bag);
    }
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('No fucking token!');
    }
    headers['Authorization'] = 'Bearer $token';
    pp('$mm body of request: $mBag');
    try {
      var resp = await client
          .post(
            Uri.parse(mUrl),
            body: mBag,
            headers: headers,
          )
          .timeout(const Duration(seconds: timeOutInSeconds));
      if (resp.statusCode == 200) {
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
    } on SocketException {
      pp('$mm  SocketException: really means that server cannot be reached 😑');
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on HttpException {
      pp("$mm  HttpException occurred 😱");
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.httpException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on FormatException {
      pp("$mm  Bad response format 👎");
      final gex = KasieException(
          message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.formatException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on TimeoutException {
      pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
      final gex = KasieException(
          message: 'Request timed out. No Internet connection',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
  }

  Future _sendHttpGET(String mUrl) async {
    pp('$mm _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
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
      //throw gex;
    }
    headers['Authorization'] = 'Bearer $token';
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
    } on SocketException {
      pp('$mm SocketException, really means that server cannot be reached 😑');
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on HttpException {
      pp("$mm HttpException occurred 😱");
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.httpException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on FormatException {
      pp("$mm Bad response format 👎");
      final gex = KasieException(
          message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.formatException);
      errorHandler.handleError(exception: gex);
      throw gex;
    } on TimeoutException {
      pp("$mm No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
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
