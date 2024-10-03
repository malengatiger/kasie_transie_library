// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointList _$RoutePointListFromJson(Map<String, dynamic> json) =>
    RoutePointList(
      (json['routePoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoutePointListToJson(RoutePointList instance) =>
    <String, dynamic>{
      'routePoints': instance.routePoints,
    };
