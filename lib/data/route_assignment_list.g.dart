// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_assignment_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteAssignmentList _$RouteAssignmentListFromJson(Map<String, dynamic> json) =>
    RouteAssignmentList(
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => RouteAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteAssignmentListToJson(
        RouteAssignmentList instance) =>
    <String, dynamic>{
      'assignments': instance.assignments,
    };
