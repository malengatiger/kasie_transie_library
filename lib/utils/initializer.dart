import 'dart:async';

import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/country_cities_isolate.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
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

    pp('$mm sending completion flag to stream .... ${E.nice}');
    _streamController.sink.add(true);

    countryCitiesIsolate.getCountryCities(user!.countryId!);

    pp('$mm ... initialization done! \n\n');
    return 'We are done, Boss!';
  }

  Future _getVehicles() async {
    if (user != null) {
      pp('$mm ... getting association cars ............ ');
      var list = await listApiDog.getAssociationVehicles(user!.associationId!, false);
      pp('$mm ... cached: ${list.length} taxis');
      return;
    }
    if (car != null) {
      pp('$mm ... getting association cars ............ ');
      var list = await listApiDog.getAssociationVehicles(car!.associationId!, false);
      pp('$mm ... cached: ${list.length} taxis');
      return;
    }
  }

  Future _getUsers() async {
    if (car != null) {
      pp('$mm ... getting association users ............ ');
      var list = await listApiDog.getAssociationUsers(car!.associationId!);
      pp('$mm ... cached: ${list.length} users');
      return;
    }
    if (user != null) {
      pp('$mm ... getting association users ............ ');
      var list = await listApiDog.getAssociationUsers(user!.associationId!);
      pp('$mm ... cached: ${list.length} users');
    }
  }

  Future _getRoutes() async {
    if (car != null) {
      pp('\n\n$mm ... getting association routes in isolate ............ ');
      await routesIsolate.getRoutes(car!.associationId!);
      return;
    }

    if (user != null) {
      pp('\n\n$mm ... getting association routes in isolate ............ ');
      await routesIsolate.getRoutes(user!.associationId!);
      return;
    }
  }

}
