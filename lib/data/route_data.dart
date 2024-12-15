import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'route_data.g.dart';

@JsonSerializable(explicitToJson: true)
class AssociationRouteData {
  String? associationId;
  List<RouteData> routeDataList = [];

  AssociationRouteData(this.routeDataList, this.associationId);
  factory AssociationRouteData.fromJson(Map<String, dynamic> json) =>
      _$AssociationRouteDataFromJson(json);

  Map<String, dynamic> toJson() => _$AssociationRouteDataToJson(this);

  // Map<String, dynamic> toJson() {
  //   var map = <String, dynamic>{};
  //
  //   map['associationId'] = associationId;
  //   List mList = [];
  //   for (var rd in routeDataList) {
  //     mList.add(rd.toJson());
  //   }
  //   map['routeData'] = mList;
  //   return map;
  // }
  //
  // AssociationRouteData.fromJson(Map<String, dynamic> json) {
  //   associationId = json['associationId'];
  //   List mList = json['routeDataList'];
  //   for (var m in mList) {
  //     routeDataList.add(RouteData.fromJson(m));
  //   }
  // }
}

@JsonSerializable(explicitToJson: true)
class RouteData {
  String? routeId;
  Route? route;
  List<RoutePoint> routePoints = [];
  List<RouteLandmark> landmarks = [];
  List<RouteCity> cities = [];

  RouteData(
      {required this.routeId,
      required this.route,
      required this.routePoints,
      required this.landmarks,
      required this.cities});

  // RouteData.fromJson(Map<String, dynamic> json) {
  //   routeId = json['routeId'];
  //   route = Route.fromJson(json['route']);
  //
  //   List mLandmarks = json['landmarks'];
  //
  //   for (var mr in mLandmarks) {
  //     landmarks.add(RouteLandmark.fromJson(mr));
  //   }
  //   List mCities = json['cities'];
  //   for (var mr in mCities) {
  //     cities.add(RouteCity.fromJson(mr));
  //   }
  //   List mRoutePoints = json['routePoints'];
  //   for (var mr in mRoutePoints) {
  //     routePoints.add(RoutePoint.fromJson(mr));
  //   }
  // }
  // Map<String, dynamic> toJson() {
  //   var map = <String, dynamic>{};
  //   var mRoute = route?.toJson();
  //
  //   map['route'] = mRoute;
  //   map['routeId'] = routeId;
  //
  //   List mLandmarks = [];
  //   for (var value in landmarks) {
  //     mLandmarks.add(value.toJson());
  //   }
  //   map['landmarks'] = mLandmarks;
  //
  //   List mCities = [];
  //   for (var value in cities) {
  //     mCities.add(value.toJson());
  //   }
  //   map['cities'] = mCities;
  //
  //   List mRoutePoints = [];
  //   for (var value in routePoints) {
  //     mRoutePoints.add(value.toJson());
  //   }
  //   map['routePoints'] = mRoutePoints;
  //   return map;
  // }
  factory RouteData.fromJson(Map<String, dynamic> json) =>
      _$RouteDataFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDataToJson(this);
}
