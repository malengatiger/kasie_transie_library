// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commuter_pickup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommuterPickUp _$CommuterPickUpFromJson(Map<String, dynamic> json) =>
    CommuterPickUp(
      commuterPickUpId: json['commuterPickUpId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      commuterRequestId: json['commuterRequestId'] as String?,
      commuterId: json['commuterId'] as String?,
      commuterEmail: json['commuterEmail'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommuterPickUpToJson(CommuterPickUp instance) =>
    <String, dynamic>{
      'commuterPickUpId': instance.commuterPickUpId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'commuterRequestId': instance.commuterRequestId,
      'commuterId': instance.commuterId,
      'commuterEmail': instance.commuterEmail,
      'created': instance.created,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'position': instance.position,
    };
