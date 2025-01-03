import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';

part 'commuter_cash_payment.g.dart';

@JsonSerializable()
class CommuterCashPayment {
  String? commuterCashPaymentId,
      vehicleId,
      vehicleReg,
      associationId,
      associationName;
  double? amount;
  int? numberOfPassengers;
  String? userId,
      tripId,
      userName,
      created,
      routeId,
      routeName,
      routeLandmarkId,
      landmarkName;
  Position? position;

  CommuterCashPayment(
      {required this.commuterCashPaymentId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.associationId,
      required this.associationName,
      required this.amount,
      required this.numberOfPassengers,
      required this.userId,
      required this.userName,
      required this.tripId,
      this.routeLandmarkId,
      this.landmarkName,
      required this.position,
      required this.routeName,
      required this.routeId,
      required this.created});

  factory CommuterCashPayment.fromJson(Map<String, dynamic> json) =>
      _$CommuterCashPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterCashPaymentToJson(this);
}
