import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'rank_fee_cash_payment.g.dart';

@JsonSerializable()
class RankFeeCashPayment {
  String? rankFeeCashPaymentId,
      vehicleId,
      vehicleReg,
      associationId,
      associationName;
  double? amount;
  String? userId, userName, created, landmarkName, routeLandmarkId;
  Position? position;

  RankFeeCashPayment(
      {required this.rankFeeCashPaymentId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.associationId,
      required this.associationName,
      required this.amount,
      required this.userId,
      this.routeLandmarkId,
      this.landmarkName,
      required this.userName,
      required this.position,
      required this.created});

  factory RankFeeCashPayment.fromJson(Map<String, dynamic> json) =>
      _$RankFeeCashPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$RankFeeCashPaymentToJson(this);
}
