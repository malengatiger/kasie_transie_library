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

import '../data/route_bag.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';
import 'heartbeat_isolate.dart';

final VehicleIsolate vehicleIsolate = VehicleIsolate();
const xy2 = '☕️☕️🍎🍎🍎🍎 VehicleIsolate HeavyTaskForCars: 🍎🍎';

class VehicleIsolate {

  Future<List<Vehicle>> getVehicles(String associationId) async {
    pp('\n\n\n$xy2 ............................ getting cars ....');
    final start = DateTime.now();

    try {
      final token = await appAuth.getAuthToken();
      if (token != null) {
        final url = '${KasieEnvironment.getUrl()}';
        var bag = DonkeyBag(associationId, url, token);
        final cars = await _handleVehicles(bag);
        pp('$xy2 back from all the isolate functions ...${E.nice} looks OK to me! ... ');

        pp('\n\n\n$xy2 ..... ${E.nice}${E.nice} done getting association cars ....${E.leaf} '
            'returning ${cars.length} cars');
        final end = DateTime.now();
        pp('$xy2 Elapsed time for association cars downloaded: ${end.difference(start).inSeconds} seconds\n\n');

        return cars;
      } else {
        final msg = '$xy2 ... getRoutes fell down and screamed! ${E.redDot} '
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

}

///Isolate to get association routes
const xyz = '🌀🌀🌀🌀🌀🌀🌀🌀🌀 HeavyTaskForCars: 🍎🍎';


@pragma('vm:entry-point')
Future<String> _heavyTaskForCars(DonkeyBag bag) async {
  pp('$xy2 _heavyTaskForCars starting ................associationId:  ${bag.associationId} .');

  var points = [];
  final token = bag.token;
  pp('$xy2 RoutePoints for routes processed so far ... ${E.appleGreen} total: ${points.length}');
  points = await _processCars(bag.associationId, bag.url, token);

  final jsonList = jsonEncode(points);
  pp('$xy2 Association cars delivered: ${points.length}');
  pp('$xy2 _heavyTaskForCars returning raw string .................');

  return jsonList;
}

Future<List> _processCars(
    String associationId, String url, String token) async {
  pp('\n\n$xyz _processCars associationId: $associationId');

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
