import 'dart:collection';

import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:geolocator/geolocator.dart' as locator;

import '../data/data_schemas.dart';
import '../data/route_data.dart';
import 'functions.dart';

// final DeviceLocationBloc locationBloc = DeviceLocationBloc();

class DeviceLocationBloc {
  final mm = '🍐🍐🍐🍐🍐🍐🍐 DeviceLocationBloc: ';

  Future<locator.Position> getLocation() async {
    bool serviceEnabled;
    locator.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await locator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await locator.Geolocator.checkPermission();
    if (permission == locator.LocationPermission.denied) {
      permission = await locator.Geolocator.requestPermission();
      if (permission == locator.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == locator.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var loc = await locator.Geolocator.getCurrentPosition();
    // pp('$mm ................. getLocation: ${loc.latitude} ${loc.longitude}');
    return loc;
  }

  Future<double> getDistanceFromCurrentPosition(
      {required double latitude, required double longitude}) async {
    var pos = await getLocation();

    var latLngFrom = LatLng(pos.latitude, pos.longitude);
    var latLngTo = LatLng(latitude, longitude);

    var distanceBetweenPoints =
        SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
    var m = distanceBetweenPoints.toDouble();
    pp('$mm getDistanceFromCurrentPosition calculated: $m metres');
    return m;
    return 0.0;
  }

  double getDistance(
      {required double latitude,
      required double longitude,
      required double toLatitude,
      required double toLongitude}) {
    var latLngFrom = LatLng(latitude, longitude);
    var latLngTo = LatLng(toLatitude, toLongitude);

    var distanceBetweenPoints =
        SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
    var m = distanceBetweenPoints.toDouble();
    return m;
  }

  Future<List<Route>> getRouteDistances({
    required AssociationRouteData routeData, required limitMetres
  }) async {
    List<DistanceBag> bags = [];
    List<RoutePoint> routePoints = [];
    for (var rd in routeData.routeDataList) {
      routePoints.addAll(rd.routePoints);
    }
    pp('$mm getRouteDistances: total routePoints: ${routePoints.length}');
    var loc = await getLocation();
    for (var r in routePoints) {
      var dist = getDistance(
          latitude: r.position!.coordinates[1],
          longitude: r.position!.coordinates[0],
          toLatitude: loc.latitude,
          toLongitude: loc.longitude);
      bags.add(DistanceBag(r, dist));
    }
    pp('$mm getRouteDistances: total bags: ${bags.length}');
    bags.sort((a, b) => a.distance.compareTo(b.distance));

    HashMap<String, DistanceBag> hash = HashMap();
    for (var bag in bags) {
      if (hash[bag.routePoint.routeId!] == null) {
        hash[bag.routePoint.routeId!] = bag;
      }
    }
    pp('$mm total hash values: ${hash.values.length}');
    var result = hash.values.toList();
    // for (var r in result) {
    //   pp('$mm getRouteDistances: route distance: ${r.distance} \t - ${r.routePoint.routeName}');
    // }
    List<DistanceBag> finalDistanceBags = [];
    for (var r in result) {
      if (r.distance <= limitMetres) {
        finalDistanceBags.add(r);
        pp('$mm getRouteDistances: route within $limitMetres meters: ${r.distance} \t - ${r.routePoint.routeName}');
      }
    }
    finalDistanceBags.sort((a, b) => a.distance.compareTo(b.distance));
    List<Route> routes = [];
    for (var bag in finalDistanceBags) {
      for (var rd in routeData.routeDataList) {
        if (rd.routeId == bag.routePoint.routeId) {
          routes.add(rd.route!);
        }
      }
    }

    return routes;
  }

  Future<List<LandmarkDistanceBag>> getRouteLandmarkDistances({
    required AssociationRouteData routeData,
  }) async {
    List<LandmarkDistanceBag> bags = [];
    List<RouteLandmark> routeLandmarks = [];
    for (var rd in routeData.routeDataList) {
      routeLandmarks.addAll(rd.landmarks);
    }
    pp('$mm getRouteLandmarkDistances: total routeLandmarks: ${routeLandmarks.length}');
    var loc = await getLocation();
    for (var r in routeLandmarks) {
      var dist = getDistance(
          latitude: r.position!.coordinates[1],
          longitude: r.position!.coordinates[0],
          toLatitude: loc.latitude,
          toLongitude: loc.longitude);
      bags.add(LandmarkDistanceBag(r, dist));
    }
    pp('$mm getRouteLandmarkDistances: total bags: ${bags.length}');
    bags.sort((a, b) => a.distance.compareTo(b.distance));

    HashMap<String, LandmarkDistanceBag> hash = HashMap();
    for (var bag in bags) {
      if (hash[bag.routeLandmark.landmarkId!] == null) {
        hash[bag.routeLandmark.landmarkId!] = bag;
      }
    }
    var filteredDistanceBags = hash.values.toList();
    filteredDistanceBags.sort((a, b) => a.distance.compareTo(b.distance));
    return filteredDistanceBags;
  }

Future<List<RoutePointDistanceBag>> getRoutePointDistances({
  required List<RoutePoint> routePoints,
}) async {
  List<RoutePointDistanceBag> bags = [];
  pp('$mm getRoutePointDistances: total routePoints: ${routePoints.length}');
  var loc = await getLocation();
  for (var r in routePoints) {
    var dist = getDistance(
        latitude: r.position!.coordinates[1],
        longitude: r.position!.coordinates[0],
        toLatitude: loc.latitude,
        toLongitude: loc.longitude);
    bags.add(RoutePointDistanceBag(r, dist));
  }
  pp('$mm getRoutePointDistances: total bags: ${bags.length}');
  bags.sort((a, b) => a.distance.compareTo(b.distance));

  HashMap<String, RoutePointDistanceBag> hash = HashMap();
  for (var bag in bags) {
    if (hash[bag.routePoint.routeId!] == null) {
      hash[bag.routePoint.routeId!] = bag;
    }
  }
  var filteredDistanceBags = hash.values.toList();
  filteredDistanceBags.sort((a, b) => a.distance.compareTo(b.distance));
  return filteredDistanceBags;
}
}

class DistanceBag {
  final RoutePoint routePoint;
  final double distance;

  DistanceBag(this.routePoint, this.distance);
}

class LandmarkDistanceBag {
  final RouteLandmark routeLandmark;
  final double distance;

  LandmarkDistanceBag(this.routeLandmark, this.distance);
}
class RoutePointDistanceBag {
  final RoutePoint routePoint;
  final double distance;

  RoutePointDistanceBag(this.routePoint, this.distance);

}
