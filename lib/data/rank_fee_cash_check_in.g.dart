// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_fee_cash_check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RankFeeCashCheckIn _$RankFeeCashCheckInFromJson(Map<String, dynamic> json) =>
    RankFeeCashCheckIn(
      rankFeeCashCheckInId: json['rankFeeCashCheckInId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      userId: json['userId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      receiptBucketFileName: json['receiptBucketFileName'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$RankFeeCashCheckInToJson(RankFeeCashCheckIn instance) =>
    <String, dynamic>{
      'rankFeeCashCheckInId': instance.rankFeeCashCheckInId,
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
