import 'dart:async';
import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:geolocator/geolocator.dart' as geo;

import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../isolates/routes_isolate.dart';

final TinyBloc tinyBloc = TinyBloc();

class TinyBloc {
  final mm = '🧩🧩🧩🧩🧩🧩 TinyBloc: 😎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  final StreamController<lib.Route> _streamController =
      StreamController.broadcast();
  Stream<lib.Route> get routeStream => _streamController.stream;

  final StreamController<String> routeIdStreamIdController =
      StreamController.broadcast();
  Stream<String> get routeIdStream => routeIdStreamIdController.stream;

  final StreamController<Map> scannerResultController =
  StreamController.broadcast();
  Stream<Map> get  scannerResultStream =>  scannerResultController.stream;


  void setRouteId(String routeId) {
    pp('$mm ... putting routeId on _streamIdController...');
    routeIdStreamIdController.sink.add(routeId);
  }

  void setScannerResult(Map map) {
    scannerResultController.sink.add(map);
  }

  lib.Route? getRouteFromCache(String routeId) {
    // pp('$mm ... getting cached route ...');
    // var r = listApiDog.realm.query<lib.Route>('routeId == \$0', [routeId]);
    // lib.Route? route;
    // if (r.isNotEmpty) {
    //   route = r.first;
    //   _streamController.sink.add(route);
    // }
    return null;
  }

  Future<lib.Route?> getRoute(String routeId) async {
    pp('$mm ... getting cached route ... ');
    lib.Route? route;

      final user = prefs.getUser();
      if (user != null) {
        route = await listApiDog.getRoute(routeId);
        if (route != null) {
        _streamController.sink.add(route);
        }

    }
    return route;
  }

  Future<int> getNumberOfLandmarks(String routeId) async {
    pp('$mm ... getNumberOfLandmarks cached  ...');
    final res = await listApiDog.getRouteLandmarks(routeId, false);
    final m = res.length;
    return m;
  }

  Future<int> getNumberOfPoints(String routeId) async {
    pp('$mm ... getNumberOfPoints cached ...');
    var routesIsolate = GetIt.instance<RoutesIsolate>();
    final res = await routesIsolate.getRoutePoints(routeId, false);
    final m = res.length;
    return m;
  }

  lib.RoutePoint? findRoutePoint(
      {required double latitude,
      required double longitude,
      required List<lib.RoutePoint> points}) {
    pp('$mm ... findRoutePoint nearest $latitude - $longitude ...');

    var kMap = HashMap<double, lib.RoutePoint>();
    for (var p in points) {
      var distance = geo.GeolocatorPlatform.instance.distanceBetween(latitude,
          longitude, p.position!.coordinates[1], p.position!.coordinates[0]);
      kMap[distance] = p;
    }

    List list = kMap.keys.toList();
    list.sort();
    pp('$mm nearest distance; ${list.first} metres');
    pp('$mm furthest distance; ${list.last} metres');


    if (list.first > 50) {
      pp('$mm nearest routePoint is too far away; ${E.redDot} distance: ${list.first} metres');
    }
    lib.RoutePoint? rp = kMap[list.first];
    pp('$mm ... findRoutePoint nearest  ...');
    myPrettyJsonPrint(rp!.toJson());

    return rp;
  }
}
