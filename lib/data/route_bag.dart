
import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'route_bag.g.dart';

@JsonSerializable()
class RouteBag {
  Route? route;
  List<RoutePoint> routePoints = [];
  List<RouteLandmark> routeLandmarks = [];
  List<RouteCity> routeCities = [];

  RouteBag(this.route, this.routePoints, this.routeLandmarks, this.routeCities);
  factory RouteBag.fromJson(Map<String, dynamic> json) =>
      _$RouteBagFromJson(json);

  Map<String, dynamic> toJson() => _$RouteBagToJson(this);
}

@JsonSerializable()
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

  factory RouteData.fromJson(Map<String, dynamic> json) =>
      _$RouteDataFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDataToJson(this);

}

