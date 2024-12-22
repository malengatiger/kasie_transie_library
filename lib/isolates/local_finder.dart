import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/utils/emojis.dart';

import '../bloc/list_api_dog.dart';
import '../data/data_schemas.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

final LocalFinder localFinder = LocalFinder();

class LocalFinder {
  final mm = '😎😎😎😎😎😎😎 LocalFinder 😎😎';
  final ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  final Prefs prefs = GetIt.instance<Prefs>();

  Future<RouteLandmark?> findNearestRouteLandmark(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final routeLandmarks = <RouteLandmark>[];

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
        pp('$mm findNearestRouteLandmarks, found: ${E.redDot} ${m!.landmarkName} route: ${m.routeName}');
        return m;
      }
    }
    return null;
  }

  Future<RoutePoint?> findNearestRoutePoint(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final routePoints = <RoutePoint>[];

    final map = HashMap<double, RoutePoint>();
    for (var value in routePoints) {
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
        pp('$mm findNearestRoutePoint, found: ${E.redDot} index: ${m!.index} route: ${m.routeName}');
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

    final routeLandmarks = <RouteLandmark>[];
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
      final rt = await listApiDog.getRoute(routeId: routeLandmarks.first.routeId!, refresh:   false);
      return rt;
    } else {
      final user = prefs.getUser();
      if (user != null) {
        var routesIsolate = GetIt.instance<SemCache>();
        routesIsolate.getRoutes(associationId: user.associationId!);
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
    var map = HashMap<String, Route>();
    for (var rk in routeLandmarks) {
      final rt = await listApiDog.getRoute(routeId: rk.routeId!, refresh: false);
      if (rt != null) {
        map[rt.routeId!] = rt;
      }
    }
    rList = map.values.toList();
    final end0 = DateTime.now();
    if (rList.isNotEmpty) {
      pp('\n\n$mm ............... found routes from landmarks, '
          '${E.redDot} returning with ${rList.length}  routes...');
      pp('$mm findNearestRoutes: ${rList.length} routes ${E.leaf2}${E.leaf2}${E.leaf2} '
          'time elapsed: ${end0.difference(start).inMilliseconds} milliseconds ${E.redDot}\n\n');
      return rList;
    } else {
      final user = prefs.getUser();
      if (user != null) {
        var routesIsolate = GetIt.instance<SemCache>();
        rList =
            await routesIsolate.getRoutes(associationId: user.associationId!);
      }
      final comm = prefs.getCommuter();
      if (comm != null) {
        rList = await listApiDog.findRoutesByLocation(LocationFinderParameter(
            latitude: latitude,
            limit: 2000,
            longitude: longitude,
            radiusInKM: radiusInMetres / 1000,
            associationId: user!.associationId!));
      }
    }
    return rList;
  }

  Future<List<City>> findNearestCities(
      {required double latitude,
      required double longitude,
      required double radiusInMetres}) async {
    final start = DateTime.now();

    final cities = <City>[];
    pp('$mm findNearestCities, found all in realm: ${cities.length}');

    final map = HashMap<double, City>();
    for (var value in cities) {
      final dist = GeolocatorPlatform.instance.distanceBetween(
          latitude,
          longitude,
          value.position!.coordinates[1],
          value.position!.coordinates[0]);
      if (dist <= radiusInMetres) {
        map[dist] = value;
      }
    }
    pp('$mm findNearestCities, ${E.appleRed} cities found within radius: ${map.length}');

    final cityDistances = <CityDistance>[];
    map.forEach((key, value) {
      final cd = CityDistance(key, value);
      cityDistances.add(cd);
    });
    cityDistances
        .sort((a, b) => a.distanceInMetres.compareTo(b.distanceInMetres));
    var citiesFound = <City>[];

    if (cityDistances.isNotEmpty) {
      for (var distance in cityDistances) {
        citiesFound.add(distance.city);
      }
    }

    pp('$mm findNearestCities, found: ${citiesFound.length}');
    final end = DateTime.now();

    pp('\n\n$mm findNearestCities, ${E.leaf2}${E.leaf2}${E.leaf2} '
        'time elapsed: ${end.difference(start).inMilliseconds} milliseconds ${E.redDot}\n\n');

    return citiesFound;
  }
}

class CityDistance {
  late double distanceInMetres;
  late City city;

  CityDistance(this.distanceInMetres, this.city);
}

class LocationFinderParameter {
  late double latitude;
  late int limit;
  late double longitude;
  late double radiusInKM;
  late String associationId;

  LocationFinderParameter(
      {required this.associationId,
      required this.latitude,
      required this.limit,
      required this.longitude,
      required this.radiusInKM});
}
