
import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'big_bag.g.dart';

@JsonSerializable()
class BigBag {
  List<VehicleArrival> vehicleArrivals = [];
  List<DispatchRecord> dispatchRecords = [];
  List<VehicleHeartbeat> vehicleHeartbeats = [];
  List<VehicleDeparture> vehicleDepartures = [];
  List<AmbassadorPassengerCount> passengerCounts = [];


  BigBag({required this.vehicleArrivals,
    required this.vehicleDepartures,
    required this.dispatchRecords,
    required this.passengerCounts,
    required this.vehicleHeartbeats});

  factory BigBag.fromJson(Map<String, dynamic> json) =>
      _$BigBagFromJson(json);

  Map<String, dynamic> toJson() => _$BigBagToJson(this);
}

