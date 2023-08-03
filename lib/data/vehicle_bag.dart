import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

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

  VehicleBag.fromJson(Map data) {
    vehicleId = data['vehicleId'];
    created = data['created'];
    List va = data['arrivals'];
    for (var value in va) {
      arrivals.add(buildVehicleArrival(value));
    }
    List vd = data['departures'];
    for (var value in vd) {
      departures.add(buildVehicleDeparture(value));
    }
    List vh = data['heartbeats'];
    for (var value in vh) {
      heartbeats.add(buildVehicleHeartbeat(value));
    }
    List di = data['dispatchRecords'];
    for (var value in di) {
      dispatchRecords.add(buildDispatchRecord(value));
    }
    List pc = data['passengerCounts'];
    for (var value in pc) {
      passengerCounts.add(buildAmbassadorPassengerCount(value));
    }
  }
}
