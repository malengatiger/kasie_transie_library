import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../data/data_schemas.dart';
import '../isolates/routes_isolate.dart';
import 'functions.dart';

final Initializer initializer = Initializer();

class Initializer {
  final mm = '🌍🌍🌍🌍🌍 Initializer 🌍🌍 ';
  Vehicle? car;
  User? user;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  final StreamController<bool> _streamController = StreamController.broadcast();

  Stream<bool> get completionStream => _streamController.stream;

  Future<String> initialize() async {
    pp('\n\n\n$mm ... initialize starting; all association data to be downloaded ....');

    car = prefs.getCar();
    user = prefs.getUser();
    if (car == null && user == null) {
      final msg = 'No Car, No User, initialize cannot continue ${E.redDot}';
      throw Exception(msg);
    }

    if (car != null) {
      myPrettyJsonPrint(car!.toJson());
    }
    if (user != null) {
      myPrettyJsonPrint(user!.toJson());
    }

    try {
      // pp('$mm ... starting to get cars ... 1');
      // await _getVehicles();

      pp('$mm ... starting to get users ...');
      // await _getUsers();

      pp('$mm ... starting to get routes ... will use isolate ... 3');
      // await _getRoutes();

      pp('$mm sending completion flag to stream .... ${E.nice} ... 4');
      _streamController.sink.add(true);
      return "Possibility exists that we are done, Chief!";

      // try {
      //   pp('$mm ... starting to get country cities ... without await! ... 5');
      //   if (user != null) {
      //     countryCitiesIsolate.getCountryCities(user!.countryId!);
      //   }
      //   if (car != null) {
      //     countryCitiesIsolate.getCountryCities(car!.countryId!);
      //   }
      // } catch (e) {
      //   pp('$mm something is fucked up here, Boss! - ${E.redDot} $e');
      //   pp(e);
      // }
    } catch (e) {
      pp(e);
      throw Exception('Initializer failed!');
    }

    pp('\n\n$mm ... initialization done! .... 6 ${E.leaf}${E.leaf}${E.leaf}${E.leaf}\n\n');
    return 'We are done, Boss!';
  }



}
