// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heartbeat_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeartbeatMeta _$HeartbeatMetaFromJson(Map<String, dynamic> json) =>
    HeartbeatMeta(
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      ownerId: json['ownerId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HeartbeatMetaToJson(HeartbeatMeta instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'ownerId': instance.ownerId,
      'vehicleReg': instance.vehicleReg,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

HeartbeatTimeSeries _$HeartbeatTimeSeriesFromJson(Map<String, dynamic> json) =>
    HeartbeatTimeSeries(
      created: DateTime.parse(json['created'] as String),
      heartbeatMeta:
          HeartbeatMeta.fromJson(json['heartbeatMeta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HeartbeatTimeSeriesToJson(
        HeartbeatTimeSeries instance) =>
    <String, dynamic>{
      'created': instance.created.toIso8601String(),
      'heartbeatMeta': instance.heartbeatMeta,
    };
