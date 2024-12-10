import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';

part 'commuter_cash_check_in.g.dart';

@JsonSerializable()
class CommuterCashCheckIn {
  String? commuterCashCheckInId,
      vehicleId,
      vehicleReg,
      associationId,
      associationName;
  double? amount;
  String? userId, userName, created, receiptBucketFileName;
  Position? position;

  CommuterCashCheckIn(
      {required this.commuterCashCheckInId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.associationId,
      required this.associationName,
      required this.amount,
      required this.userId,
      required this.userName,
      required this.position,
      required this.receiptBucketFileName,
      required this.created});

  factory CommuterCashCheckIn.fromJson(Map<String, dynamic> json) =>
      _$CommuterCashCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterCashCheckInToJson(this);
}
