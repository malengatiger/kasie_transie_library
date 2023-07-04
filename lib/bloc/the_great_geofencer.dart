import 'dart:async';
import 'dart:collection';

import 'package:geofence_service/geofence_service.dart' as geo;
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';

import '../data/schemas.dart' as lib;
import '../data/schemas.dart';
import '../utils/device_location_bloc.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/local_finder.dart';
import '../utils/prefs.dart';
import 'package:sane_uuid/uuid.dart' as uu;

final geofenceService = geo.GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: geo.GeofenceRadiusSortType.DESC);

final TheGreatGeofencer theGreatGeofencer = TheGreatGeofencer();

class TheGreatGeofencer {
  final xx = '😡😡😡😡😡😡😡 TheGreatGeofencer:  🔱 🔱 ';
  final reds = '🔴🔴🔴🔴🔴🔴 TheGreatGeofencer: ';

  final StreamController<lib.VehicleArrival> _vehicleArrivalController =
      StreamController.broadcast();

  Stream<lib.VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalController.stream;

  final StreamController<lib.VehicleDeparture> _vehicleDepartureController =
      StreamController.broadcast();

  Stream<lib.VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureController.stream;

  final _geofenceList = <geo.Geofence>[];
  lib.User? _user;
  SettingsModel? _settingsModel;

  var defaultRadiusInKM = 100.0;
  var defaultRadiusInMetres = 150.0;
  var defaultDwellInMilliSeconds = 30;

  Future buildGeofences() async {
    pp('$xx buildGeofences .... build geofences for '
        'the association started ... 🌀 ');

    _settingsModel = await prefs.getSettings();
    _user = await prefs.getUser();
    _vehicle = await prefs.getCar();

    var loc = await locationBloc.getLocation();

    final marks = await localFinder.findNearestRouteLandmarks(
        latitude: loc.latitude,
        longitude: loc.longitude,
        radiusInMetres: 1000 * 200);

    pp('$xx buildGeofences .... routeLandmarks, unfiltered: ${marks.length} ');
    pp('$xx buildGeofences .... filter by landmarkId ....');

    var filteredLandmarks = <lib.RouteLandmark>[];
    final map = HashMap<String, RouteLandmark>();

    for (var value in marks) {
      map[value.landmarkId!] = value;
    }

    filteredLandmarks = map.values.toList();
    pp('$xx buildGeofences .... filteredLandmarks: ${filteredLandmarks.length} ');
    pp('$xx buildGeofences .... filter by name ....');
    var filteredLandmarks2 = <lib.RouteLandmark>[];
    final map2 = HashMap<String, RouteLandmark>();

    for (var value in filteredLandmarks) {
      map2[value.landmarkName!] = value;
    }

    filteredLandmarks2 = map2.values.toList();
    pp('$xx buildGeofences .... filteredLandmarks2: ${filteredLandmarks2.length} ');


    int cnt = 0;
    var radius = 200.0;
    if (_settingsModel != null) {
      radius = _settingsModel!.geofenceRadius!.toDouble();
    }
    pp('$xx buildGeofences .... radius in metres: $radius ');

    //
    for (var landmark in filteredLandmarks2) {
      await addGeofence(
          landmarkId: landmark.landmarkId!,
          landmarkName: landmark.landmarkName!,
          longitude: landmark.position!.coordinates[0],
          latitude: landmark.position!.coordinates[1],
          radius: radius);
      cnt++;
      if (cnt > 98) {
        break;
      }
    }

    pp('\n$xx ${_geofenceList.length} geofences added to service: ${filteredLandmarks2.length}\n');
    geofenceService.addGeofenceList(_geofenceList);

    geofenceService.addGeofenceStatusChangeListener(
        (geofence, geofenceRadius, geofenceStatus, location) async {
      pp('$xx ....... Geofence Listener 💠 FIRED!! '
          '🔵🔵🔵 geofenceStatus: ${geofenceStatus.name}  at 🔶 ${geofence.data['landmarkName']}');

      await _processGeofenceEvent(
        geofence: geofence,
        geofenceRadius: geofenceRadius,
        geofenceStatus: geofenceStatus,
      );
    });

    try {
      pp('$xx  🔶🔶🔶🔶🔶🔶 Starting GeofenceService ...... 🔶🔶🔶🔶🔶🔶 ');
      await geofenceService.start().onError((error, stackTrace) {});
    } catch (e) {
      pp('\n\n$xx GeofenceService failed to start: 🔴 $e 🔴 }');
    }
  }

  Future addGeofence(
      {required String landmarkName,
      required String landmarkId,
      required double latitude,
      required double longitude,
      required double radius}) async {
    final data = {
      'landmarkName': landmarkName,
      'landmarkId': landmarkId,
      'dateGeofenceAdded': DateTime.now().toUtc().toIso8601String(),
    };

    final fence = geo.Geofence(
      id: landmarkId,
      data: data,
      latitude: latitude,
      longitude: longitude,
      radius: [
        geo.GeofenceRadius(id: 'radius_from_settings', length: radius),
      ],
    );

    _geofenceList.add(fence);
    pp('$reds geofence added to geofenceList: ${E.broc} ${fence.data}');
  }

  Vehicle? _vehicle;
  Future _processGeofenceEvent(
      {required geo.Geofence geofence,
      required geo.GeofenceRadius geofenceRadius,
      required geo.GeofenceStatus geofenceStatus}) async {

    pp('\n\n$xx ....... _processing GeofenceEvent; 🔵 ${geofence.data['landmarkName']} '
        '🔵🔵🔵🔵🔵 geofenceStatus: ${geofenceStatus.toString()}');

    _user = await prefs.getUser();
    _vehicle = await prefs.getCar();

    String status = geofenceStatus.toString();
    switch (status) {
      case 'GeofenceStatus.ENTER':
        pp('$xx .... IGNORING geofence ${E.redDot} ENTER ${E.redDot} '
            'event for either user or vehicle ');
        return;
      case 'GeofenceStatus.DWELL':
        if (_user != null) {
          _addUserGeofenceEvent(geofence, 'GeofenceStatus.DWELL');
        } else {
          _addVehicleArrival(geofence);
        }
        break;
      case 'GeofenceStatus.EXIT':
        if (_user != null) {
          _addUserGeofenceEvent(geofence, 'GeofenceStatus.EXIT');
        } else {
          _addVehicleDeparture(geofence);
        }

        break;
    }
    //
  }

  void _addVehicleArrival(geo.Geofence geofence) async {
    pp('\n\n$xx _adding VehicleArrival ... geofence status: ${geofence.status.toString()}');
    final m = VehicleArrival(
      ObjectId(),
      vehicleArrivalId: uu.Uuid.v4().toString(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: buildPosition({
        'type': point,
        'coordinates': [geofence.longitude, geofence.latitude],
        'latitude': geofence.latitude,
        'longitude': geofence.longitude,
      }),
      make: _vehicle!.make,
      model: _vehicle!.model,
      vehicleId: _vehicle!.vehicleId,
      vehicleReg: _vehicle!.vehicleReg,
      ownerId: _vehicle!.ownerId,
      ownerName: _vehicle!.ownerName,
    );
    await dataApiDog.addVehicleArrival(m);
    pp('$xx ... VehicleArrival should be OK! ${_vehicle!.vehicleReg}');
  }

  void _addVehicleDeparture(geo.Geofence geofence) async {
    pp('\n\n$xx _addVehicleDeparture ... geofence status: ${geofence.status.toString()}');
    final m = VehicleDeparture(
      ObjectId(),
      vehicleDepartureId: uu.Uuid.v4().toString(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: buildPosition({
        'type': point,
        'coordinates': [geofence.longitude, geofence.latitude],
        'latitude': geofence.latitude,
        'longitude': geofence.longitude,
      }),
      make: _vehicle!.make,
      model: _vehicle!.model,
      vehicleId: _vehicle!.vehicleId,
      vehicleReg: _vehicle!.vehicleReg,
      ownerId: _vehicle!.ownerId,
      ownerName: _vehicle!.ownerName,
    );
    await dataApiDog.addVehicleDeparture(m);
    pp('$xx ... VehicleDeparture should be OK! ${_vehicle!.vehicleReg}');
  }

  void _addUserGeofenceEvent(geo.Geofence geofence, String action) async {
    pp('$xx _addUserGeofenceEvent ... geofence status: ${geofence.status.toString()}');
    final m = UserGeofenceEvent(
      ObjectId(),
      userGeofenceId: uu.Uuid.v4().toString(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: buildPosition({
        'type': point,
        'coordinates': [geofence.longitude, geofence.latitude],
        'latitude': geofence.latitude,
        'longitude': geofence.longitude,
      }),
      userId: _user!.userId,
      action: action,
    );
    await dataApiDog.addUserGeofenceEvent(m);
    pp('$xx ... UserGeofenceEvent should be OK! ${_vehicle!.vehicleReg}');
  }
}
