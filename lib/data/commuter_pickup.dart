import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';

part 'commuter_pickup.g.dart';

@JsonSerializable()
class CommuterPickUp {
  String? commuterPickUpId,
      vehicleId,
      vehicleReg,
      commuterRequestId,
      commuterId,
      commuterEmail,
      created,
      associationId,
      associationName;
  Position? position;


  CommuterPickUp({
      required this.commuterPickUpId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.commuterRequestId,
      required this.commuterId,
      required this.commuterEmail,
      this.created,
      required this.associationId,
      required this.associationName,
      required this.position});

  factory CommuterPickUp.fromJson(Map<String, dynamic> json) =>
      _$CommuterPickUpFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterPickUpToJson(this);
}
