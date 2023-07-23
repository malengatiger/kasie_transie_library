import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import 'heartbeat_isolate.dart';

final VehicleIsolate vehicleIsolate = VehicleIsolate();
const xy2 = '☕️☕️🍎🍎🍎🍎 VehicleIsolate HeavyTaskForCars: 🍎🍎';

class VehicleIsolate {
  Future<List<Vehicle>> getOwnerVehicles(String userId) async {
    pp('\n\n\n$xy2 ............................ getting owner cars ....');
    final start = DateTime.now();

    try {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final url = '${KasieEnvironment.getUrl()}';
        var bag = OwnerCarBag(userId, url, token);
        final cars = await _handleOwnerVehicles(bag);

        pp('\n\n\n$xy2 ..... ${E.nice}${E.nice} done getting owner cars ....${E.leaf} '
            'returning ${cars.length} cars');
        final end = DateTime.now();
        pp('$xy2 Elapsed time for owner cars downloaded: ${end.difference(start).inSeconds} seconds\n\n');

        return cars;
      } else {
        final msg =
            '$xy2 ... getOwnerVehicles fell down and screamed! ${E.redDot} '
            'no Firebase token found!!';
        pp(msg);
        throw Exception(msg);
      }
    } catch (e) {
      final msg = '$xy2 ... getOwnerVehicles fell down and screamed! '
          '${E.redDot}${E.redDot}${E.redDot} $e';
      pp(msg);
      throw Exception(msg);
    }
  }

  Future<List<Vehicle>> getVehicles(String associationId) async {
    pp('\n\n\n$xy2 ............................ getting cars ....');
    final start = DateTime.now();

    try {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final url = '${KasieEnvironment.getUrl()}';
        var bag = DonkeyBag(associationId, url, token);
        final cars = await _handleVehicles(bag);

        pp('\n\n\n$xy2 ..... ${E.nice}${E.nice} done getting association cars ....${E.leaf} '
            'returning ${cars.length} cars');
        final end = DateTime.now();
        pp('$xy2 Elapsed time for association cars downloaded: ${end.difference(start).inSeconds} seconds\n\n');

        return cars;
      } else {
        final msg = '$xy2 ... getVehicles fell down and screamed! ${E.redDot} '
            'no Firebase token found!!';
        pp(msg);
        throw Exception(msg);
      }
    } catch (e) {
      final msg = '$xy2 ... getVehicles fell down and screamed! '
          '${E.redDot}${E.redDot}${E.redDot} $e';
      pp(msg);
      throw Exception(msg);
    }
  }

  Future<List<Vehicle>> _handleOwnerVehicles(OwnerCarBag bag) async {
    pp('$xy2 ................ _handleOwnerVehicles .... ');
    final start = DateTime.now();

    final s = await Isolate.run(() async => _heavyTaskForOwnerCars(bag));
    final list = jsonDecode(s);
    var cars = <Vehicle>[];
    for (var value in list) {
      cars.add(buildVehicle(value));
    }
    pp('$xy2 _handleOwnerVehicles attempting to cache ${cars.length} cars.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<Vehicle>(cars, update: true);
    });
    var end = DateTime.now();
    pp('$xy2 should have cached ${cars.length} owner cars in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return cars;
  }
}

Future<List<Vehicle>> _handleVehicles(DonkeyBag bag) async {
  pp('$xy2 ................ _handleVehicles .... ');
  final start = DateTime.now();

  final s = await Isolate.run(() async => _heavyTaskForCars(bag));
  final list = jsonDecode(s);
  var cars = <Vehicle>[];
  for (var value in list) {
    cars.add(buildVehicle(value));
  }
  pp('$xy2 _handleVehicles attempting to cache ${cars.length} cars.... ');

  listApiDog.realm.write(() {
    listApiDog.realm.addAll<Vehicle>(cars, update: true);
  });
  var end = DateTime.now();
  pp('$xy2 should have cached ${cars.length} cars in realm; elapsed time: '
      '${end.difference(start).inSeconds} seconds');
  return cars;
}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForCars: 🍎🍎';

@pragma('vm:entry-point')
Future<String> _heavyTaskForCars(DonkeyBag bag) async {
  pp('$xy2 _heavyTaskForCars starting ................associationId:  ${bag.associationId} .');

  var points = [];
  final token = bag.token;
  pp('$xy2 RoutePoints for routes processed so far ... ${E.appleGreen} total: ${points.length}');
  points = await _processAssociationCars(bag.associationId, bag.url, token);

  final jsonList = jsonEncode(points);
  pp('$xy2 Association cars delivered: ${points.length}');
  pp('$xy2 _heavyTaskForCars returning raw string .................');

  return jsonList;
}

@pragma('vm:entry-point')
Future<String> _heavyTaskForOwnerCars(OwnerCarBag bag) async {
  pp('$xy2 _heavyTaskForOwnerCars starting ................userId:  ${bag.userId} .');

  var cars = [];
  final token = bag.token;
  pp('$xy2 cars for owner processed so far ... ${E.appleGreen} total: ${cars.length}');
  cars = await _processOwnerCars(bag.userId, bag.url, token);

  final jsonList = jsonEncode(cars);
  pp('$xy2 Owner cars delivered: ${cars.length}');
  pp('$xy2 _heavyTaskForOwnerCars returning raw string .................');

  return jsonList;
}

Future<List> _processOwnerCars(String userId, String url, String token) async {
  pp('\n\n$xyz _processOwnerCars for userId: $userId');

  int page = 0;
  bool stop = false;
  final allCars = [];

  while (stop == false) {
    final mUrl = '${url}getOwnerVehicles?userId=$userId&page=$page';
    List resp = await httpGet(mUrl, token);
    pp('$xy2 page of cars for userId: $userId: ${resp.length}');

    if (resp.isEmpty) {
      stop = true;
    }
    allCars.addAll(resp);
    page++;
  }

  pp('$xy2 cars for userId: $userId: ${allCars.length}\n\n');
  return allCars;
}

Future<List> _processAssociationCars(
    String associationId, String url, String token) async {
  pp('\n\n$xyz _processAssociationCars associationId: $associationId');

  int page = 0;
  bool stop = false;
  final points = [];

  while (stop == false) {
    final mUrl =
        '${url}getAssociationVehicles?associationId=$associationId&page=$page';
    List resp = await httpGet(mUrl, token);
    pp('$xy2 page of cars for associationId: $associationId: ${resp.length}');

    if (resp.isEmpty) {
      stop = true;
    }
    points.addAll(resp);
    page++;
  }

  pp('$xy2 cars for associationId: $associationId: ${points.length}\n\n');
  return points;
}

class DonkeyBag {
  late String associationId, url, token;

  DonkeyBag(this.associationId, this.url, this.token);
}

class OwnerCarBag {
  late String userId, url, token;

  OwnerCarBag(this.userId, this.url, this.token);
}

class RoutePointsBag {
  late List<String> routeIds;
  late String url, token;

  RoutePointsBag(this.routeIds, this.url, this.token);
}

class BunnyBag {
  late String associationId;
  late String url, token;

  BunnyBag(this.associationId, this.url, this.token);
}

class BirdieBag {
  late String associationId, routeId;
  late String url, token;

  BirdieBag(this.associationId, this.routeId, this.url, this.token);
}
