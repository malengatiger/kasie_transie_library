
import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';

part 'vehicle_list.g.dart';
@JsonSerializable()

class VehicleList {
  String? routeId;
  String? created;
  int? intervalInSeconds;
  List<Vehicle> vehicles = [];

  VehicleList(
      {required this.routeId,
      required this.created,
      required this.intervalInSeconds,
      required this.vehicles});

  factory VehicleList.fromJson(Map<String, dynamic> json) =>
      _$VehicleListFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleListToJson(this);
}
