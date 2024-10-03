import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';

import '../bloc/data_api_dog.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

final HeartbeatManager heartbeatManager = HeartbeatManager();

class HeartbeatManager {
  final mm = '🔴🔴🔴🔴🔴🔴 HeartbeatManager: 🔴🔴🔴🔴🔴🔴';

  late Timer timer;
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

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
    await addHeartbeat();  //initial heartbeat
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
        pp('$mm ......... heartbeat to be sent in the background ...');
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

    final heartbeat = getHeartbeat(car: car, latitude: loc.latitude, longitude: loc.longitude);

    try {
      await dataApiDog.addVehicleHeartbeat(heartbeat);
      pp('\n\n$mm VehicleHeartbeat added to database, registration: ${car.vehicleReg} '
              'at ${DateTime.now().toIso8601String()}');
    } catch (e) {
      pp(e);
    }
  }

  static VehicleHeartbeat getHeartbeat({required Vehicle car,
    required double latitude, required double longitude}) {

    final heartbeat = VehicleHeartbeat(
        ownerName: car.ownerName,
        ownerId: car.ownerId,
        associationId: car.associationId,
        vehicleReg: car.vehicleReg,
        vehicleId: car.vehicleId,
        model: car.model,
        make: car.make,
        created: DateTime.now().toUtc().toIso8601String(),
        longDate: DateTime.now().toUtc().millisecondsSinceEpoch,
        vehicleHeartbeatId:DateTime.now().toIso8601String(),
        position: Position(
          type: 'Point',
          coordinates: [longitude, latitude],
          latitude: latitude,
          longitude: longitude,
        ));

    return heartbeat;
  }
}
