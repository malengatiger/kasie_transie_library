// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleList _$VehicleListFromJson(Map<String, dynamic> json) => VehicleList(
      routeId: json['routeId'] as String?,
      created: json['created'] as String?,
      intervalInSeconds: (json['intervalInSeconds'] as num?)?.toInt(),
      vehicles: (json['vehicles'] as List<dynamic>)
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleListToJson(VehicleList instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'created': instance.created,
      'intervalInSeconds': instance.intervalInSeconds,
      'vehicles': instance.vehicles,
    };
