import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../isolates/heartbeat_isolate.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/parsers.dart';

final Heartbeat heartbeat = Heartbeat();

class Heartbeat {
  final mm = '🔴🔴🔴🔴🔴🔴 Heartbeat: 🔴🔴🔴🔴🔴🔴';

  late Timer timer;

  void startHeartbeat() async {
    pp('\n\n$mm start Heartbeat ............................................');
    final sett = await prefs.getSettings();
    int seconds = 600; //10 minutes
    if (sett != null) {
      seconds = sett.heartbeatIntervalSeconds!;
      //todo - remove after test - check default settings
      if (seconds < 600) {
        seconds = 600;
      }
    }
    await addHeartbeat();
    pp('$mm Heartbeat ......... timer will start with tick of ${E.leaf} $seconds seconds  ${E.leaf}');

    timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      addHeartbeat();
    });
  }

  Future addHeartbeat() async {
    var car = await prefs.getCar();

    if (car == null) {
      try {
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
    final loc = await locationBloc.getLocation();
    if (car == null) {
      return;
    }


    final heartbeat = getHeartbeat(car: car, latitude: loc.latitude, longitude: loc.longitude);
    await dataApiDog.addVehicleHeartbeat(heartbeat);
    pp('\n\n$mm VehicleHeartbeat added to database, registration: ${car.vehicleReg} '
        'at ${DateTime.now().toIso8601String()}');
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
const cc = '🔴🔴🔴🔴🔴🔴🌀🌀 Workmanager Heartbeat:  🌀🌀🔴🔴🔴🔴';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  pp("$cc Workmanager background callbackDispatcher ....");
  Workmanager().executeTask((task, inputData) {
    pp("$cc Native called background task ..... addHeartbeat, call isolate ...");
    heartbeatIsolate.addHeartbeat();
    return Future.value(true);
  });
}
