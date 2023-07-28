
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/data/schemas.dart';

class PassengerCountCover with ClusterItem {
  final LatLng latLng;
  final AmbassadorPassengerCount passengerCount;

  PassengerCountCover({required this.latLng, required this.passengerCount});

  @override
  LatLng get location => latLng;
}
class DispatchRecordCover with ClusterItem {
  final LatLng latLng;
  final DispatchRecord dispatchRecord;

  DispatchRecordCover({required this.latLng, required this.dispatchRecord});

  @override
  LatLng get location => latLng;
}

class CommuterRequestCover with ClusterItem {
  final LatLng latLng;
  final CommuterRequest request;

  CommuterRequestCover({required this.latLng, required this.request});

  @override
  LatLng get location => latLng;
}

class VehicleArrivalCover with ClusterItem {
  final LatLng latLng;
  final VehicleArrival arrival;

  VehicleArrivalCover({required this.latLng, required this.arrival});

  @override
  LatLng get location => latLng;
}

class HeartbeatCover with ClusterItem {
  final LatLng latLng;
  final VehicleHeartbeat heartbeat;

  HeartbeatCover({required this.latLng, required this.heartbeat});

  @override
  LatLng get location => latLng;
}
