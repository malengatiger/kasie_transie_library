// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_fee_cash_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RankFeeCashPayment _$RankFeeCashPaymentFromJson(Map<String, dynamic> json) =>
    RankFeeCashPayment(
      rankFeeCashPaymentId: json['rankFeeCashPaymentId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      userId: json['userId'] as String?,
      routeLandmarkId: json['routeLandmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      userName: json['userName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      created: json['created'] as String?,
    );

Map<String, dynamic> _$RankFeeCashPaymentToJson(RankFeeCashPayment instance) =>
    <String, dynamic>{
      'rankFeeCashPaymentId': instance.rankFeeCashPaymentId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'amount': instance.amount,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'landmarkName': instance.landmarkName,
      'routeLandmarkId': instance.routeLandmarkId,
      'position': instance.position,
    };
