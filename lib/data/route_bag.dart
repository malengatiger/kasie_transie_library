import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'route_bag.g.dart';

@JsonSerializable(explicitToJson: true)
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


