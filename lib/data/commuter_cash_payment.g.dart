// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commuter_cash_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommuterCashPayment _$CommuterCashPaymentFromJson(Map<String, dynamic> json) =>
    CommuterCashPayment(
      commuterCashPaymentId: json['commuterCashPaymentId'] as String?,
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
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$CommuterCashPaymentToJson(
        CommuterCashPayment instance) =>
    <String, dynamic>{
      'commuterCashPaymentId': instance.commuterCashPaymentId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'amount': instance.amount,
      'numberOfPassengers': instance.numberOfPassengers,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'routeLandmarkId': instance.routeLandmarkId,
      'landmarkName': instance.landmarkName,
      'position': instance.position,
    };
