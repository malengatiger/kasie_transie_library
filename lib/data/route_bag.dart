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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['route'] = route!.toJson();
    List points = [];
    List marks = [];
    List cities = [];
    routePoints..forEach((m) {
      points.add(m.toJson());
    });
    routeLandmarks.forEach((m) {
      marks.add(m.toJson());
    });
    routeCities..forEach((m) {
      cities.add(m.toJson());
    });
    map['routePoints'] = points;
    map['routeLandmarks'] = marks;
    map['routeCities'] = cities;
    return map;
  }
}

class RouteData {
  List<Route> routes = [];
  List<RoutePoint> routePoints = [];
  List<RouteLandmark> landmarks = [];
  List<RouteCity> cities = [];


  RouteData(
      {required this.routes,
        required this.routePoints,
        required this.landmarks,
        required this.cities});

  RouteData.fromJson(Map data) {
    List rpList = data['routes'];
    for (var value in rpList) {
      routes.add(buildRoute(value));
    }
    List rList = data['routePoints'];
    for (var value in rList) {
      routePoints.add(buildRoutePoint(value));
    }
    List mList = data['landmarks'];
    for (var value in mList) {
      landmarks.add(buildRouteLandmark(value));
    }
    List cList = data['cities'];
    for (var value in cList) {
      cities.add(buildRouteCity(value));
    }
  }


}

