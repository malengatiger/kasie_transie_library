
import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../data/data_schemas.dart';

part 'distance.g.dart';
@JsonSerializable()

class RouteDistanceEstimation {
  String?  routeId, routeName, nearestLandmarkName, nearestLandmarkId;
  List<DynamicDistance>? dynamicDistances;
  double? distanceToNearestLandmark;
  String? created;
  Vehicle? vehicle;

  RouteDistanceEstimation(
      {this.routeId,
      this.routeName,
      this.dynamicDistances,
      this.nearestLandmarkId,
      this.nearestLandmarkName,
      this.created,
      this.vehicle,
      this.distanceToNearestLandmark});

  factory RouteDistanceEstimation.fromJson(Map<String, dynamic> json) =>
      _$RouteDistanceEstimationFromJson(json);

  Map<String, dynamic> toJson() => _$RouteDistanceEstimationToJson(this);
  printString() {
    var sb = StringBuffer();
    sb.write(
        '🍎🍎  distanceToNearestLandmark : $distanceToNearestLandmark'
            ' metres : 🍏 $nearestLandmarkName  🍀🍀 ROUTE: $routeName 🍀🍀');
    if (dynamicDistances!.isEmpty) {
      sb.write(
          '\n🌼🌼 The vehicle or user is at the end of the route: 🌼 $nearestLandmarkName');
    }
    pp(sb.toString());
    for (var dd in dynamicDistances!) {
      dd.printString();
    }
//    print('🌼 🌼 🌼 🌼 🌼 🌼  End of Estimation\n');
  }
}

@JsonSerializable()

class DynamicDistance {
  double? distanceInMetres, distanceInKM;
  String? landmarkName, landmarkId, date, routeName;

  DynamicDistance(
      {this.distanceInMetres,
      this.distanceInKM,
      this.landmarkName,
      this.landmarkId,
      this.routeName,
      this.date});

  printString() {
    var sb = StringBuffer();
    sb.write('🍎 🍎 DynamicDistance: 🐸 $distanceInKM km to  🍏 $landmarkName \t on route: $routeName');
    pp(sb.toString());
  }

  factory DynamicDistance.fromJson(Map<String, dynamic> json) =>
      _$DynamicDistanceFromJson(json);

  Map<String, dynamic> toJson() => _$DynamicDistanceToJson(this);
}
