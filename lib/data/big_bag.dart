import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class BigBag {
  List<VehicleArrival> vehicleArrivals = [];
  List<DispatchRecord> dispatchRecords = [];
  List<VehicleHeartbeat> vehicleHeartbeats = [];
  List<VehicleDeparture> vehicleDepartures = [];

  BigBag(
      {required this.vehicleArrivals,
      required this.vehicleDepartures,
      required this.dispatchRecords,
      required this.vehicleHeartbeats});

  BigBag.fromJson(Map data) {
    List va = data['vehicleArrivals'];
    for (var value in va) {
      vehicleArrivals.add(buildVehicleArrival(value));
    }
    List vd = data['vehicleDepartures'];
    for (var value in vd) {
      vehicleDepartures.add(buildVehicleDeparture(value));
    }
    List vh = data['vehicleHeartbeats'];
    for (var value in vh) {
      vehicleHeartbeats.add(buildVehicleHeartbeat(value));
    }
    List di = data['dispatchRecords'];
    for (var value in di) {
      dispatchRecords.add(buildDispatchRecord(value));
    }
  }
}
