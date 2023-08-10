import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class VehicleList {
  String? routeId;
  String? created;
  int? intervalInSeconds;
  List<Vehicle> vehicles = [];

  VehicleList(
      {required this.routeId,
      required this.created,
      required this.intervalInSeconds,
      required this.vehicles});

  VehicleList.fromJson(Map data) {
    routeId = data['routeId'];
    created = data['created'];
    intervalInSeconds = data['intervalInSeconds'];

    List va = data['vehicles'];
    for (var value in va) {
      vehicles.add(buildVehicle(value));
    }
  }
  Map<String, dynamic> toJson() {
    List cars = [];
    for (var value in vehicles) {
      cars.add(value.toJson());
    }
    final map = {
      'routeId': routeId,
      'created': created,
      'vehicles': cars,
    };
    return map;
  }
}
