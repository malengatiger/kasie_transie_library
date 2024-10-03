import 'dart:async';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/route_bag.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:universal_io/io.dart';

import '../data/data_schemas.dart';
import 'functions.dart';
import 'kasie_exception.dart';

// final ZipHandler zipHandler = ZipHandler();

class ZipHandler {
  static const xz = '🍐🍐🍐🍐 ZipHandler : ';
  final AppAuth appAuth;
  final SemCache semCache;

  ZipHandler(this.appAuth, this.semCache);

  Future<String> getCars(String associationId, String token) async {
    pp('$xz getVehiclesZippedFile: 🔆🔆🔆 get zipped car data associationId: $associationId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getVehiclesZippedFile?associationId=$associationId';
    var start = DateTime.now();
    List<Vehicle> cars = [];

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    pp('$xz getCars: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);

      pp('$xz getCars: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');
      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz getCars: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);
          for (var v in mJson) {
            cars.add(Vehicle.fromJson(v));
          }
          pp('$xz getCars 🍎🍎🍎🍎 list of ${cars.length} cars has been filled!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz getCars 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
        }
      }
    } catch (e, stack) {
      pp('$xz ... Error dealing with zipped file: $e : $stack');
      rethrow;
    }
    return jsonEncode(cars);
  }

  Future<String> getOwnerCars(String userId, String token) async {
    pp('$xz getOwnerCars: 🔆🔆🔆 get zipped owner car data userId: $userId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getOwnerVehiclesZippedFile?userId=$userId';
    var start = DateTime.now();
    List<Vehicle> cars = [];

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    pp('$xz getOwnerCars: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      pp('$xz getOwnerCars: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz getOwnerCars: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);
          for (var v in mJson) {
            cars.add(Vehicle.fromJson(v));
          }

          pp('$xz getOwnerCars 🍎🍎🍎🍎 list of ${cars.length} cars has been filled!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz getOwnerCars 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
        }
      }
    } catch (e, stack) {
      pp('$xz ... Error dealing with zipped file: $e : $stack');
      rethrow;
    }
    return jsonEncode(cars);
  }

  int count = 0;
  Future<List<City>> getCities(String countryId, bool refresh) async {
    pp('$xz ....... getCities: refresh: $refresh');
    List<City> mCities = [];
    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('No token');
    }
    if (refresh) {
      var s = await getCitiesString(countryId, token);
      List json = jsonDecode(s);
      for (var value in json) {
        mCities.add(City.fromJson(value));
      }
      await semCache.saveCities(mCities);
      return mCities;
    }
    var cities = await semCache.getCities();
    if (cities.isEmpty) {
      if (count == 0) {
        count++;
        cities = await getCities(countryId,true);
      }
    }
    count = 0;
    return cities;
  }

  Future<String> getCitiesString(String countryId, String token) async {
    pp('$xz getCitiesString: 🔆🔆🔆 get zipped cities; countryId: $countryId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}country/getCountryCitiesZippedFile?countryId=$countryId';
    var start = DateTime.now();
    List<City> cities = [];

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    try {
      http.Response response = await getUsingHttp(mUrl, token, headers);
      pp('$xz getCities: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      pp('$xz getCities: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);

          for (var v in mJson) {
            cities.add(City.fromJson(v));
          }

          pp('$xz getCities 🍎🍎🍎🍎 list of ${cities.length} cities has been filled!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz getCities 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
        }
      }
    } catch (e) {
      pp('$xz ... Error dealing with zipped file: $e');
      rethrow;
    }
    return jsonEncode(cities);
  }

  Future<List<Route>> getRoutes(
      {required String associationId, required bool refresh}) async {
    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('No auth token');
    }
    pp('$xz ... getRoutes starting ... refresh: $refresh');
    if (refresh) {
      var string =
          await getRouteDataString(associationId: associationId, token: token);
      var mJson = jsonDecode(string);
      var routeData = RouteData.fromJson(mJson);
      return routeData.routes;
    }
    var routes = await semCache.getRoutes(associationId);
    if (routes.isEmpty) {
      pp('$xz ... getRoutes 😈😈routes not found in Mongo ... count: $count');
      if (count == 0) {
        count++;
        routes = await getRoutes(associationId: associationId, refresh: true);
      }
    }
    count = 0;
    return routes;
  }

  Future<String> getRouteDataString(
      {required String associationId, required String token}) async {
    pp('$xz getRouteDataString: 🔆🔆🔆 get zipped route data; ... associationId: $associationId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}routes/getAssociationRouteZippedFile?associationId'
        '=$associationId';

    var start = DateTime.now();
    RouteData routeData =
        RouteData(routes: [], routePoints: [], landmarks: [], cities: []);

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    try {
      http.Response response = await getUsingHttp(mUrl, token, headers);
      pp('$xz getRouteDataString: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      List<Route> routes = [];
      List<RoutePoint> routePoints = [];
      List<RouteLandmark> landmarks = [];
      List<RouteCity> cities = [];
      for (final file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz _getRouteBag: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');

          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);

          List dRoutes = mJson['routes'];
          List dRoutePoints = mJson['points'];
          List dLandmarks = mJson['landmarks'];
          List dCities = mJson['cities'];

          for (var json in dRoutes) {
            routes.add(Route.fromJson(json));
          }
          pp('$xz getRouteDataString 🍎🍎 routes: ${routes.length}');
          for (var marks in dLandmarks) {
            marks.forEach((element) {
              landmarks.add(RouteLandmark.fromJson(element));
            });
          }
          pp('$xz getRouteDataString 🍎🍎 landmarks: ${landmarks.length}');

          for (var mPoints in dRoutePoints) {
            mPoints.forEach((element) {
              routePoints.add(RoutePoint.fromJson(element));
            });
          }
          pp('$xz getRouteDataString 🍎🍎 routePoints: ${routePoints.length}');
          for (var mCities in dCities) {
            mCities.forEach((element) {
              cities.add(RouteCity.fromJson(element));
            });
          }
          pp('$xz getRouteDataString 🍎🍎 cities: ${cities.length}');

          routeData = RouteData(
              routes: routes,
              routePoints: routePoints,
              landmarks: landmarks,
              cities: cities);

          //cache data locally
          await semCache.saveRoutes(routes);
          await semCache.saveRoutePoints(routePoints);
          await semCache.saveRouteCities(cities);
          await semCache.saveRouteLandmarks(landmarks);

          pp('$xz getRouteDataString 🍎🍎🍎🍎 RouteData has been filled and cached!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz getRouteDataString 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎 return string ...\n\n');
          return jsonEncode(routeData.toJson());
        }
      }
    } catch (e, stackTrace) {
      pp('Error parsing JSON: $e');
      pp('Stack trace: $stackTrace');
      rethrow;
    }
    throw Exception('Bad moon rising!');
  }

  Future<String> getRoutePoints(
      {required String routeId, required String token}) async {
    pp('$xz getRoutePoints: 🔆🔆🔆 get zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}getRoutePointsZipped?routeId'
        '=$routeId';

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    final list = await _getPointsFromArchive(response);
    return jsonEncode(list);
  }

  Future<String> deleteRoutePoints(
      {required String routeId,
      required double latitude,
      required double longitude,
      required String token}) async {
    pp('$xz deleteRoutePoints: 🔆🔆🔆 response is zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}deleteRoutePoints?routeId'
        '=$routeId&latitude=$latitude&longitude=$longitude';

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    http.Response response = await getUsingHttp(mUrl, token, headers);
    final points = await _getPointsFromArchive(response);
    return jsonEncode(points);
  }

  Future<List<RoutePoint>> _getPointsFromArchive(http.Response response) async {
    pp('$xz _getPointsFromArchive: 🔆🔆🔆 get zipped data, response contentLength: ${response.contentLength} bytes ...');

    var start = DateTime.now();
    List<RoutePoint> routePoints = [];
    try {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      pp('$xz getCities: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);
          for (var element in mJson) {
            routePoints.add(RoutePoint.fromJson(element));
          }
          pp('$xz _getPointsFromArchive 🍎🍎🍎🍎 ${routePoints.length} route points built!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz _getPointsFromArchive 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
        }
      }
    } catch (e, stackTrace) {
      pp('Error parsing JSON: $e');
      pp('Stack trace: $stackTrace');
      rethrow;
    }
    return routePoints;
  }

  Future<RouteBag?> refreshRoute(
      {required String routeId, required String token}) async {
    pp('$xz refreshRoute: 🔆🔆🔆 get zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}refreshRoute?routeId'
        '=$routeId';

    var start = DateTime.now();

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);

    pp('$xz refreshRoute: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');
    RouteBag? bag;
    try {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      pp('$xz getCities: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final content = utf8.decode(file.content as List<int>);
          final mJson = json.decode(content);
          bag = RouteBag.fromJson(mJson);
          pp('$xz refreshRoute 🍎🍎🍎🍎 route bag has been filled and cached!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz refreshRoute 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          return bag;
        }
      }
    } catch (e, stackTrace) {
      pp('Error parsing JSON: $e');
      pp('Stack trace: $stackTrace');
      rethrow;
    }
    return bag;
  }

  Future<http.Response> getUsingHttp(
      String mUrl, String token, Map<String, String> headers) async {
    pp('$xz httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();

    try {
      final http.Client client = http.Client();
      var resp = await client
          .get(
            Uri.parse(mUrl),
            headers: headers,
          )
          .timeout(const Duration(seconds: 120));
      pp('$xz httpGet call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
      var end = DateTime.now();
      pp('$xz httpGet call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

      if (resp.statusCode == 403) {
        var msg =
            '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
        pp(msg);
        final gex = KasieException(
            message: 'Forbidden call',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        //errorHandler.handleError(exception: gex);
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
        ////errorHandler.handleError(exception: gex);
        throw gex;
      }
      return resp;
    } on SocketException {
      pp('$xz SocketException, really means that server cannot be reached 😑');
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
      // //errorHandler.handleError(exception: gex);
      throw gex;
    } on HttpException {
      pp("$xz HttpException occurred 😱");
      final gex = KasieException(
          message: 'Server not available',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.httpException);
      // //errorHandler.handleError(exception: gex);
      throw gex;
    } on FormatException {
      pp("$xz Bad response format 👎");
      final gex = KasieException(
          message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.formatException);
      // //errorHandler.handleError(exception: gex);
      throw gex;
    } on TimeoutException {
      pp("$xz No Internet connection. Request has timed out in 120 seconds 👎");
      final gex = KasieException(
          message: 'No Internet connection. Request timed out',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      // //errorHandler.handleError(exception: gex);
      throw gex;
    }
  }
}
