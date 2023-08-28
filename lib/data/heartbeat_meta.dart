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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['vehicleId'] = vehicleId;
    map['associationId'] = associationId;
    map['ownerId'] = ownerId;
    map['vehicleReg'] = vehicleReg;
    map['latitude'] = latitude;
    map['longitude'] = longitude;

    return map;
  }

  HeartbeatMeta.fromJson(Map map) {
    vehicleId = map['vehicleId'];
    associationId = map['associationId'];
    ownerId = map['ownerId'];
    vehicleReg = map['vehicleReg'];
    latitude = map['latitude'];
    longitude = map['longitude'];
  }
}

class HeartbeatTimeSeries {
  late DateTime created;
  late HeartbeatMeta heartbeatMeta;

  HeartbeatTimeSeries({required this.created, required this.heartbeatMeta});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['heartbeatMeta'] = heartbeatMeta.toJson();
    map['created'] = DateTime.parse(created.toLocal().toIso8601String());

    return map;
  }
}
