// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteDistanceEstimation _$RouteDistanceEstimationFromJson(
        Map<String, dynamic> json) =>
    RouteDistanceEstimation(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      dynamicDistances: (json['dynamicDistances'] as List<dynamic>?)
          ?.map((e) => DynamicDistance.fromJson(e as Map<String, dynamic>))
          .toList(),
      nearestLandmarkId: json['nearestLandmarkId'] as String?,
      nearestLandmarkName: json['nearestLandmarkName'] as String?,
      created: json['created'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      distanceToNearestLandmark:
          (json['distanceToNearestLandmark'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RouteDistanceEstimationToJson(
        RouteDistanceEstimation instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'nearestLandmarkName': instance.nearestLandmarkName,
      'nearestLandmarkId': instance.nearestLandmarkId,
      'dynamicDistances': instance.dynamicDistances,
      'distanceToNearestLandmark': instance.distanceToNearestLandmark,
      'created': instance.created,
      'vehicle': instance.vehicle,
    };

DynamicDistance _$DynamicDistanceFromJson(Map<String, dynamic> json) =>
    DynamicDistance(
      distanceInMetres: (json['distanceInMetres'] as num?)?.toDouble(),
      distanceInKM: (json['distanceInKM'] as num?)?.toDouble(),
      landmarkName: json['landmarkName'] as String?,
      landmarkId: json['landmarkId'] as String?,
      routeName: json['routeName'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$DynamicDistanceToJson(DynamicDistance instance) =>
    <String, dynamic>{
      'distanceInMetres': instance.distanceInMetres,
      'distanceInKM': instance.distanceInKM,
      'landmarkName': instance.landmarkName,
      'landmarkId': instance.landmarkId,
      'date': instance.date,
      'routeName': instance.routeName,
    };
