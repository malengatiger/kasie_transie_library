import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'rank_fee_provider_payment.g.dart';

@JsonSerializable()
class RankFeeProviderPayment {
  String? rankFeeProviderPaymentId,
      vehicleId,
      vehicleReg,
      associationId,
      providerId,
      providerName,
      associationName;
  double? amount;
  int? numberOfPassengers;
  String? userId,
      userName,
      created,
      routeLandmarkId,
      landmarkName;

  RankFeeProviderPayment(
      {required this.rankFeeProviderPaymentId,
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
      required this.providerId,
      required this.providerName,
      required this.created});

  factory RankFeeProviderPayment.fromJson(Map<String, dynamic> json) =>
      _$RankFeeProviderPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$RankFeeProviderPaymentToJson(this);
}
