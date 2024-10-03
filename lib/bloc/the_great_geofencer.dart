import 'dart:async';
import 'dart:collection';

import 'package:geofence_service/geofence_service.dart' as geo;
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';

import '../data/data_schemas.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

import 'list_api_dog.dart';

final geofenceService = geo.GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: geo.GeofenceRadiusSortType.DESC);


class TheGreatGeofencer {
  final xx = '😡😡😡😡😡😡😡 TheGreatGeofencer:  🔱 🔱 ';
  final reds = '🔴🔴🔴🔴🔴🔴 TheGreatGeofencer: ';
  final ListApiDog listApiDog;
  final DataApiDog dataApiDog;
 final Prefs prefs;

  TheGreatGeofencer(this.dataApiDog, this.listApiDog, this.prefs);

  final StreamController<VehicleArrival> _vehicleArrivalController =
      StreamController.broadcast();

  Stream<VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalController.stream;

  final StreamController<VehicleDeparture> _vehicleDepartureController =
      StreamController.broadcast();

  Stream<VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureController.stream;

  final _geofenceList = <geo.Geofence>[];
  User? _user;
  SettingsModel? _settingsModel;

  var defaultRadiusInKM = 100.0;
  var defaultRadiusInMetres = 150.0;
  var defaultDwellInMilliSeconds = 30;

  Future<List<RouteAssignment>> getRouteAssignments(String vehicleId) async {
    return await listApiDog.getVehicleRouteAssignments(vehicleId, false);
  }

  Future buildGeofences() async {
    pp('$xx buildGeofences .... build geofences for '
        'the association started ... 🌀 ');

    _settingsModel = prefs.getSettings();
    _user = prefs.getUser();
    _vehicle = prefs.getCar();

    var landmarks = await _getLandmarksFromAssignments(_vehicle!.vehicleId!);
    if (landmarks.isEmpty) {
      landmarks = await _getLandmarks();
    }

    int cnt = 0;
    var radius = 200.0;
    if (_settingsModel != null) {
      radius = _settingsModel!.geofenceRadius!.toDouble();
    }
    pp('$xx buildGeofences .... radius in metres: $radius ');

    //
    for (var landmark in landmarks) {
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
    final xList = [];
    for (var element in _geofenceList) {
      xList.add(element.data['landmarkName']);
    }
    xList.sort();
    pp('\n$xx geofences added to service in alphabetic order\n');

    for (var element in xList) {
      pp('$xx geofence added to service: ${E.peach} $element');
    }
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

  Future<List<RouteLandmark>> _getLandmarksFromAssignments(String vehicleId) async {
      final a = await listApiDog.getVehicleRouteAssignments(vehicleId, true);
      pp('$xx _getLandmarksFromAssignments .... found: ${a.length} ');

      final map = HashMap<String, String>();
      for (var value in a) {
        map[value.routeId!] = value.routeId!;
      }
      final List<RouteLandmark> list = [];
      final routeIds = map.values.toList();
      for (var routeId in routeIds) {
        list.addAll(await listApiDog.getRouteLandmarks(routeId, false));
      }
      pp('$xx _getLandmarksFromAssignments .... found: ${list.length} ');

      final map2 = HashMap<String, RouteLandmark>();
      for (var rl in list) {
        map2[rl.landmarkName!] = rl;
      }
      pp('$xx _getLandmarksFromAssignments .... filtered: ${map2.length} ');

      return map2.values.toList();
  }
  Future<List<RouteLandmark>> _getLandmarks() async {
    var routesIsolate = GetIt.instance<RoutesIsolate>();
    final marks2 = await routesIsolate.getAllRouteLandmarksCached();

    pp('$xx _getLandmarks .... routeLandmarks, unfiltered: ${marks2.length} ');

    final map = HashMap<String, RouteLandmark>();
    for (var value in marks2) {
      map[value.landmarkId!] = value;
    }

    final filteredLandmarks = map.values.toList();
    pp('$xx _getLandmarks .... filteredLandmarks: ${filteredLandmarks.length} ');
    final map2 = HashMap<String, RouteLandmark>();

    for (var value in filteredLandmarks) {
      map2[value.landmarkName!] = value;
    }
    pp('$xx _getLandmarks .... found: ${map2.length} ');

    return map2.values.toList();
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

    _user = prefs.getUser();
    _vehicle = prefs.getCar();

    String status = geofenceStatus.toString();
    switch (status) {
      case 'GeofenceStatus.ENTER':
        pp('$xx .... IGNORING geofence ${E.redDot} ENTER ${E.redDot} '
            'event for either user or vehicle ');
        return;
      case 'GeofenceStatus.DWELL':
        if (_user != null) {
          _addUserGeofenceEvent(geofence, 'GeofenceStatus.DWELL');
        }
        if (_vehicle != null) {
          _addVehicleArrival(geofence);
        }

        break;
      case 'GeofenceStatus.EXIT':
        if (_user != null) {
          _addUserGeofenceEvent(geofence, 'GeofenceStatus.EXIT');
        }
        if (_vehicle != null) {
          _addVehicleDeparture(geofence);
        }


        break;
    }
    //
  }

  void _addVehicleArrival(geo.Geofence geofence) async {
    pp('\n\n$xx _adding VehicleArrival ... geofence status: ${geofence.status.toString()}');
    final m = VehicleArrival(

      vehicleArrivalId: DateTime.now().toIso8601String(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: Position.fromJson({
        'type': 'Point',
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
    var pos = Position.fromJson({
      'type':"Point",
      'coordinates': [geofence.longitude, geofence.latitude],
      'latitude': geofence.latitude,
      'longitude': geofence.longitude,
    });
    final m = VehicleDeparture(
      vehicleDepartureId: DateTime.now().toIso8601String(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: pos,
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
    var pos = Position.fromJson({
      'type': 'Point',
      'coordinates': [geofence.longitude, geofence.latitude],
      'latitude': geofence.latitude,
      'longitude': geofence.longitude,
    });
    final m = UserGeofenceEvent(
      userGeofenceId:DateTime.now().toIso8601String(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      position: pos,
      userId: _user!.userId,
      action: action,
    );
    await dataApiDog.addUserGeofenceEvent(m);
    pp('$xx ... UserGeofenceEvent should be OK! ${_vehicle!.vehicleReg}');
  }
}
