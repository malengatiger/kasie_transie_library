import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:geolocator/geolocator.dart';

import 'functions.dart';

final DeviceLocationBloc locationBloc = DeviceLocationBloc();

class DeviceLocationBloc {
  final mm = '🍐🍐🍐🍐🍐🍐🍐 DeviceLocationBloc: ';

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    pp('$mm ... getting location ....');

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var loc = await Geolocator.getCurrentPosition();
    pp('$mm location determined: ${loc.latitude} ${loc.longitude}');
    return loc;
  }
  Future<double> getDistanceFromCurrentPosition(
      {required double latitude, required double longitude}) async {
    var pos = await getLocation();

    var latLngFrom = LatLng(pos.latitude, pos.longitude);
    var latLngTo = LatLng(latitude, longitude);

    var distanceBetweenPoints =
        SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
    var m = distanceBetweenPoints.toDouble();
    pp('$mm getDistanceFromCurrentPosition calculated: $m metres');
    return m;
    return 0.0;
  }

  double getDistance(
      {required double latitude,
      required double longitude,
      required double toLatitude,
      required double toLongitude}) {
    var latLngFrom = LatLng(latitude, longitude);
    var latLngTo = LatLng(toLatitude, toLongitude);

    var distanceBetweenPoints =
        SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
    var m = distanceBetweenPoints.toDouble();
    //pp('$mm getDistance between 2 points calculated: $m metres');

    return m;
  }
}


