// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_bag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteBag _$RouteBagFromJson(Map<String, dynamic> json) => RouteBag(
      json['route'] == null
          ? null
          : Route.fromJson(json['route'] as Map<String, dynamic>),
      (json['routePoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['routeLandmarks'] as List<dynamic>)
          .map((e) => RouteLandmark.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['routeCities'] as List<dynamic>)
          .map((e) => RouteCity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteBagToJson(RouteBag instance) => <String, dynamic>{
      'route': instance.route,
      'routePoints': instance.routePoints,
      'routeLandmarks': instance.routeLandmarks,
      'routeCities': instance.routeCities,
    };

RouteData _$RouteDataFromJson(Map<String, dynamic> json) => RouteData(
      routes: (json['routes'] as List<dynamic>)
          .map((e) => Route.fromJson(e as Map<String, dynamic>))
          .toList(),
      routePoints: (json['routePoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      landmarks: (json['landmarks'] as List<dynamic>)
          .map((e) => RouteLandmark.fromJson(e as Map<String, dynamic>))
          .toList(),
      cities: (json['cities'] as List<dynamic>)
          .map((e) => RouteCity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteDataToJson(RouteData instance) => <String, dynamic>{
      'routes': instance.routes,
      'routePoints': instance.routePoints,
      'landmarks': instance.landmarks,
      'cities': instance.cities,
    };
