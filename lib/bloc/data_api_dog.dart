import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:http/http.dart' as http;
import '../data/schemas.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';

late DataApiDog dataApiDog;

class DataApiDog {
  static const mm = '🌎🌎🌎🌎🌎🌎 DataApiDog: 🌎🌎';

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

  Future addVehicle(Vehicle vehicle) async {
    final bag = vehicle.toJson();
    final cmd = '${url}addVehicle';
    final res = _callPost(cmd, bag);
    pp('$mm vehicle added to database: $res');
  }

  Future addLandmark(Landmark landmark) async {
    final bag = landmark.toJson();
    final cmd = '${url}addLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm landmark added to database: $res');

  }
  Future addRoutePoints(List<RoutePoint> routePoints) async {

    final list = jsonEncode(routePoints);
    final bag = {
      'routePoints': list,
    };

    final cmd = '${url}addRoutePoints';
    List res = await _callPost(cmd, bag);
    pp('$mm routePoints added to database: ${res.length}');

  }
  Future addRoute(Route route) async {
    final bag = route.toJson();
    final cmd = '${url}addRoute';
    final res = _callPost(cmd, bag);
    pp('$mm route added to database: $res');

  }
  Future registerAssociation(Association association) async {
    final bag = association.toJson();
    final cmd = '${url}registerAssociation';

    final res = _callPost(cmd, bag);
    pp('$mm association registration added to database: $res');

  }
  Future addSettings(SettingsModel settings) async {
    final bag = settings.toJson();
    final cmd = '${url}addSettingsModel';

    final res = _callPost(cmd, bag);
    pp('$mm settings added to database: $res');

  }


  Future _callPost(String mUrl, Map? bag) async {
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


}
