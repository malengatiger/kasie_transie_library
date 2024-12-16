import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/route_data.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:uuid/v4.dart';

import 'list_api_dog.dart';

class VehicleTelemetryService {
  late Timer timer;
  late DeviceLocationBloc locationBloc;
  late Prefs prefs;
  late ListApiDog listApiDog;
  List<lib.Route> routes = [];
  AssociationRouteData? routeData;
  late DataApiDog dataApiDog;

  final StreamController<lib.VehicleTelemetry> _telemetryController =
  StreamController.broadcast();

  Stream<lib.VehicleTelemetry> get telemetryStream =>
      _telemetryController.stream;
  static const minutes = 1;

  static const mm = '🍎🍎🍎🍎 VehicleTelemetryService 🍎🍎';

  init() {
    pp('\n\n$mm initialize Timer for telemetry');

    timer = Timer.periodic(const Duration(minutes: minutes), (timer) {
      pp('\n\n$mm Timer tick ${timer.tick} - create telemetry');
      createTelemetry();
    });
    pp('$mm  Timer initialized ');

    //create initial telemetry record
    //createTelemetry();
  }

  Future createTelemetry() async {
    pp('\n\n$mm createTelemetry  - create telemetry');

    if (routeData == null) {
      listApiDog = GetIt.instance<ListApiDog>();
      locationBloc = GetIt.instance<DeviceLocationBloc>();
      dataApiDog = GetIt.instance<DataApiDog>();
      prefs = GetIt.instance<Prefs>();

      var ass = prefs.getAssociation();
      if (ass != null) {
        routeData = await listApiDog.getAssociationRouteData(
            ass!.associationId!, false);
      }
    }
    lib.Route? route;
    routes = await locationBloc.getRouteDistances(routeData: routeData!);
    if (routes.isNotEmpty) {
      route = routes.first;
      pp('$mm nearest route: ${route.toJson()}');
    }
    var car = prefs.getCar();
    var loc = await locationBloc.getLocation();
    var tm = lib.VehicleTelemetry(
        vehicleTelemetryId: const UuidV4().generate(),
        vehicleId: car!.vehicleId!,
        created: DateTime.now().toUtc().toIso8601String(),
        vehicleReg: car.vehicleReg,
        make: car.make,
        model: car.model,
        year: car.year,
        passengerCapacity: car.passengerCapacity,
        position: lib.Position(
            type: 'Point',
            coordinates: [loc.longitude, loc.latitude],
            latitude: loc.latitude,
            longitude: loc.longitude),
        nearestRouteName: route?.name!,
        routeId: route?.routeId!,
        nearestRouteLandmarkName: null,
        routeLandmarkId: null,
        associationId: car.associationId,
        associationName: car.associationName,
        ownerId: car.ownerId,
        ownerName: car.ownerName,
        accuracy: loc.accuracy,
        heading: loc.heading,
        altitude: loc.altitude,
        altitudeAccuracy: loc.altitudeAccuracy,
        speed: loc.speed,
        speedAccuracy: loc.speedAccuracy);

    pp('$mm Telemetry record to be sent: ${tm.toJson()}');
    var res = await dataApiDog.addVehicleTelemetry(tm);
    _telemetryController.sink.add(tm);
    pp('\n\n$mm Telemetry sent to stream: ${res.toJson()}\n\n');
  }

  Future<List<lib.VehicleTelemetry>> getTelemetry(
      String vehicleId, int minutes) async {
    ListApiDog dataApiDog = GetIt.instance<ListApiDog>();
    List<lib.VehicleTelemetry> metrics = [];

    return metrics;
  }
}
