import 'dart:convert';

import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class RouteBag {
  Route? route;
  List<RoutePoint> routePoints = [];
  List<RouteLandmark> routeLandmarks = [];
  List<RouteCity> routeCities = [];

  RouteBag(this.route, this.routePoints, this.routeLandmarks, this.routeCities);

  RouteBag.fromJson(Map data) {
    route = buildRoute(data['route']);
    List rpList = data['routePoints'];
    for (var value in rpList) {
      routePoints.add(buildRoutePoint(value));
    }
    List rlList = data['routeLandmarks'];
    for (var value in rlList) {
      routeLandmarks.add(buildRouteLandmark(value));
    }
    List rcList = data['routeCities'];
    for (var value in rcList) {
      routeCities.add(buildRouteCity(value));
    }
  }
}

class RouteBagList {
  List<RouteBag> routeBags = [];
  RouteBagList(this.routeBags);

  RouteBagList.fromJson(Map data) {
    List rpList = data['routeBags'];
    for (var value in rpList) {
      routeBags.add(RouteBag.fromJson(value));
    }
  }


}

