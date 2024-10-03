import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../bloc/app_auth.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final DirectionsDog directionsDog = DirectionsDog();
class DirectionsDog {
  /*
  key:
  https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&key=YOUR_API_KEY
   */
  final urlPrefix = 'https://maps.googleapis.com/maps/api/directions/json?';
  final mm = ' 😡😡😡 DirectionsDog 😡😡😡';
  final http.Client client = http.Client();
  ErrorHandler errorHandler = GetIt.instance<ErrorHandler>();

  Future getDirections({required double originLat, required double originLng,
    required double destinationLat, required double destinationLng}) async {
    await dot.dotenv.load();
    var key = dot.dotenv.get('API_KEY');
    var url = '${urlPrefix}origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$key';

    final result = await _httpGet(url);
    pp('$mm we are back with directions: Yay! ${E.nice}');
    myPrettyJsonPrint(result);
  }
  Future _httpGet(String mUrl) async {
    pp('$mm _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
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
          .timeout(const Duration(seconds: 120));
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
      pp("$mm No Internet connection. Request has timed out in 120 seconds 👎");
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
