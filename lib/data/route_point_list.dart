
import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'route_point_list.g.dart';

@JsonSerializable()

class RoutePointList {
  List<RoutePoint> routePoints = [];

  RoutePointList(this.routePoints);
  factory RoutePointList.fromJson(Map<String, dynamic> json) =>
      _$RoutePointListFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointListToJson(this);
}
