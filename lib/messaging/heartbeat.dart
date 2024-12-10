import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:geolocator/geolocator.dart' as locator;
import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';


class TelemetryManager {
  final mm = '🔴🔴🔴🔴🔴🔴 HeartbeatManager: 🔴🔴🔴🔴🔴🔴';

  late Timer timer;
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  void startHeartbeat() async {
    pp('\n\n$mm start Heartbeat ................... are we falling here? .........................');
    final sett = prefs.getSettings();
    int seconds = 600; //3 minutes
    if (sett != null) {
      seconds = sett.heartbeatIntervalSeconds!;
      //todo - remove after test - check default settings
      if (seconds < 600) {
        seconds = 600;
      }
    }
    //
    await addHeartbeat(); //initial heartbeat
    pp('$mm Heartbeat ......... initial heartbeat sent; ${E.nice} '
        'timer will start with tick of ${E.leaf} $seconds seconds  ${E.leaf}');

    timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      addHeartbeat();
    });
  }

  Future addHeartbeat() async {
    var car = prefs.getCar();

    if (car == null) {
      try {
        pp('$mm ......... telemetry to be sent in the background ...');
        await Firebase.initializeApp();
        car = await getCarInBackground();
      } catch (e) {
        pp(e);
      }
    }
    //
    if (car == null) {
      return;
    }
    final loc = await locationBloc.getLocation();

    final telemetry = await _getTelemetry(
        car: car, loc: loc, radiusInKM: 1);
    try {
      await dataApiDog.addVehicleTelemetry(telemetry);
      pp('\n\n$mm VehicleHeartbeat added to database, registration: ${car.vehicleReg} '
          'at ${DateTime.now().toIso8601String()}');
    } catch (e) {
      pp(e);
    }
  }

  Future<VehicleTelemetry> _getTelemetry(
      {required Vehicle car,
      required locator.Position loc,
      required double radiusInKM}) async {
    String? nearestRouteLandmarkName;
    String? nearestRouteName;
    String? routeLandmarkId;
    String? routeId;

    var landmarks = await listApiDog.findRouteLandmarksByLocation(
        latitude: loc.latitude,
        longitude: loc.longitude,
        radiusInKM: radiusInKM);
    if (landmarks.isNotEmpty) {
      nearestRouteLandmarkName = landmarks[0].landmarkName;
      routeLandmarkId = landmarks[0].landmarkId;
    }
    var points = await listApiDog.findRoutePointsByLocation(
        latitude: loc.latitude,
        longitude: loc.longitude,
        radiusInKM: radiusInKM);
    if (points.isNotEmpty) {
      routeId = points.first.routeId;
      nearestRouteName = points.first.routeName;
    }
    Position pos = Position(coordinates: [loc.longitude, loc.latitude]);
    final heartbeat = VehicleTelemetry(
        vehicleId: car.vehicleId,
        created: DateTime.now().toUtc().toIso8601String(),
        vehicleReg: car.vehicleReg,
        make: car.make,
        model: car.model,
        year: car.year,
        passengerCapacity: 0,
        position: pos,
        nearestRouteName: nearestRouteName,
        routeId: routeId,
        nearestRouteLandmarkName: nearestRouteLandmarkName,
        routeLandmarkId: routeLandmarkId,
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

    return heartbeat;
  }

  Future findNearestRoute(Position position) async {}
}
