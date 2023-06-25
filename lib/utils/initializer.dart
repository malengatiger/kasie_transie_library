import 'dart:async';

import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/country_cities_isolate.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/utils/routes_isolate.dart';
import 'functions.dart';

final Initializer initializer = Initializer();
class Initializer {
  final mm = '😡😡😡😡😡😡😡 Initializer 😡 ';

  Vehicle? car;
  User? user;

  final StreamController<bool> _streamController = StreamController.broadcast();
  Stream<bool> get completionStream  => _streamController.stream;

  Future initialize() async {
    pp('\n\n$mm ... initialize starting; all association data to be downloaded ....');

    car = await prefs.getCar();
    user = await prefs.getUser();

    await _getVehicles();
    await _getUsers();
    await _getRoutes();

    _streamController.sink.add(true);
    pp('$mm ... initialization done! \n\n');

  }

  Future _getCountries() async {
    pp('$mm ... getCountries starting ....');
    var list = await listApiDog.getCountries();
    pp('$mm ... initialization complete ... countries found: ${list.length}');

    final country = await prefs.getCountry();
    if (country != null) {
      await _getCities(country.countryId!);
    }
  }

  Future _getVehicles() async {
    if (car != null) {
      pp('$mm ... getting association cars ............ ');
      var list = await listApiDog.getAssociationVehicles(car!.associationId!, false);
      pp('$mm ... cached: ${list.length} taxis');
    }
  }

  Future _getUsers() async {
    if (car != null) {
      pp('$mm ... getting association users ............ ');
      var list = await listApiDog.getAssociationUsers(car!.associationId!);
      pp('$mm ... cached: ${list.length} users');
    }
  }

  Future _getCities(String countryId) async {
      pp('$mm ... getting country cities ............ ');
      countryCitiesIsolate.getCountryCities(countryId);
  }

  Future _getRoutes() async {
    final car = await prefs.getCar();

    if (car != null) {
      pp('$mm ... getting association routes ............ ');
      routesIsolate.getRoutes(car.associationId!);
    }
  }

}
