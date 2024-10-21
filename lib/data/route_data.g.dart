// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssociationRouteData _$AssociationRouteDataFromJson(
        Map<String, dynamic> json) =>
    AssociationRouteData(
      (json['routeDataList'] as List<dynamic>)
          .map((e) => RouteData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['associationId'] as String?,
    );

Map<String, dynamic> _$AssociationRouteDataToJson(
        AssociationRouteData instance) =>
    <String, dynamic>{
      'associationId': instance.associationId,
      'routeDataList': instance.routeDataList.map((e) => e.toJson()).toList(),
    };

RouteData _$RouteDataFromJson(Map<String, dynamic> json) => RouteData(
      routeId: json['routeId'] as String?,
      route: json['route'] == null
          ? null
          : Route.fromJson(json['route'] as Map<String, dynamic>),
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
      'routeId': instance.routeId,
      'route': instance.route?.toJson(),
      'routePoints': instance.routePoints.map((e) => e.toJson()).toList(),
      'landmarks': instance.landmarks.map((e) => e.toJson()).toList(),
      'cities': instance.cities.map((e) => e.toJson()).toList(),
    };
