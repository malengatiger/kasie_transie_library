import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/route_bag.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:path_provider/path_provider.dart';

import 'emojis.dart';
import 'functions.dart';
import 'kasie_exception.dart';

final ZipHandler zipHandler = ZipHandler();

class ZipHandler {
  static const xz = '🍐🍐🍐🍐 ZipHandler : ';

  Future<List<Vehicle>> getCars(String associationId, String token) async {
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
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz getCars: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz getCars: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz getCars: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz getCars: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            List mJson = json.decode(m);
            //mjson has multiple cars
            for (var v in mJson) {
              cars.add(buildVehicle(v));
            }
            await cacheCars(cars);
            pp('$xz getCars 🍎🍎🍎🍎 list of ${cars.length} cars has been filled!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz getCars 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          } else {
            pp('$xz ERROR: could not find file. ${E.redDot}');
          }
        }
      }
    } catch (e, stack) {
      pp('$xz ... Error dealing with zipped file: $e : $stack');
      rethrow;
    }
    return cars;
  }

  Future<List<Vehicle>> getOwnerCars(String userId, String token) async {
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
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz getCars: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz getCars: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz getCars: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz getCars: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            List mJson = json.decode(m);
            //mjson has multiple cars
            for (var v in mJson) {
              cars.add(buildVehicle(v));
            }
            await cacheCars(cars);
            pp('$xz getCars 🍎🍎🍎🍎 list of ${cars.length} cars has been filled!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz getCars 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          } else {
            pp('$xz ERROR: could not find file. ${E.redDot}');
          }
        }
      }
    } catch (e, stack) {
      pp('$xz ... Error dealing with zipped file: $e : $stack');
      rethrow;
    }
    return cars;
  }

  Future cacheCars(List<Vehicle> cars) async {
    listApiDog.realm.write(() {
      listApiDog.realm.addAll<Vehicle>(cars, update: true);
    });
    pp('$xz ${cars.length} cars cached in realm');
  }

  Future<List<City>> getCities(String countryId, String token) async {
    pp('$xz getCities: 🔆🔆🔆 get zipped city data countryId: $countryId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getCountryCitiesZippedFile?countryId=$countryId';
    var start = DateTime.now();
    List<City> cities = [];

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    pp('$xz getCities: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz getCities: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz getCities: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz getCities: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz getCities: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            List mJson = json.decode(m);
            //mjson has multiple cities
            for (var v in mJson) {
              cities.add(buildCity(v));
            }
            await cacheCities(cities);
            pp('$xz getCities 🍎🍎🍎🍎 list of ${cities.length} cities has been filled!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz getCities 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          } else {
            pp('$xz ERROR: could not find file. ${E.redDot}');
          }
        }
      }
    } catch (e) {
      pp('$xz ... Error dealing with zipped file: $e');
      rethrow;
    }
    return cities;
  }

  Future cacheCities(List<City> cities) async {
    listApiDog.realm.write(() {
      listApiDog.realm.addAll<City>(cities, update: true);
    });
    pp('$xz ${cities.length} cities cached in realm');
  }

  Future<RouteData> getRouteData(
      {required String associationId, required String token}) async {
    pp('$xz _getRouteBag: 🔆🔆🔆 get zipped data; ... associationId: $associationId ...');

    final mUrl =
        '${KasieEnvironment.getUrl()}getAssociationRouteZippedFile?associationId'
        '=$associationId';

    var start = DateTime.now();
    RouteData routeData =
        RouteData(routes: [], routePoints: [], landmarks: [], cities: []);

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);

    pp('$xz getRouteData: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz getRouteData: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz _getRouteBag: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz _getRouteBag: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz _getRouteBag: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');
          List<Route> routes = [];
          List<RoutePoint> routePoints = [];
          List<RouteLandmark> landmarks = [];
          List<RouteCity> cities = [];

          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            var mJson = json.decode(m);

            List dRoutes = mJson['routes'];
            List dRoutePoints = mJson['points'];
            List dLandmarks = mJson['landmarks'];
            List dCities = mJson['cities'];

            for (var json in dRoutes) {
              routes.add(buildRoute(json));
            }
            pp('$xz _getRouteBag 🍎🍎 routes: ${routes.length}');
            for (var marks in dLandmarks) {
              marks.forEach((element) {
                landmarks.add(buildRouteLandmark(element));
              });
            }
            pp('$xz _getRouteBag 🍎🍎 landmarks: ${landmarks.length}');

            for (var mPoints in dRoutePoints) {
              mPoints.forEach((element) {
                routePoints.add(buildRoutePoint(element));
              });
            }
            pp('$xz _getRouteBag 🍎🍎 routePoints: ${routePoints.length}');
            for (var mCities in dCities) {
              mCities.forEach((element) {
                cities.add(buildRouteCity(element));
              });
            }
            pp('$xz _getRouteBag 🍎🍎 cities: ${cities.length}');

            routeData = RouteData(
                routes: routes,
                routePoints: routePoints,
                landmarks: landmarks,
                cities: cities);
            await cacheBag(
                routes: routes,
                routePoints: routePoints,
                landmarks: landmarks,
                cities: cities);

            pp('$xz _getRouteBag 🍎🍎🍎🍎 route bag has been filled and cached!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          }
        }
      }
    } catch (e, stackTrace) {
      pp('Error parsing JSON: $e');
      pp('Stack trace: $stackTrace');
      rethrow;
    }
    return routeData;
  }

  Future<List<RoutePoint>> getRoutePoints(
      {required String routeId, required String token}) async {
    pp('$xz getRoutePoints: 🔆🔆🔆 get zipped data; ... routeId: $routeId ...');

    final mUrl = '${KasieEnvironment.getUrl()}getRoutePointsZipped?routeId'
        '=$routeId';

    var start = DateTime.now();
    List<RoutePoint> routePoints = [];

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);

    return await _getPointsFromArchive(response);
  }

  Future<List<RoutePoint>> deleteRoutePoints(
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

    return await _getPointsFromArchive(response);
  }

  Future<List<RoutePoint>> _getPointsFromArchive(http.Response response) async {
    pp('$xz _getPointsFromArchive: 🔆🔆🔆 get zipped data, response contentLength: ${response.contentLength} bytes ...');

    var start = DateTime.now();
    List<RoutePoint> routePoints = [];
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz _getPointsFromArchive: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz _getPointsFromArchive: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz _getPointsFromArchive: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            List mJson = json.decode(m);
            for (var element in mJson) {
              routePoints.add(buildRoutePoint(element));
            }
            pp('$xz _getPointsFromArchive 🍎🍎🍎🍎 ${routePoints.length} route points built!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz _getPointsFromArchive 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
          }
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
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File(
          '${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz refreshRoute: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

      //create zip archive
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      pp('$xz refreshRoute: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

      for (var file in archive.files) {
        if (file.isFile) {
          final fileName = file.name;
          pp('$xz refreshRoute: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
          var outFile = File('${dir.path}/$fileName');
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          pp('$xz refreshRoute: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');
          if (outFile.existsSync()) {
            var m = outFile.readAsStringSync(encoding: utf8);
            var mJson = json.decode(m);
            bag = RouteBag.fromJson(mJson);
            pp('$xz refreshRoute 🍎🍎🍎🍎 route bag has been filled and cached!');
            var end = DateTime.now();
            var ms = end.difference(start).inSeconds;
            pp('$xz refreshRoute 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
            return bag;
          }
        }
      }
    } catch (e, stackTrace) {
      pp('Error parsing JSON: $e');
      pp('Stack trace: $stackTrace');
      rethrow;
    }
    return bag;
  }

  Future cacheBag(
      {required List<Route> routes,
      required List<RoutePoint> routePoints,
      required List<RouteLandmark> landmarks,
      required List<RouteCity> cities}) async {
    pp('$xz ... cacheBag - cache all the data for ${routes.length} routes ......... ');
    //

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<RouteLandmark>(landmarks, update: true);
      listApiDog.realm.addAll<RoutePoint>(routePoints, update: true);
      listApiDog.realm.addAll<RouteCity>(cities, update: true);
      listApiDog.realm.addAll<Route>(routes, update: true);
    });
    //
    pp('$xz ... 🌼🌼 ..... Routes cached: ${routes.length}');
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
