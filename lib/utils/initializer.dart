import 'dart:async';

import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/isolates/country_cities_isolate.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'functions.dart';

final Initializer initializer = Initializer();

class Initializer {
  final mm = '😡😡😡😡😡😡😡 Initializer 😡😡 ';

  Vehicle? car;
  User? user;

  final StreamController<bool> _streamController = StreamController.broadcast();

  Stream<bool> get completionStream => _streamController.stream;

  Future initialize() async {
    pp('\n\n\n$mm ... initialize starting; all association data to be downloaded ....');

    car = await prefs.getCar();
    user = await prefs.getUser();
    if (car == null && user == null) {
      final msg = 'No Car, No User, initialize cannot continue ${E.redDot}';
      throw Exception(msg);
    }

    if (car != null) {
      myPrettyJsonPrint(car!.toJson());
    }

    try {
      pp('$mm ... starting to get cars ... 1');
      await _getVehicles();

      pp('$mm ... starting to get users ... 2');
      await _getUsers();

      pp('$mm ... starting to get routes ... will use isolate ... 3');
      await _getRoutes();

      pp('$mm sending completion flag to stream .... ${E.nice} ... 4');
      _streamController.sink.add(true);
      try {
        pp('$mm ... starting to get country cities ... without await! ... 5');
        if (user != null) {
          countryCitiesIsolate.getCountryCities(user!.countryId!);
        }
        if (car != null) {
          countryCitiesIsolate.getCountryCities(car!.countryId!);
        }
      } catch (e) {
        pp('$mm something is fucked up here, Boss! - ${E.redDot} $e');
        pp(e);
      }
    } catch (e) {
      pp(e);
      throw Exception('Initializer failed!');
    }

    pp('\n\n$mm ... initialization done! .... 6 ${E.leaf}${E.leaf}${E.leaf}${E.leaf}\n\n');
    return 'We are done, Boss!';
  }

  Future<List<Vehicle>> _getVehicles() async {
    if (user != null) {
      pp('$mm ... getting association cars ............ ');
      var list =
          await listApiDog.getAssociationVehicles(user!.associationId!, false);
      pp('$mm ... cached: ${list.length} taxis');
      return list;
    }
    if (car != null) {
      pp('$mm ... getting association cars ............ ');
      var list =
          await listApiDog.getAssociationVehicles(car!.associationId!, false);
      pp('$mm ... cached: ${list.length} taxis');
      return list;
    }
    throw Exception('Cars crashed and burned!');
  }

  Future<List<User>> _getUsers() async {
    if (car != null) {
      pp('$mm ... getting association users ............ ');
      var list = await listApiDog.getAssociationUsers(car!.associationId!);
      pp('$mm ... cached: ${list.length} users');
      return list;
    }
    if (user != null) {
      pp('$mm ... getting association users ............ ');
      var list = await listApiDog.getAssociationUsers(user!.associationId!);
      pp('$mm ... cached: ${list.length} users');
      return list;
    }
    throw Exception('Users not here, Joe!');
  }

  Future _getRoutes() async {
    if (car != null) {
      pp('\n\n\n$mm ... getting association routes in isolate ............ car: ${car!.vehicleReg} ');
      await routesIsolate.getRoutes(car!.associationId!);
      return;
    }

    if (user != null) {
      pp('\n\n$mm ... getting association routes in isolate ............ user: ${user!.name} ');
      await routesIsolate.getRoutes(user!.associationId!);
      return;
    }
    //
    pp('$mm routesIsolate just fucked up in _getRoutes! ${E.redDot} No car, No user! ${E.redDot}${E.redDot}${E.redDot}');
    throw Exception('routesIsolate just fucked up in _getRoutes !');
  }
}
