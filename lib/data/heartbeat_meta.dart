import 'package:json_annotation/json_annotation.dart';

part 'heartbeat_meta.g.dart';
@JsonSerializable()

class HeartbeatMeta {
  String? vehicleId;
  String? associationId;
  String? ownerId;
  String? vehicleReg;
  double? latitude;
  double? longitude;

  HeartbeatMeta(
      {required this.vehicleId,
      required this.associationId,
      required this.ownerId,
      required this.vehicleReg,
      required this.latitude,
      required this.longitude});

  factory HeartbeatMeta.fromJson(Map<String, dynamic> json) =>
      _$HeartbeatMetaFromJson(json);

  Map<String, dynamic> toJson() => _$HeartbeatMetaToJson(this);
}
@JsonSerializable()
class HeartbeatTimeSeries {
  late DateTime created;
  late HeartbeatMeta heartbeatMeta;

  HeartbeatTimeSeries({required this.created, required this.heartbeatMeta});

  factory HeartbeatTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$HeartbeatTimeSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$HeartbeatTimeSeriesToJson(this);
}
