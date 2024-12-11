import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_library/data/payment_provider.dart';

import 'data_schemas.dart';
part 'commuter_provider_payment.g.dart';

@JsonSerializable()
class CommuterProviderPayment {
  String? commuterProviderPaymentId,
      vehicleId,
      vehicleReg,
      associationId,
      associationName;
  double? amount;
  int? numberOfPassengers;
  String? userId,
      userName,
      created,
      routeId,
      routeName,
      routeLandmarkId,
      landmarkName;
  PaymentProvider paymentProvider;
  Position? position;

  CommuterProviderPayment(
      {required this.commuterProviderPaymentId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.associationId,
      required this.associationName,
      required this.amount,
      required this.numberOfPassengers,
      required this.userId,
      required this.userName,
      this.routeLandmarkId,
      this.landmarkName,
      required this.position,
      required this.routeName,
      required this.routeId,
      required this.paymentProvider,
      required this.created});

  factory CommuterProviderPayment.fromJson(Map<String, dynamic> json) =>
      _$CommuterProviderPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterProviderPaymentToJson(this);
}
