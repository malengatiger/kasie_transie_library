import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/route_bag.dart';
import 'package:http/http.dart' as http;
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

  Future<List<Vehicle>> getCars(String associationId) async {
    pp('$xz getVehiclesZippedFile: 🔆🔆🔆 get zipped data associationId: $associationId ...');

    final mUrl = '${KasieEnvironment.getUrl()}getVehiclesZippedFile?associationId=$associationId';
    var start = DateTime.now();
    List<Vehicle> cars = [];
    final token = await appAuth.getAuthToken();
    if (token == null) {
      return [];
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    pp('$xz getCars: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File('${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
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
    } catch (e) {
      pp('$xz ... Error dealing with zipped file: $e');
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
  Future<List<City>> getCities(String countryId) async {
    pp('$xz getCities: 🔆🔆🔆 get zipped data countryId: $countryId ...');

    final mUrl = '${KasieEnvironment.getUrl()}getCountryCitiesZippedFile?countryId=$countryId';
    var start = DateTime.now();
    List<City> cities = [];
    final token = await appAuth.getAuthToken();
    if (token == null) {
      return [];
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);
    pp('$xz getCities: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File('${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
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

  Future<RouteBagList?> getRouteBags(
      {required String associationId}) async {
    pp('$xz _getRouteBag: 🔆🔆🔆 get zipped data associationId: $associationId ...');

    final mUrl = '${KasieEnvironment.getUrl()}getAssociationRouteZippedFile?associationId=$associationId';
    var start = DateTime.now();
    RouteBagList? routeBagList;
    final token = await appAuth.getAuthToken();
    if (token == null) {
      return null;
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
    headers['Authorization'] = 'Bearer $token';

    http.Response response = await getUsingHttp(mUrl, token, headers);

    pp('$xz _getRouteBag: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File zipFile = File('${dir.path}/zipFile${DateTime.now().millisecondsSinceEpoch}.zip');
      zipFile.writeAsBytesSync(response.bodyBytes);
      pp('$xz _getRouteBag: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

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

              if (outFile.existsSync()) {
                var m = outFile.readAsStringSync(encoding: utf8);
                var mJson = json.decode(m);
                //mjson has multiple route bags
                routeBagList = RouteBagList.fromJson(mJson);
                await cacheBag(routeBagList);
                pp('$xz _getRouteBag 🍎🍎🍎🍎 bag has been filled!');
                var end = DateTime.now();
                var ms = end.difference(start).inSeconds;
                pp('$xz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
              } else {
                pp('$xz ERROR: could not find file. ${E.redDot}');
              }
            }
          }
    } catch (e) {
      pp('$xz ... Error dealing with zipped file: $e');
      rethrow;
    }
    return routeBagList;
  }

  Future cacheBag(RouteBagList bagList) async {
    pp('$xz ... cacheBag RouteBagList ......... ');
    //
    for (var bag in bagList.routeBags) {
      listApiDog.realm.write(() {
        listApiDog.realm.addAll<RouteLandmark>(bag.routeLandmarks, update: true);
        listApiDog.realm.addAll<RoutePoint>(bag.routePoints, update: true);
        listApiDog.realm.addAll<RouteCity>(bag.routeCities, update: true);
        listApiDog.realm.add<Route>(bag.route!, update: true);
      });
      //
      pp('$xz ... 🌼🌼 Total Route cached: ${bag.route!.name!}'
          '\n🌼 landmarks: ${bag.routeLandmarks.length}'
          '\n🍎 routePoints: ${bag.routePoints.length}'
          '\n💙 routeCities: ${bag.routeCities.length}');

    }

  }
  Future<http.Response> getUsingHttp(String mUrl, String token, Map<String, String> headers) async {
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
