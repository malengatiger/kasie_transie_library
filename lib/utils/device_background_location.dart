import 'package:flutter/foundation.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:location/location.dart';

import '../bloc/data_api_dog.dart';
import '../messaging/heartbeat.dart';

final DeviceBackgroundLocation deviceBackgroundLocation =
    DeviceBackgroundLocation();

class DeviceBackgroundLocation {
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  LocationData? locationData;
  Location location = Location();
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 DeviceBackgroundLocation 🔵🔵';

  Vehicle? car;

  initialize() async {
    pp('$mm ... starting & initializing location ...');
    car = await prefs.getCar();
    final sett = await prefs.getSettings();

    pp('$mm ... initializing location ...${E.heartRed} enabling background mode');
    location.enableBackgroundMode(enable: true);

    if (kReleaseMode) {
      location.changeSettings(
        distanceFilter:
            sett == null ? 1000 * 2 : sett.distanceFilter!.toDouble(),
        interval: sett == null
            ? 1000 * 60 * 5
            : sett.heartbeatIntervalSeconds! * 1000,
        accuracy: LocationAccuracy.high,
      );
    } else {
      pp('$mm ... initializing location ...${E.heartRed} debug mode');
      location.changeSettings(
        distanceFilter: 20,
        interval: 1000 * 30,
        accuracy: LocationAccuracy.high,
      );
    }
    /*
    Note: you can convert the timestamp into a DateTime with:
    DateTime.fromMillisecondsSinceEpoch(locationData.time.toInt())
     */
    location.onLocationChanged.listen((LocationData locationData) async {
      pp('$mm location.onLocationChanged FIRED! locationData: '
          '\n accuracy: ${locationData.accuracy} '
          '\n latitude: ${locationData.latitude} '
          '\n longitude: ${locationData.longitude}'
          '\n speed:${locationData.speed} '
          '\n heading: ${locationData.heading} '
          '\n headingAccuracy: ${locationData.headingAccuracy}');

      if (car != null) {
        final hb = Heartbeat.getHeartbeat(
            car: car!,
            latitude: locationData.latitude!,
            longitude: locationData.longitude!);

        pp('$mm VehicleHeartbeat to be written to the db ...... '
            '${E.appleRed} see record below.');
        await dataApiDog.addVehicleHeartbeat(hb);
        myPrettyJsonPrint(hb.toJson());
      }
    });
    // var settings = Platform.isIOS ? iosSettings : androidSettings;
    // Geolocator.getPositionStream(locationSettings: settings).listen((position) {
    //   double speedMps = position.speed;
    // });
  }

  Future<(double?, double?)> getLocation() async {
    await getPermission();
    locationData = await location.getLocation();
    return (locationData?.latitude, locationData?.longitude);
  }

  Future<bool> getPermission() async {
    bool enabled = false;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        enabled = true;
      }
    }
    pp('$mm ... location service is enabled?: $enabled');
    bool enabled2 = false;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        enabled2 = true;
      }
    }
    pp('$mm ... location permission is cool?: $enabled2');

    return enabled2;
  }
}
