import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/initializer.dart';
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
    pp('$mm findNearestRouteLandmark, found all in realm: ${routeLandmarks.length}');

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
        pp('$mm findNearestRouteLandmarks, found:');
        myPrettyJsonPrint(m!.toJson());
        return m;
      }
    }
    return null;
  }

  Future<List<RouteLandmark>> findNearestRouteLandmarks(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
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
    final lrs = <RouteLandmark>[];
    List list = map.keys.toList();
    list.sort();
    if (list.isNotEmpty) {
      for (var distance in list) {
        if (distance <= radiusInMetres) {
          lrs.add(map[distance]!);
        }
      }
    }
    pp('$mm findNearestRouteLandmarks, found: ${lrs.length}');
    return lrs;
  }

  Future<List<Route>> findNearestRoutes(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final routePoints = listApiDog.realm.all<RoutePoint>();
    pp('$mm findNearestRoutes, radiusInMetres: $radiusInMetres metres');
    pp('$mm findNearestRoutes, found all points in realm: ${routePoints.length} points');
    // final user = await prefs.getUser();
    // if (routePoints.isEmpty) {
    //   await initializer.initialize();
    // }

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
    return fList;
  }
}
