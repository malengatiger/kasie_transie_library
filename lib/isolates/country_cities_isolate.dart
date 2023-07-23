import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../utils/functions.dart';
import '../utils/kasie_exception.dart';

final CountryCitiesIsolate countryCitiesIsolate = CountryCitiesIsolate();

class CountryCitiesIsolate {
  final xy = '💦💦💦💦💦💦💦💦 Country Cities Isolated Functions: 🍎🍎';

  Future<int> getCountryCities(String countryId) async {
    pp('\n\n\n$xy .............................. getting country cities ....');

    final start = DateTime.now();
    final token = await appAuth.getAuthToken();
    if (token != null) {
      final bag = CharlieBag(countryId, KasieEnvironment.getUrl(), token);
      final jsonList =
          await Isolate.run(() async => _heavyTaskForCountryCities(bag));
      final list = jsonDecode(jsonList);
      var mCities = <City>[];
      for (var value in list) {
        mCities.add(buildCity(value));
      }
      pp('$xy before caching to realm, cities from backend : 💙 ${mCities.length}  💙');

      listApiDog.realm.write(() {
        listApiDog.realm.addAll<City>(mCities, update: true);
      });

      final end = DateTime.now();
      pp('\n\n$xy should have cached ${mCities.length} cities in Realm; elapsed time: '
          '${end.difference(start).inSeconds} seconds\n\n');
    }

    return 0;
  }
}

///Isolate to get country cities
const xyz =
    '💦💦💦💦💦💦💦💦 CountryCitiesIsolate: _heavyTaskForCountryCities: 🍎🍎';

Future<String> _heavyTaskForCountryCities(CharlieBag bag) async {
  pp('xyz ... _heavyTaskForCountryCities');
  List allCities = [];
  int page = 0;
  bool stop = false;
  while (stop == false) {
    final mUrl =
        '${bag.url}getCountryCities?countryId=${bag.countryId}&page=$page';
    final List list = await _httpGet(mUrl, bag.token);
    allCities.addAll(list);
    if (list.isEmpty) {
      stop = true;
    }
    page++;
    pp('$xyz ... this page $page contains ${list.length} cities');
    pp('$xyz .... sleeping for .5 second ...');
    await Future.delayed(const Duration(milliseconds: 500));
  }
  var s = jsonEncode(allCities);
  pp('xyz ... _heavyTaskForCountryCities completed, returning big string .... ${s.length} bytes');

  return s;
}

Future _httpGet(String mUrl, String token) async {
  pp('$xyz _httpGet: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
  var start = DateTime.now();
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  headers['Authorization'] = 'Bearer $token';
  try {
    final http.Client client = http.Client();
    var resp = await client
        .get(
          Uri.parse(mUrl),
          headers: headers,
        )
        .timeout(const Duration(seconds: 600));
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

class CharlieBag {
  late String countryId, url, token;

  CharlieBag(this.countryId, this.url, this.token);
}
