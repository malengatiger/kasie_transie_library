import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import 'functions.dart';

final LocalFinder localFinder = LocalFinder();

class LocalFinder {
  final mm = '😎😎😎😎😎😎😎 LocalFinder 😎😎';

  Future<RouteLandmark?> findNearestRouteLandmark(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final routeLandmarks = listApiDog.realm.all<RouteLandmark>();

    final map = HashMap<double, RouteLandmark>();
    for (var value in routeLandmarks) {
      final dist = GeolocatorPlatform.instance.distanceBetween(
          latitude,
          longitude,
          value.position!.coordinates[1],
          value.position!.coordinates[0]);
      map[dist] = value;
    }
    List list = map.keys.toList();
    list.sort();
    if (list.isNotEmpty) {
      final m = map[list.first];
      if (list.first <= radiusInMetres) {
        pp('$mm findNearestRouteLandmarks, found: ${E.redDot} ${m!.landmarkName} route: ${m!.routeName}');
        return m;
      }
    }
    return null;
  }

  Future<List<RouteLandmark>> findNearestRouteLandmarks(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final start = DateTime.now();

    final routeLandmarks = listApiDog.realm.all<RouteLandmark>();
    pp('$mm findNearestRouteLandmarks, found all in realm: ${routeLandmarks.length}');

    final map = HashMap<double, RouteLandmark>();
    for (var value in routeLandmarks) {
      final dist = GeolocatorPlatform.instance.distanceBetween(
          latitude,
          longitude,
          value.position!.coordinates[1],
          value.position!.coordinates[0]);
      map[dist] = value;
    }
    var lrs = <RouteLandmark>[];
    List list = map.keys.toList();
    list.sort();
    if (list.isNotEmpty) {
      for (var distance in list) {
        if (distance <= radiusInMetres) {
          lrs.add(map[distance]!);
        }
      }
    }
    var hashMap = HashMap<String, RouteLandmark>();
    for (var element in lrs) {
      hashMap[element.routeId!] = element;
    }
    lrs = hashMap.values.toList();
    pp('$mm findNearestRouteLandmarks, found: ${lrs.length}');

    final end = DateTime.now();

    pp('\n\n$mm findNearestRouteLandmarks, ${E.leaf2}${E.leaf2}${E.leaf2} '
        'time elapsed: ${end.difference(start).inMilliseconds} milliseconds ${E.redDot}\n\n');

    return lrs;
  }

  Future<Route?> findNearestRoute(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    pp('\n\n$mm ............... starting findNearestRoute ...');

    var routeLandmarks = await findNearestRouteLandmarks(
        latitude: latitude,
        longitude: longitude,
        radiusInMetres: radiusInMetres);

    if (routeLandmarks.isNotEmpty) {
      final rt = await listApiDog.getRoute(routeLandmarks.first.routeId!);
      return rt;
    } else {
      final user = await prefs.getUser();
      if (user != null) {
        routesIsolate.getRoutes(user.associationId!);
      }
    }

    return null;
  }

  Future<List<Route>> findNearestRoutes(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    pp('\n\n$mm ............... starting findNearestRoutes ...');
    final start = DateTime.now();
    var routeLandmarks = await findNearestRouteLandmarks(
        latitude: latitude,
        longitude: longitude,
        radiusInMetres: radiusInMetres);
    var rList = <Route>[];
    for (var rk in routeLandmarks) {
      final rt = await listApiDog.getRoute(rk.routeId!);
      if (rt != null) {
        rList.add(rt);
      }
    }
    final end0 = DateTime.now();

    if (rList.isNotEmpty) {
      pp('\n\n$mm ............... found routes from landmarks, '
          '${E.redDot} returning with ${rList.length}  routes...');
      pp('$mm findNearestRoutes: ${rList.length} routes ${E.leaf2}${E.leaf2}${E.leaf2} '
          'time elapsed: ${end0.difference(start).inMilliseconds} milliseconds ${E.redDot}\n\n');
      return rList;
    } else {
      final user = await prefs.getUser();
      if (user != null) {
        routesIsolate.getRoutes(user.associationId!);
      }
    }
    var routePoints = listApiDog.realm.all<RoutePoint>();
    pp('$mm findNearestRoutes, radiusInMetres: $radiusInMetres metres');
    pp('$mm findNearestRoutes, found all points in realm: ${routePoints.length} points');
    final user = await prefs.getUser();
    if (routePoints.isEmpty) {
      final routes = await routesIsolate.getRoutes(user!.associationId!);
      pp('$mm .. routes found ${routes.length}, will try again ...');
      routePoints = listApiDog.realm.all<RoutePoint>();
    }

    final map = HashMap<double, RoutePoint>();
    for (var value in routePoints) {
      final dist = GeolocatorPlatform.instance.distanceBetween(
          latitude,
          longitude,
          value.position!.coordinates[1],
          value.position!.coordinates[0]);

      map[dist] = value;
    }
    pp('$mm hashMap has ${map.length} distances calculated');

    final routes = <Route>[];
    List list = map.keys.toList();
    list.sort();
    pp('$mm hashMap has ${list.length} distances in the list ...');
    if (list.isNotEmpty) {
      for (var distance in list) {
        if (distance <= radiusInMetres) {
          var routeId = map[distance]!.routeId;
          var route = await listApiDog.getRoute(routeId!);
          if (route != null) {
            // pp('$mm .... route ${route.name!} has been found nearby, '
            //     'distance: $distance, vs radiusInMetres: $radiusInMetres ');
            routes.add(route);
          }
        }
      }
    } else {
      pp('$mm hashMap has ${list.length} distances. ${E.redDot} wtf?');
    }
    //
    final map2 = HashMap<String, Route>();
    for (var r in routes) {
      map2[r.routeId!] = r;
    }
    final fList = map2.values.toList();
    pp('$mm findNearestRoutes, found: ${fList.length} routes');
    final end = DateTime.now();
    pp('\n\n$mm findNearestRoutes, ${E.leaf2}${E.leaf2}${E.leaf2} '
        'time elapsed: ${end.difference(start).inSeconds} seconds\n\n');

    return fList;
  }
}
