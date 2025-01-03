import 'package:geofence_service/geofence_service.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../data/data_schemas.dart';



final DeviceBackgroundLocation deviceBackgroundLocation =
    DeviceBackgroundLocation();

class DeviceBackgroundLocation {
  bool serviceEnabled = false;

  final mm = '🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 ${E.appleRed} DeviceBackgroundLocation ${E.appleRed} 🔵🔵';

  Vehicle? car;
  Location? prevLocation;
  DateTime? prevDate;
  int seconds = 59;

  initialize() async {
    pp('$mm ... starting & initializing location ...');
    pp('$mm ... initializing location service ... ${E.heartRed} enabling background mode');

    // BackgroundLocation.setAndroidNotification(
    //   title: "Notification title",
    //   message: "Notification message",
    //   icon: "@mipmap/ic_launcher",
    // );
    //
    // BackgroundLocation.startLocationService();
    //
    // BackgroundLocation.getLocationUpdates((location) {
    //   pp('$mm ... DeviceBackgroundLocation FIRED!');
    //     pp('$mm onLocationChanged FIRED! locationData: '
    //         '\n${E.appleRed} accuracy: ${location.accuracy} '
    //         '\n${E.appleRed} latitude: ${location.latitude} '
    //         '\n${E.appleRed} longitude: ${location.longitude}'
    //         '\n${E.appleRed} speed: ${location.speed} '
    //         '\n${E.appleRed} bearing: ${location.bearing} '
    //         '\n${E.appleRed} altitude: ${location.altitude}');
    //
    //     processUpdate(location);
    //
    //
    // });

  }

  Future<void> processUpdate(Location location) async {
    pp('$mm processUpdate starting ..... ');

    // final car = Vehicle();
    // if (prevDate == null) {
    //   prevDate = DateTime.now();
    //   return;
    // }
    // var now = DateTime.now();
    //
    // var diff = prevDate!.difference(now).inSeconds;
    // if (diff > seconds) {
    //   pp('$mm 2 minutes has elapsed since last heartbeat, create new ...');
    //   final hb = VehicleHeartbeat(
    //     associationId: car.associationId,
    //     created: now.toUtc().toIso8601String(),
    //     longDate: now.millisecondsSinceEpoch,
    //     make: car.make,
    //     model: car.model,
    //     ownerId: car.ownerId,
    //     ownerName: car.ownerName,
    //     vehicleId: car.vehicleId,
    //     vehicleReg: car.vehicleReg,
    //     vehicleHeartbeatId: DateTime.now().toIso8601String(),
    //     position: Position(
    //       type: point,
    //       coordinates: [
    //         location.longitude!,
    //         location.latitude!,
    //       ]
    //     ),
    //   );
    //
    //   await Firebase.initializeApp();
    //   String? token = ''; //await appAuth.getAuthToken();
    //   if (token == null) {
    //     pp('$mm Firebase auth token not available');
    //     return;
    //   }
    //   final mUrl = '${KasieEnvironment.getUrl()}addVehicleHeartbeat';
    //   final bag = hb.toJson();
    //   final result = await httpPost(mUrl, bag, token);
    //   pp('$mm ... heartbeat added to database from location updates: $result');
    // }
  }
}
