import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/parsers.dart';

final HeartbeatManager heartbeat = HeartbeatManager();

class HeartbeatManager {
  final mm = '🔴🔴🔴🔴🔴🔴 HeartbeatManager: 🔴🔴🔴🔴🔴🔴';

  late Timer timer;

  void startHeartbeat() async {
    pp('\n\n$mm start Heartbeat ................... are we falling here? .........................');
    final sett = await prefs.getSettings();
    int seconds = 180; //3 minutes
    if (sett != null) {
      seconds = sett.heartbeatIntervalSeconds!;
      //todo - remove after test - check default settings
      if (seconds < 180) {
        seconds = 180;
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
    var car = await prefs.getCar();

    if (car == null) {
      try {
        pp('$mm ......... heartbeat to be sent in the background ...');
            await Firebase.initializeApp();
            final prefs1 = await SharedPreferences.getInstance();
            prefs1.reload(); // The magic line
            var string = prefs1.getString('car');
            if (string == null) {
              pp('... ${E.redDot}${E.redDot}${E.redDot} car is null in background ... 1');
              return;
            } else {
              final json = jsonDecode(string);
              car = buildVehicle(json);
            }
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

    final heartbeat = VehicleHeartbeat(ObjectId(),
        ownerName: car.ownerName,
        ownerId: car.ownerId,
        associationId: car.associationId,
        vehicleReg: car.vehicleReg,
        vehicleId: car.vehicleId,
        model: car.model,
        make: car.make,
        created: DateTime.now().toUtc().toIso8601String(),
        longDate: DateTime.now().toUtc().millisecondsSinceEpoch,
        vehicleHeartbeatId: Uuid.v4().toString(),
        position: Position(
          type: point,
          coordinates: [longitude, latitude],
          latitude: latitude,
          longitude: longitude,
        ));

    return heartbeat;
  }
}
