import 'dart:async';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/route_bag.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:universal_io/io.dart';

import '../data/data_schemas.dart';
import '../data/route_data.dart';
import 'functions.dart';
import 'kasie_exception.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// final ZipHandler zipHandler = ZipHandler();

class ZipHandler {
  static const xz = '🍐🍐🍐🍐 ZipHandler : ';
  late SemCache semCache;

  Future<String> getCars(String associationId) async {
    pp('$xz getVehiclesZippedFile: 🔆🔆🔆 get zipped car data associationId: $associationId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getVehiclesZippedFile?associationId=$associationId';
    var start = DateTime.now();
    List<Vehicle> cars = [];

    http.Response response = await getUsingHttp(mUrl);
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

  Future<String> getOwnerCars(String userId) async {
    pp('$xz getOwnerCars: 🔆🔆🔆 get zipped owner car data userId: $userId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getOwnerVehiclesZippedFile?userId=$userId';
    var start = DateTime.now();
    List<Vehicle> cars = [];

    var token = await auth.FirebaseAuth.instance.currentUser!.getIdToken(true);
    Map<String, String> headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token'
    };

    http.Response response = await getUsingHttp(mUrl);
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
    List<City> mCities = await semCache.getCities();

    if (refresh || mCities.isEmpty) {
      var s = await getCitiesString(countryId);
      List json = jsonDecode(s);
      for (var value in json) {
        mCities.add(City.fromJson(value));
      }
      await semCache.saveCities(mCities);
    }

    return mCities;
  }

  Future<String> getCitiesString(String countryId) async {
    pp('$xz getCitiesString: 🔆🔆🔆 get zipped cities; countryId: $countryId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}country/getCountryCitiesZippedFile?countryId=$countryId';
    var start = DateTime.now();
    List<City> cities = [];

    try {
      http.Response response = await getUsingHttp(mUrl);
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

  Future<AssociationRouteData> getRouteData({required String associationId}) async {
    pp('$xz getRouteData: 🔆🔆🔆 zipped for associationId: $associationId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}routes/getAssociationRouteZippedFile?associationId'
        '=$associationId';

    var start = DateTime.now();

    try {
      semCache = GetIt.instance<SemCache>();
      http.Response response = await getUsingHttp(mUrl);
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
          AssociationRouteData routeData = AssociationRouteData.fromJson(mJson);
          //cache data locally
          routeData.associationId = associationId;
          await semCache.saveAssociationRouteData(routeData);

          pp('$xz getRoutes: 🍎🍎🍎🍎 RouteData has been filled and cached!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz getRoutes: 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎 return string ...\n\n');
          return routeData;
        }
      }
    } catch (e, stackTrace) {
      pp('$xz Error parsing JSON: $e');
      pp('$xz Stack trace: $stackTrace');
      throw Exception('$xz \nFailed to retrieve route data zipped file: $e');
    }
    throw Exception('Bad moon rising!');
  }

  Future<String> getRoutePoints({required String routeId}) async {
    pp('$xz getRoutePoints: 🔆🔆🔆 get zipped data; ... routeId: $routeId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}routes/getRoutePointsZipped?routeId'
        '=$routeId';



    http.Response response = await getUsingHttp(mUrl);
    final list = await _getPointsFromArchive(response);
    return jsonEncode(list);
  }

  Future<String> deleteRoutePoints(
      {required String routeId,
      required double latitude,
      required double longitude}) async {
    pp('$xz deleteRoutePoints: 🔆🔆🔆 response is zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}deleteRoutePoints?routeId'
        '=$routeId&latitude=$latitude&longitude=$longitude';


    http.Response response = await getUsingHttp(mUrl);
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

  Future<RouteBag?> refreshRoute({required String routeId}) async {
    pp('$xz refreshRoute: 🔆🔆🔆 get zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}refreshRoute?routeId'
        '=$routeId';

    var start = DateTime.now();


    http.Response response = await getUsingHttp(mUrl);

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
      String mUrl) async {
    pp('$xz httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    var token = await auth.FirebaseAuth.instance.currentUser!.getIdToken(true);
    Map<String, String> headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token'
    };

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
