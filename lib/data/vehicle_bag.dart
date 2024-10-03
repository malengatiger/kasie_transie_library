import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'vehicle_bag.g.dart';

@JsonSerializable()

class VehicleBag {
  String? vehicleId;
  String? created;
  List<VehicleArrival> arrivals = [];
  List<DispatchRecord> dispatchRecords = [];
  List<VehicleHeartbeat> heartbeats = [];
  List<VehicleDeparture> departures = [];
  List<AmbassadorPassengerCount> passengerCounts = [];

  VehicleBag(
      {required String vehicleId,
      required String created,
      required this.arrivals,
      required this.departures,
      required this.dispatchRecords,
      required this.passengerCounts,
      required this.heartbeats});
  factory VehicleBag.fromJson(Map<String, dynamic> json) =>
      _$VehicleBagFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleBagToJson(this);
  bool isEmpty() {
    if(dispatchRecords.isEmpty
        && passengerCounts.isEmpty
        && heartbeats.isEmpty
        && departures.isEmpty
        && arrivals.isEmpty) {
      return true;
    }
    return false;
  }
}
