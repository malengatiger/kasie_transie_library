import 'dart:async';
import 'dart:collection';

import 'package:geofence_service/geofence_service.dart' as geo;
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';

import '../data/schemas.dart' as lib;
import '../data/schemas.dart';
import '../utils/device_location_bloc.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
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
    late String associationId;
    if (_user != null) {
      associationId = _user!.associationId!;
    }
    if (_vehicle != null) {
      associationId = _vehicle!.associationId!;
    }
    //
    var routeLandmarks = <lib.RouteLandmark>[];
    var loc = await locationBloc.getLocation();

    // final routes = await listApiDog
    //     .getRoutes(AssociationParameter(associationId, false));

    final assRoutesAroundHere = await listApiDog.findAssociationRoutesByLocation(LocationFinderParameter(
        latitude: loc.latitude, limit: 2000, longitude: loc.longitude, radiusInKM: 100));

    // final landmarks = await listApiDog.findLandmarksByLocation(
    //     latitude: loc.latitude,
    //     longitude: loc.longitude,
    //     radiusInKM: _settingsModel == null? 100: _settingsModel!.vehicleGeoQueryRadius!.toDouble());

    pp('$xx buildGeofences .... routes: ${assRoutesAroundHere.length} ');

    var filteredLandmarks = <lib.RouteLandmark>[];
    final map = HashMap<String, RouteLandmark>();

    for (var value in assRoutesAroundHere) {
      var m = await listApiDog.getRouteLandmarks(value.routeId!, false);
      for (var rl in m) {
        map[rl.landmarkId!] = rl;
      }
    }

    filteredLandmarks = map.values.toList();
    pp('$xx buildGeofences .... filteredLandmarks: ${filteredLandmarks
        .length} ');


    int cnt = 0;
    var radius = 25.0;
    if (_settingsModel != null) {
      radius = _settingsModel!.geofenceRadius!.toDouble();
    }
    //
    for (var landmark in filteredLandmarks) {
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

    pp('\n$xx ${_geofenceList.length} geofences added to service\n');
    geofenceService.addGeofenceList(_geofenceList);

    geofenceService.addGeofenceStatusChangeListener(
            (geofence, geofenceRadius, geofenceStatus, location) async {
          pp('$xx ....... Geofence Listener 💠 FIRED!! '
              '🔵🔵🔵 geofenceStatus: ${geofenceStatus.name}  at 🔶 ${geofence
              .data['landmarkName']}');

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

  Future addGeofence({
    required String landmarkName,
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
  }

  Vehicle? _vehicle;
  Future _processGeofenceEvent({required geo.Geofence geofence,
    required geo.GeofenceRadius geofenceRadius,
    required geo.GeofenceStatus geofenceStatus}) async {

    pp('$xx ....... _processing GeofenceEvent; 🔵 ${geofence.data['landmarkName']} '
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

  void _addVehicleArrival(geo.Geofence geofence) async  {
    pp('\n\n$xx _addVehicleArrival ... geofence status: ${geofence.status.toString()}');
    final m = VehicleArrival(ObjectId(),
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
    final m = VehicleDeparture(ObjectId(),
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
    final m = UserGeofenceEvent(ObjectId(),
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
