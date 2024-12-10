import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'rank_fee_cash_check_in.g.dart';

@JsonSerializable()
class RankFeeCashCheckIn {
  String? rankFeeCashCheckInId,
      vehicleId,
      vehicleReg,
      associationId,
      associationName;
  double? amount;
  String? userId, userName, created, receiptBucketFileName;
  Position? position;

  RankFeeCashCheckIn(
      {required this.rankFeeCashCheckInId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.associationId,
      required this.associationName,
      required this.amount,
      required this.userId,
      required this.position,
      required this.receiptBucketFileName,
      required this.userName,
      required this.created});

  factory RankFeeCashCheckIn.fromJson(Map<String, dynamic> json) =>
      _$RankFeeCashCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$RankFeeCashCheckInToJson(this);
}
