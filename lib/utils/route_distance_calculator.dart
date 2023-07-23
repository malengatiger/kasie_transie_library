import 'dart:core';
import 'dart:core' as prefix0;

import 'package:geolocator/geolocator.dart' as geo;
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/calculated_distance_list.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';

import '../isolates/routes_isolate.dart';
import 'distance.dart';

final RouteDistanceCalculator routeDistanceCalculator =
    RouteDistanceCalculator();

class RouteDistanceCalculator {
  static const mm = '🌸🌸🌸🌸 RouteDistanceCalculator: 🌸🌸🌸';

  Future calculateAssociationRouteDistances() async {
    pp('... starting ... calculateAssociationRouteDistances ...');
    final user = await prefs.getUser();
    final routes = await listApiDog
        .getRoutes(AssociationParameter(user!.associationId!, false));
    final distances = <lib.CalculatedDistance>[];
    for (var value in routes) {
      final list =
          (await calculateRouteDistances(value.routeId!, user.associationId!));
      distances.addAll(list);
      pp('... added ${list.length} route distances for route: ${value.name} ...');
    }
    //print
    int cnt = 1;
    pp('\n\n$mm ROUTE DISTANCES CALCULATED .............');
    for (var d in distances) {
      pp('$mm #$cnt route distance: ');
      myPrettyJsonPrint(d.toJson());
      cnt++;
    }
  }

  Future<List<lib.CalculatedDistance>> calculateRouteDistances(
      String routeId, String associationId) async {
    pp('$mm ... starting calculateRouteDistances for $routeId');

    final routeLandmarks = await listApiDog.getRouteLandmarks(routeId, false);
    if (routeLandmarks.isEmpty) {
      pp('$mm ... 1. stopping calculateRouteDistances for $routeId, no routeLandmarks');
      return [];
    }

    routeLandmarks.sort((a,b) => a.index!.compareTo(b.index!));
    final routePoints = await routesIsolate.getRoutePoints(routeId, false);
    if (routePoints.isEmpty) {
      pp('$mm ... 2. stopping calculateRouteDistances for $routeId, routePoints');
      return [];
    }

    //
    pp('\n\n$mm ... calculateRouteDistances for ${routeLandmarks.length} routeLandmarks');
    pp('$mm ... calculateRouteDistances for ${routePoints.length} points');

    //
    routePoints.sort((a, b) => a.index!.compareTo(b.index!));
    final distances = <lib.CalculatedDistance>[];
    lib.RouteLandmark? prevRouteLandmark;
    int index = 0;
    double mDistance = 0;
    //
    for (var routeLandmark in routeLandmarks) {
      if (index == 0) {
        prevRouteLandmark = routeLandmark;
        index++;
      } else {
        final dist = await _calculateDistanceBetween(
            fromLandmark: prevRouteLandmark!,
            toLandmark: routeLandmark,
            routePoints: routePoints);

        mDistance += dist;

        final m = lib.CalculatedDistance(
          ObjectId(),
          distanceInMetres: dist,
          routeId: routeId,
          index: index - 1,
          associationId: associationId,
          routeName: routeLandmark.routeName,
          fromLandmark: prevRouteLandmark.landmarkName,
          fromRoutePointIndex: prevRouteLandmark.routePointIndex,
          distanceFromStart: mDistance,
          fromLandmarkId: prevRouteLandmark.landmarkId,
          toLandmark: routeLandmark.landmarkName,
          toLandmarkId: routeLandmark.landmarkId,
          toRoutePointIndex: routeLandmark.routePointIndex,
        );
        distances.add(m);
        prevRouteLandmark = routeLandmark;
        index++;
      }
    }
    pp('\n\n$mm update the route with total distance: $mDistance metres');
    pp('$mm update the route with distances between landmarks: ${distances.length}');
    pp('$mm route: ${routeLandmarks.first.routeName}');

    for (var calcDistance in distances) {
      pp('$mm calculated distance: ${calcDistance.distanceInMetres} '
          '${E.pear} distanceFromStart: ${calcDistance.distanceFromStart}'
          ' ${E.appleRed} ${calcDistance.fromLandmark} - ${calcDistance.toLandmark}');
    }
    await dataApiDog.addCalculatedDistances(CalculatedDistanceList(distances));
    return distances;
  }

  Future<double> _calculateDistanceBetween(
      {required lib.RouteLandmark fromLandmark,
      required lib.RouteLandmark toLandmark,
      required List<lib.RoutePoint> routePoints}) async {
    pp('$mm ... _calculateDistanceBetween ${fromLandmark.landmarkName} ${E.heartBlue} index: ${fromLandmark.routePointIndex} '
        'and ${toLandmark.landmarkName}  ${E.heartBlue} index: ${toLandmark.routePointIndex}');

    Iterable<lib.RoutePoint> range = [];
    try {
      range = routePoints.getRange(
          fromLandmark.routePointIndex!, toLandmark.routePointIndex!);
      pp('$mm ... range of points between: ${range.length}');
    } catch (e) {
      range = routePoints.getRange(
          fromLandmark.routePointIndex!, routePoints.length - 1);
      pp(e);
    }

    lib.RoutePoint? prevPoint;
    double mDistance = 0.0;
    for (var pointBetween in range) {
      if (prevPoint == null) {
        prevPoint = pointBetween;
      } else {
        var distance = geo.GeolocatorPlatform.instance.distanceBetween(
            prevPoint.latitude!,
            prevPoint.longitude!,
            pointBetween.latitude!,
            pointBetween.longitude!);
        distance = distance.roundToDouble();
        mDistance += distance;
        prevPoint = pointBetween;
      }
    }
    pp('$mm ... returning calculate Distance for the pair: $mDistance metres');

    return mDistance;
  }

  Future<List<RoutePointDistance>> calculateFromLocation(
      {required double latitude,
      required double longitude,
      required lib.Route route}) async {
    pp('🥬🥬🥬🥬🥬🥬🥬 calculateFromLocation starting: 💛 ${DateTime.now().toIso8601String()}');
    final routePoints = await routesIsolate.getRoutePoints(route.routeId!, false);

    pp('🥬🥬🥬🥬🥬🥬🥬  ${route.name} points: ${routePoints.length}');
    List<RoutePointDistance> rpdList = [];
    // Geolocator geoLocator = Geolocator();

    var index = 0;

    for (var point in routePoints) {
      var dist = geo.GeolocatorPlatform.instance.distanceBetween(
          latitude, longitude, point.latitude!, point.longitude!);
      point.index = index;
      rpdList.add(
          RoutePointDistance(index: index, routePoint: point, distance: dist));
      index++;
    }

    pp('...... Distances calculated from each route point to this location:  💙 ${rpdList.length}  💙');
    rpdList.sort((a, b) => a.distance.compareTo(b.distance));
    List<RoutePointDistance> marks = [];

    if (marks.isEmpty) {}
    var nearestRoutePoint = rpdList.first;
    pp('🚨 nearestRoutePoint: ${nearestRoutePoint.distance} metres 🍎 index: ${nearestRoutePoint.routePoint.index}');

    pp('💛💛💛💛 ${marks.length} dynamic distances calculated');

    pp('🥬🥬🥬🥬🥬🥬🥬 calculateFromLocation DONE!: 💛 ${DateTime.now().toIso8601String()}');
    return marks;
  }

  Future<List<DynamicDistance>> _traversePoints(
      {required List<lib.RoutePoint> points, required int startIndex}) async {
    pp('_traversePoints :  🔆  🔆  🔆  🔆 calculating distances between points from  🔆 index: $startIndex ...');
    // var geoLocator = Geolocator();
    List<DynamicDistance> list = [];
    List<RoutePointDistance> rpList = [];
    var cnt = 0;
    lib.RoutePoint? prevPoint;
    for (var i = startIndex; i < points.length; i++) {
      if (prevPoint == null) {
        prevPoint = points.elementAt(i);
      } else {
        var distance = geo.GeolocatorPlatform.instance.distanceBetween(
            prevPoint.latitude!,
            prevPoint.longitude!,
            points.elementAt(i).latitude!,
            points.elementAt(i).longitude!);
        rpList.add(RoutePointDistance(
            index: i, routePoint: points.elementAt(i), distance: distance));
        prevPoint = points.elementAt(i);
        cnt++;
      }
    }
    pp('🥬🥬🥬🥬🥬🥬🥬 Calculated 🍎 $cnt 🍎 distances between route points');
    var tot = 0.0;
    cnt = 0;
    for (var rp in rpList) {
      tot += rp.distance;
      cnt++;
      // if (rp.routePoint.landmarkId != null) {
      //   list.add(DynamicDistance(
      //     landmarkId: rp.routePoint.landmarkId,
      //     landmarkName: rp.routePoint.landmarkName,
      //     date: DateTime.now().toLocal().toIso8601String(),
      //   ));
      //   cnt = 0;
      // }
    }

    return list;
  }

  Future<double> calculateRouteLengthInKM(String routeId) async {
    final routePoints = await routesIsolate.getRoutePoints(routeId, false);
    if (routePoints.isEmpty) {
      pp('$mm ... 2. stopping calculateRouteLengthInKM for $routeId, routePoints');
      return 0;
    }
    //
    pp('$mm ... calculateRouteLengthInKM for ${routePoints.length} points');
    routePoints.sort((a, b) => a.index!.compareTo(b.index!));
    lib.RoutePoint? prevRoutePoint;
    int index = 0;
    double totalDistance = 0;
    //
    for (var routePoint in routePoints) {
      if (index == 0) {
        prevRoutePoint = routePoint;
        index++;
      } else {
        final dist = geo.GeolocatorPlatform.instance.distanceBetween(
            prevRoutePoint!.position!.coordinates[1],
            prevRoutePoint.position!.coordinates[0],
          routePoint.position!.coordinates[1],
          routePoint.position!.coordinates[0],
        );
        totalDistance += dist;
        prevRoutePoint = routePoint;
        index++;
      }
    }
    pp('$mm ... calculateRouteLengthInKM: length: $totalDistance metres');
    pp('$mm ... calculateRouteLengthInKM length: ${(totalDistance/1000).toStringAsFixed(2)} km');

    var b = totalDistance /1000;
    b = double.parse(b.toStringAsFixed(2));
    return b;
  }

}

class RoutePointDistance {
  int index;
  lib.RoutePoint routePoint;
  double distance;

  RoutePointDistance(
      {required this.index, required this.routePoint, required this.distance});
}

