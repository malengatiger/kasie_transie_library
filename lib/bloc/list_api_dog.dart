import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart' as rm;

import '../data/schemas.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

late ListApiDog listApiDog;

class ListApiDog {
  static const mm = '❤️❤️❤️ ListApiDog: ❤️: ';
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
      final p = await prefs.getUser();
      return true;
    } catch (e) {
      pp('$mm ${E.redDot}${E.redDot}${E.redDot}${E.redDot} Problem initializing Realm: $e');
    }
    return false;
  }

  Future<User> getUserById(String userId) async {
    final cmd = '${url}getUserById?userId=$userId';
    final resp = await _sendHttpGET(cmd);
    final user = buildUser(resp);
    realm.write(() {
      realm.add(user);
    });
    pp('$mm cached user: ${user.name}');

    return user;
  }

  Future<Association> getAssociationById(String associationId) async {
    final cmd = '${url}getAssociationById?associationId=$associationId';
    final resp = await _sendHttpGET(cmd);
    final ass = _buildAssociation(resp);
    realm.write(() {
      realm.add(ass);
    });
    pp('$mm cached association: ${ass.associationName}');

    return ass;
  }

  Association _buildAssociation(Map map) {
    List<int> bytes = utf8.encode(map['id']);

    final m = Association(rm.ObjectId.fromBytes(bytes),
      userId: map['userId'],
      countryId: map['countryId'],
      countryName: map['countryName'],
      cityId: map['cityId'],
      associationId: map['associationId'],
      associationName: map['associationName'],
      status: map['status'],
      adminCellphone: map['adminCellphone'],
      adminEmail: map['adminEmail'],
      adminUserFirstName: map['adminUserFirstName'],
      adminUserLastName: map['adminUserLastName'],
      cityName: map['cityName'],
      date: map['date'],
      dateRegistered: map['dateRegistered'],
    );
    return m;
  }

  Future<List<SettingsModel>> getSettings(String associationId) async {
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

  Future<List<Vehicle>> getAssociationVehicles(String associationId) async {
    final cmd = '${url}getAssociationVehicles?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    final list = <Vehicle>[];
    for (var vehicleJson in resp) {
      List<int> bytes = utf8.encode(vehicleJson['id']);
      list.add(Vehicle(rm.ObjectId.fromBytes( bytes),
        vehicleId: vehicleJson['vehicleId'],
        vehicleReg: vehicleJson['vehicleReg'],
        associationId: vehicleJson['associationId'],
        associationName: vehicleJson['associationName'],
        created: vehicleJson['created'],
        make: vehicleJson['make'],
        model: vehicleJson['model'],
        year: vehicleJson['year'],
        countryId: vehicleJson['countryId'],
        dateInstalled: vehicleJson['dateInstalled'],
        ownerId: vehicleJson['ownerId'],
        ownerName: vehicleJson['ownerName'],
      ));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached vehicles: ${list.length}');
    return list;
  }
  final StreamController<List<RoutePoint>> _routePointController = StreamController.broadcast();
  Stream<List<RoutePoint>> get routePointStream => _routePointController.stream;
  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    final cmd = '${url}getRoutePoints?routeId=$routeId';
    List resp = await _sendHttpGET(cmd);
    final list = <RoutePoint>[];
    for (var value in resp) {
      List<int> bytes = utf8.encode(value['id']);

      list.add(RoutePoint(rm.ObjectId.fromBytes(bytes),
        longitude: value['longitude'],
        routeId: value['routeId'],
        index: value['index'],
        latitude: value['userId'],
        created: value['created'],
        heading: value['heading'],
        landmarkId: value['landmarkId'],
        landmarkName: value['landmarkName'],
        position: Position(
          type: 'Point',
          latitude: value['position']['latitude'],
          longitude: value['position']['longitude'],
          coordinates: [value['position']['longitude'], value['position']['latitude'],],
        ),

      ));
    }
    realm.write(() {
      realm.addAll(list);
    });
    _routePointController.sink.add(list);
    pp('$mm cached routePoints: ${list.length}');
    return list;
  }

  final StreamController<List<Route>> _routeController = StreamController.broadcast();
  Stream<List<Route>> get routeStream => _routeController.stream;
  Future<List<Route>> getRoutes(String associationId) async {
    final cmd = '${url}getAssociationRoutes?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    final list = <Route>[];
    for (var value in resp) {
      List<int> bytes = utf8.encode(value['id']);

      list.add(Route(rm.ObjectId.fromBytes(bytes),
        countryId: value['countryId'],
        routeId: value['routeId'],
        associationId: value['countryId'],
        userId: value['userId'],
        created: value['created'],
        heading: value['heading'],
        name: value['name'],
        userName: value['userName'],
        userUrl: value['userUrl'],
        countryName: value['countryName'],
        color: value['color'],
        activationDate: value['activationDate'],
        associationName: value['associationName'],
        calculatedDistances: value['calculatedDistances'],
        landmarkIds: value['landmarkIds'],
        lengthInMetres: value['lengthInMetres'],
        routeNumber: value['routeNumber'],
      ));
    }
    realm.write(() {
      realm.addAll(list);
    });
    _routeController.sink.add(list);
    pp('$mm cached settings: ${list.length}');
    return list;
  }

  Future<List<City>> findCitiesByLocation(
      {required double latitude,
      required double longitude,
      required double radiusInKM}) async {
    final cmd =
        '${url}findCitiesByLocation?latitude=$latitude&longitude=$longitude&radiusInKM=$radiusInKM';
    List resp = await _sendHttpGET(cmd);
    final list = <City>[];
    for (var value in resp) {
      list.add(_buildCity(value));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached cities: ${list.length}');

    return list;
  }

  City _buildCity(Map map) {
    List<int> bytes = utf8.encode(map['id']);

    final m = City(rm.ObjectId.fromBytes(bytes),
      cityId: map['cityId'],
      name: map['name'],
      countryName: map['countryName'],
      countryId: map['countryId'],
      stateName: map['stateName'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      position: Position(
          type: 'Point',
          latitude: map['position']['latitude'],
          longitude: map['position']['longitude'],
          coordinates: [
            map['position']['longitude'],
            map['position']['latitude']
          ]),
      distance: map['distance'],
    );
    return m;
  }

  Future<List<City>> getCountryCities(String countryId) async {
    final cmd = '${url}getCountryCities?countryId=$countryId';
    List resp = await _sendHttpGET(cmd);
    final list = <City>[];
    for (var value in resp) {
      List<int> bytes = utf8.encode(value['id']);

      list.add(City(rm.ObjectId.fromBytes(bytes),
        countryId: value['countryId'],
        name: value['name'],
        stateName: value['stateName'],
        cityId: value['cityId'],
        countryName: value['countryName'],
        position: Position(
          type: 'Point',
          latitude:  value['position']['latitude'],
          longitude:  value['position']['longitude'],
          coordinates: [value['position']['longitude'], value['position']['latitude']]
        ),
      ));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached countries: ${list.length}');
    return list;
  }
  Future<List<User>> getAssociationUsers(String associationId) async {
    final cmd = '${url}getAssociationUsers?associationId=$associationId';
    List resp = await _sendHttpGET(cmd);
    final list = <User>[];
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
    final cmd = '${url}getCountries';
    List resp = await _sendHttpGET(cmd);
    final list = <Country>[];
    for (var value in resp) {
      List<int> bytes = utf8.encode(value['id']);

      list.add(Country(rm.ObjectId.fromBytes(bytes),
        countryId: value['countryId'],
        name: value['name'],
      ));
    }
    realm.write(() {
      realm.addAll(list);
    });
    pp('$mm cached countries: ${list.length}');
    return list;
  }

  Future ping() async {
    var result = await _sendHttpGET('${url}ping');
    pp('$mm result of ping: $result');
  }

  Future _callWebAPIPost(String mUrl, Map? bag) async {
    // pp('$xz http POST call: 🔆 🔆 🔆  calling : 💙  $mUrl  💙 ');

    String? mBag;
    if (bag != null) {
      mBag = json.encode(bag);
    }
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();

    headers['Authorization'] = 'Bearer $token';
    try {
      var resp = await client
          .post(
            Uri.parse(mUrl),
            body: mBag,
            headers: headers,
          )
          .timeout(const Duration(seconds: timeOutInSeconds));
      if (resp.statusCode == 200) {
        pp('$xz _callWebAPIPost RESPONSE: 💙💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
      } else {
        pp('👿👿👿_callWebAPIPost: 🔆 statusCode: 👿👿👿 ${resp.statusCode} 🔆🔆🔆 for $mUrl');
        pp(resp.body);
        throw KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
      }
      var end = DateTime.now();
      pp('$xz _callWebAPIPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
      try {
        var mJson = json.decode(resp.body);
        return mJson;
      } catch (e) {
        pp("👿👿👿👿👿👿👿 json.decode failed, returning response body");
        return resp.body;
      }
    } on SocketException {
      pp('$xz SocketException: really means that server cannot be reached 😑');
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
          message: 'Request timed out. No Internet connection',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
  }

  static const xz = '🌎🌎🌎🌎🌎🌎 ListApiDog: ';

  Future _sendHttpGET(String mUrl) async {
    pp('$xz _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();
    if (token != null) {
      // pp('$xz _sendHttpGET: 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 ');
    } else {
      pp('$xz Firebase token missing ${E.redDot}${E.redDot}${E.redDot}${E.redDot}');
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

User buildUser(Map map) {
  List<int> bytes = utf8.encode(map['id']);

  final m = User(rm.ObjectId.fromBytes(bytes),
    userId: map['userId'],
    firstName: map['firstName'],
    lastName: map['lastName'],
    countryId: map['countryId'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    imageUrl: map['imageUrl'],
    thumbnailUrl: map['thumbnailUrl'],
    userType: map['userType'],
    email: map['email'],
    cellphone: map['cellphone'],
    gender: map['gender'],
    fcmToken: map['fcmToken'],
  );
  return m;
}
SettingsModel buildSettingsModel(Map map) {
  List<int> bytes = utf8.encode(map['id']);

  final m = SettingsModel(rm.ObjectId.fromBytes(bytes),
  associationId: map['associationId'],
  locale: map['locale'],
  refreshRateInSeconds: map['refreshRateInSeconds'],
  themeIndex: map['themeIndex'],
  distanceFilter: map['distanceFilter'],
  created: map['created'],
  commuterGeofenceRadius: map['commuterGeofenceRadius'],
  commuterGeoQueryRadius: map['commuterGeoQueryRadius'],
  commuterSearchMinutes: map['commuterSearchMinutes'],
  geofenceRadius: map['geofenceRadius'],
  heartbeatIntervalSeconds: map['heartbeatIntervalSeconds'],
  loiteringDelay: map['loiteringDelay'],
  numberOfLandmarksToScan: map['numberOfLandmarksToScan'],
  vehicleGeoQueryRadius: map['vehicleGeoQueryRadius'],
  vehicleSearchMinutes: map['vehicleSearchMinutes'],
);
return m;
}
