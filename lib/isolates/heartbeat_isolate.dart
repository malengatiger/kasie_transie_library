import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final HeartbeatIsolate heartbeatIsolate = HeartbeatIsolate();

class HeartbeatIsolate {
  final xy = '☕️☕️☕️☕️ HeartbeatIsolate Functions: 🍎🍎';
  Future addHeartbeat() async {
    pp('\n\n\n$xy ............................ addHeartbeat ....');

    try {
      var res = await Firebase.initializeApp();
      pp('\n\n$xy Firebase.initializeApp .. seems ok! ... app: ${res.name}');

      final token = await appAuth.getAuthToken();
      var car = await prefs.getCar();
      final loc = await locationBloc.getLocation();
      if (car == null) {
        try {
          await Firebase.initializeApp();
          final prefs1 = await SharedPreferences.getInstance();
          prefs1.reload(); // The magic line
          var string = prefs1.getString('car');
          if (string == null) {
            pp('$xy ... ${E.redDot}${E.redDot}${E.redDot} car is null in background ... 1');
            return;
          } else {
            final json = jsonDecode(string);
            car = buildVehicle(json);
          }
        } catch (e) {
          pp('$xy  addHeartbeat fell down and cried like a baby! ${E.redDot}');
          pp(e);
        }
      }

      if (token != null) {
            final string = jsonEncode(car!.toJson());
            final bag = HeartbeatBag(carJson: string, url: KasieEnvironment.getUrl(),
                token: token, latitude: loc.latitude, longitude: loc.longitude);
            pp('$xy  save new heartbeat to backend; using isolate ... ');
            final m = await _handleHeartbeat(bag);
            pp('\n\n\n$xy ..... done saving ${m.vehicleReg} heartbeat record ....\n\n');
            return m;

          } else {
            pp('$xy ${E.redDot}${E.redDot}${E.redDot}${E.redDot} no Firebase token found!!!! ${E.redDot}');
          }
    } catch (e) {
      pp(e);
    }
    throw Exception('Failed to add heartbeat');
  }


  Future<VehicleHeartbeat> _handleHeartbeat(HeartbeatBag bag) async {
    pp('$xy ................ _handleHeartbeat .... ');
    final start = DateTime.now();
    final s = await Isolate.run(() async => _heavyTaskForHeartbeat(bag));
    final mJson = jsonDecode(s);
    final heartbeat = buildVehicleHeartbeat(mJson);

    pp('$xy _handleHeartbeat attempting to cache ${heartbeat.vehicleReg} heartbeat.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.add<VehicleHeartbeat>(heartbeat, update: true);
    });
    var end = DateTime.now();
    pp('$xy should have cached ${heartbeat.vehicleReg} Heartbeat in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return heartbeat;
  }

}

///Isolate to handle dispatches
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForDispatches: 🍎🍎';
@pragma('vm:entry-point')
Future<String> _heavyTaskForHeartbeat(HeartbeatBag hb) async {
  pp('$xyz _heavyTaskForHeartbeat starting .................');

  await Firebase.initializeApp();
  final m = jsonDecode(hb.carJson);
  final car = buildVehicle(m);
  final heartbeat = VehicleHeartbeat(ObjectId(),
      ownerName: car.ownerName,
      ownerId: car.ownerId,
      associationId: car.associationId,
      vehicleReg: car.vehicleReg,
      vehicleId: car.vehicleId,
      model: car.model,
      make: car.make,
      created: DateTime.now().toUtc().toIso8601String(),
      longDate: DateTime.now().toUtc().millisecondsSinceEpoch,
      vehicleHeartbeatId: Uuid.v4().toString(),
      position: Position(
        type: point,
        coordinates: [hb.longitude, hb.latitude],
        latitude: hb.latitude,
        longitude: hb.longitude,
      ));

  final bag = heartbeat.toJson();
  final cmd =
      '${hb.url}addHeartbeat';
  final resp = await httpPost(cmd, bag, hb.token);
  final result = jsonEncode(resp);
  pp('$xyz _heavyTaskForHeartbeat returning raw string .................');

  return result;
}

Future httpPost(String mUrl, Map? bag, String token) async {
  String? mBag;
  if (bag != null) {
    mBag = json.encode(bag);
  }
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  var start = DateTime.now();
  headers['Authorization'] = 'Bearer $token';
  try {
    var resp = await client
        .post(
      Uri.parse(mUrl),
      body: mBag,
      headers: headers,
    )
        .timeout(const Duration(seconds: 120));
    if (resp.statusCode == 200) {
      pp('$xyz  _httpPost RESPONSE: 💙💙 statusCode: 👌👌👌 '
          '${resp.statusCode} 👌👌👌 💙 for $mUrl');
    } else {
      pp('$xyz  👿👿👿_httpPost: 🔆 statusCode: 👿👿👿 '
          '${resp.statusCode} 🔆🔆🔆 for $mUrl');
      pp(resp.body);
      throw KasieException(
          message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
    }
    var end = DateTime.now();
    pp('$xyz  _httpPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
    try {
      var mJson = json.decode(resp.body);
      return mJson;
    } catch (e) {
      pp("$xyz 👿👿👿👿👿👿👿 json.decode failed, returning response body");
      return resp.body;
    }
  } on SocketException {
    pp('$xyz  SocketException: really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$xyz  HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$xyz  Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$xyz  No Internet connection. Request has timed out in 120 seconds 👎");
    final gex = KasieException(
        message: 'Request timed out. No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    //errorHandler.handleError(exception: gex);
    throw gex;
  }
}

Future httpGet(String mUrl, String token, Map<String, String> headers) async {
  pp('$xyz _httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
  var start = DateTime.now();

  try {
    final http.Client client = http.Client();
    var resp = await client
        .get(
          Uri.parse(mUrl),
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));
    pp('$xyz _httpGet call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
    var end = DateTime.now();
    pp('$xyz _httpGet call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

    if (resp.body.contains('not found')) {
      return false;
    }

    if (resp.statusCode == 403) {
      var msg =
          '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
      pp(msg);
      // final gex = KasieException(
      //     message: 'Forbidden call',
      //     url: mUrl,
      //     translationKey: 'serverProblem',
      //     errorType: KasieException.httpException);
      // //errorHandler.handleError(exception: gex);
      // throw gex;
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
    var mJson = json.decode(resp.body);
    return mJson;
  } on SocketException {
    pp('$xyz SocketException, really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$xyz HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$xyz Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$xyz No Internet connection. Request has timed out in 120 seconds 👎");
    final gex = KasieException(
        message: 'No Internet connection. Request timed out',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    // //errorHandler.handleError(exception: gex);
    throw gex;
  }
}

final http.Client client = http.Client();


class HeartbeatBag {
  late String carJson, url, token;
  late double latitude, longitude;

  HeartbeatBag({
      required this.carJson,  required  this.url,  required this.token,  required this.latitude,  required this.longitude});
}



