import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/zip_handler.dart';
import 'heartbeat_isolate.dart';

final VehicleIsolate vehicleIsolate = VehicleIsolate();
const xy2 = '☕️☕️🍎🍎🍎🍎 VehicleIsolate HeavyTaskForCars: 🍎🍎';

class VehicleIsolate {
  Future<List<Vehicle>> getOwnerVehicles(String userId) async {
    pp('\n\n\n$xy2 ............................ getting owner cars ....');
    final start = DateTime.now();

    try {
        final cars = await _handleOwnerVehicles(userId);
        pp('\n\n\n$xy2 ..... ${E.nice}${E.nice} done getting owner cars ....${E.leaf} '
            'returning ${cars.length} cars');
        final end = DateTime.now();
        pp('$xy2 Elapsed time for owner cars downloaded: ${end.difference(start).inSeconds} seconds\n\n');

        return cars;
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

        final cars = await _handleVehicles(associationId);

        pp('\n\n\n$xy2 ..... ${E.nice}${E.nice} done getting association cars ....${E.leaf} '
            'returning ${cars.length} cars');
        final end = DateTime.now();
        pp('$xy2 Elapsed time for association cars downloaded: ${end.difference(start).inSeconds} seconds\n\n');

        return cars;

    } catch (e) {
      final msg = '$xy2 ... getVehicles fell down and screamed! '
          '${E.redDot}${E.redDot}${E.redDot} $e';
      pp(msg);
      throw Exception(msg);
    }
  }

  Future<List<Vehicle>> _handleOwnerVehicles(String userId) async {
    pp('$xy2 ................ _handleOwnerVehicles .... ');
    final start = DateTime.now();
    final List<Vehicle> list = [];
    final token = await appAuth.getAuthToken();
    if (token != null) {
      final rootToken = ServicesBinding.rootIsolateToken!;
      final s = await Isolate.run(
              () async => _heavyTaskForZippedOwnerCars(userId, token, rootToken));
      List json = jsonDecode(s);
      for (var value in json) {
        list.add(buildVehicle(value));
      }
    }

    pp('$xy2 _handleVehicles attempting to cache ${list.length} cars.... ');

    listApiDog.realm.write(() {
      listApiDog.realm.addAll<Vehicle>(list, update: true);
    });
    var end = DateTime.now();
    pp('$xy2 should have cached ${list.length} cars in realm; elapsed time: '
        '${end.difference(start).inSeconds} seconds');
    return list;
  }
}

Future<List<Vehicle>> _handleVehicles(String associationId) async {
  pp('$xy2 ................ _handleVehicles .... ');
  final start = DateTime.now();
  final List<Vehicle> list = [];
  final token = await appAuth.getAuthToken();
  if (token != null) {
    final rootToken = ServicesBinding.rootIsolateToken!;
    final s = await Isolate.run(
            () async => _heavyTaskForZippedCars(associationId, token, rootToken));
    List json = jsonDecode(s);
    for (var value in json) {
      list.add(buildVehicle(value));
    }
  }

  pp('$xy2 _handleVehicles attempting to cache ${list.length} cars.... ');

  listApiDog.realm.write(() {
    listApiDog.realm.addAll<Vehicle>(list, update: true);
  });
  var end = DateTime.now();
  pp('$xy2 should have cached ${list.length} cars in realm; elapsed time: '
      '${end.difference(start).inSeconds} seconds');
  return list;
}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForCars: 🍎🍎';
@pragma('vm:entry-point')
Future<String> _heavyTaskForZippedCars(
    String associationId, String token, RootIsolateToken rootToken) async {
  pp('\n\n$xyz _heavyTaskForZippedCars 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.getCars() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();

  final List<Vehicle> res = await zipHandler.getCars(associationId, token);
  final s = jsonEncode(res);
  return s;
}
@pragma('vm:entry-point')
Future<String> _heavyTaskForZippedOwnerCars(
    String userId, String token, RootIsolateToken rootToken) async {
  pp('\n\n$xyz _heavyTaskForZippedOwnerCars 🅿️ 🅿️ 🅿️  starting '
      '... calling zipHandler.getOwnerCars() ...');
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  Firebase.initializeApp();

  final List<Vehicle> res = await zipHandler.getOwnerCars(userId, token);
  final s = jsonEncode(res);
  return s;
}
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
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  headers['Authorization'] = 'Bearer $token';


  while (stop == false) {
    final mUrl = '${url}getOwnerVehicles?userId=$userId&page=$page';
    List resp = await httpGet(mUrl, token, headers);
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
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  headers['Authorization'] = 'Bearer $token';

  final mUrl =
      '${url}getAssociationVehiclesZippedFile?associationId=$associationId';
  final resp = await httpGet(mUrl, token, headers);
  pp('$xy2 cars for associationId: $associationId: ${resp.length}');

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
