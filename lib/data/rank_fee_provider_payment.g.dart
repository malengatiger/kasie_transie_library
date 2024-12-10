// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_fee_provider_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RankFeeProviderPayment _$RankFeeProviderPaymentFromJson(
        Map<String, dynamic> json) =>
    RankFeeProviderPayment(
      rankFeeProviderPaymentId: json['rankFeeProviderPaymentId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      numberOfPassengers: (json['numberOfPassengers'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      routeLandmarkId: json['routeLandmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      providerId: json['providerId'] as String?,
      providerName: json['providerName'] as String?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$RankFeeProviderPaymentToJson(
        RankFeeProviderPayment instance) =>
    <String, dynamic>{
      'rankFeeProviderPaymentId': instance.rankFeeProviderPaymentId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'associationName': instance.associationName,
      'amount': instance.amount,
      'numberOfPassengers': instance.numberOfPassengers,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'routeLandmarkId': instance.routeLandmarkId,
      'landmarkName': instance.landmarkName,
    };
