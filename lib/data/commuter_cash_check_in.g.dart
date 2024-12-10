// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commuter_cash_check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommuterCashCheckIn _$CommuterCashCheckInFromJson(Map<String, dynamic> json) =>
    CommuterCashCheckIn(
      commuterCashCheckInId: json['commuterCashCheckInId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      receiptBucketFileName: json['receiptBucketFileName'] as String?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$CommuterCashCheckInToJson(
        CommuterCashCheckIn instance) =>
    <String, dynamic>{
      'commuterCashCheckInId': instance.commuterCashCheckInId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'amount': instance.amount,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'receiptBucketFileName': instance.receiptBucketFileName,
      'position': instance.position,
    };
