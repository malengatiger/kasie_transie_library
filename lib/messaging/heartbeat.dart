import 'dart:async';

import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';
import 'package:workmanager/workmanager.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/parsers.dart';

final Heartbeat heartbeat = Heartbeat();

class Heartbeat {
  final mm = '🔴🔴🔴🔴🔴🔴 Heartbeat: 🔴🔴🔴🔴🔴🔴';

  late Timer timer;

  void startHeartbeat() async {
    pp('$mm start Heartbeat ....');
    final sett = await prefs.getSettings();
    int seconds = 30;
    if (sett != null) {
      seconds = sett.heartbeatIntervalSeconds!;
    }
    await addHeartbeat();
    pp('$mm Heartbeat ......... tick duration of ${E.leaf} $seconds seconds  ${E.leaf}');

    timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      pp('\n\n$mm .... on Heartbeat timer tick:'
          ' ${timer.tick} ${E.leaf} ${E.leaf} ... add another heartbeat!');
      addHeartbeat();
    });
  }

  Future addHeartbeat() async {
    pp('$mm addHeartbeat: VehicleHeartbeat to be added ....');
    final loc = await locationBloc.getLocation();
    final car = await prefs.getCar();
    if (car == null) {
      return;
    }

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
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude,
        ));

    pp('$mm VehicleHeartbeat to be written to the db ...... see record below.');
    await dataApiDog.addVehicleHeartbeat(heartbeat);
    myPrettyJsonPrint(heartbeat.toJson());
    pp('$mm VehicleHeartbeat to be written to the db ...... see below.');
    pp('$mm VehicleHeartbeat added to database, registration: ${car.vehicleReg} '
        'at ${DateTime.now().toIso8601String()}');
  }
}
const cc = '🔴🔴🔴🔴🔴🔴🌀🌀 Workmanager Heartbeat:  🌀🌀🔴🔴🔴🔴';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  pp("$cc callbackDispatcher ....");
  Workmanager().executeTask((task, inputData) {
    pp("$cc Native called background task ..... addHeartbeat: $inputData");
    heartbeat.addHeartbeat();
    return Future.value(true);
  });
}
