

import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'route_assignment_list.g.dart';

@JsonSerializable()
class RouteAssignmentList {
  List<RouteAssignment> assignments = [];

  RouteAssignmentList(
      {
      required this.assignments});

  factory RouteAssignmentList.fromJson(Map<String, dynamic> json) =>
      _$RouteAssignmentListFromJson(json);

  Map<String, dynamic> toJson() => _$RouteAssignmentListToJson(this);
}
