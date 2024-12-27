import 'dart:async';

import 'package:geofence_service/geofence_service.dart' as geo;
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:uuid/v4.dart';

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
  final xx = '😡😡😡😡😡😡😡 TheGreatGeofencer: 😡😡😡😡 ';
  final reds = '🔴🔴🔴🔴🔴🔴 TheGreatGeofencer: ';
  final ListApiDog listApiDog;
  final DataApiDog dataApiDog;
  final Prefs prefs;

  TheGreatGeofencer(this.dataApiDog, this.listApiDog, this.prefs) {
    // setRefreshFencesTimer();
  }

  final StreamController<VehicleArrival> _vehicleArrivalController =
      StreamController.broadcast();

  Stream<VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalController.stream;

  final StreamController<VehicleTelemetry> _telemetryController =
      StreamController.broadcast();

  Stream<VehicleTelemetry> get telemetryStream => _telemetryController.stream;

  final StreamController<VehicleDeparture> _vehicleDepartureController =
      StreamController.broadcast();

  Stream<VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureController.stream;

  final _geofenceList = <geo.Geofence>[];
  User? _user;

  // SettingsModel? _settingsModel;

  var defaultRadiusInKM = 100.0;
  var defaultRadiusInMetres = 150.0;
  var defaultDwellInMilliSeconds = 30;
  late Timer timer;
  int refreshMinutes = 30;

  setRefreshFencesTimer() {
    pp('$xx initialize Timer for refreshing fences');
    timer = Timer.periodic(Duration(minutes: refreshMinutes), (timer) {
      pp('\n\n$xx Timer tick ${timer.tick} - refresh geoFences');
      buildGeofences();
    });
    pp('$xx  Geofence Timer initialized ');
  }

  Future buildGeofences() async {
    pp('\n\n$xx buildGeofences .... build geofences for '
        'the association started ... 🌀🌀🌀🌀 ');

    _vehicle = prefs.getCar();
    _geofenceList.clear();

    var locationBloc = GetIt.instance<DeviceLocationBloc>();

    var routeData = await listApiDog.getAssociationRouteData(
        _vehicle!.associationId!, false);

    if (routeData == null) {
      return;
    }
    if (routeData.routeDataList.isEmpty) {
      return;
    }

    List<RouteLandmark> landmarks = [];
    List<LandmarkDistanceBag> distanceBags =
        await locationBloc.getRouteLandmarkDistances(routeData: routeData);

    for (var bag in distanceBags) {
      landmarks.add(bag.routeLandmark);
    }
    pp('$xx buildGeofences .... landmarks: ${landmarks.length} ');
    if (landmarks.isEmpty) {
      return;
    }

    int cnt = 0;
    var radius = 200.0;

    pp('$xx buildGeofences .... radius in metres: $radius ');

    for (var landmark in landmarks) {
      if (landmark.associationId == _vehicle!.associationId) {
        await addGeofence(
            landmarkId: landmark.landmarkId!,
            landmarkName: landmark.landmarkName!,
            longitude: landmark.position!.coordinates[0],
            latitude: landmark.position!.coordinates[1],
            routeId: landmark.routeId!,
            routeName: landmark.routeName!,
            radius: radius);
        cnt++;
        if (cnt > 99) {
          pp('$xx buildGeofences .... $cnt fences built, other landmarks, from 100, not built');
          break;
        }
      }
    }
    pp('$xx buildGeofences .... fences built: $cnt ');
    pp('$xx buildGeofences .... fence #1 built: ${landmarks[0].landmarkName} ');

    geofenceService.addGeofenceList(_geofenceList);

    geofenceService.addGeofenceStatusChangeListener(
        (geofence, geofenceRadius, geofenceStatus, location) async {
      await _processGeofenceEvent(
        geofence: geofence,
        geofenceRadius: geofenceRadius,
        geofenceStatus: geofenceStatus,
      );
    });

    try {
      pp('$xx  🔶🔶🔶🔶🔶🔶 Starting GeofenceService ...... 🔶🔶🔶🔶🔶🔶 ');
      await geofenceService.start().onError((error, stackTrace) {
        pp('\n\n$xx GeofenceService failed to start: 🔴 $error 🔴 }');
      });
      pp('$xx  🔶🔶🔶🔶🔶🔶 GeofenceService started 🌀🌀🌀🌀 ...... 🔶🔶🔶🔶🔶🔶 ');
    } catch (e) {
      pp('\n\n$xx GeofenceService failed to start: 🔴 $e 🔴 }');
    }
  }

  Future addGeofence(
      {required String landmarkName,
      required String landmarkId,
      required String routeName,
      required String routeId,
      required double latitude,
      required double longitude,
      required double radius}) async {
    final data = {
      'landmarkName': landmarkName,
      'landmarkId': landmarkId,
      'routeId': routeId,
      'routeName': routeName,
      'dateGeofenceAdded': DateTime.now().toUtc().toIso8601String(),
    };

    final fence = geo.Geofence(
      id: landmarkId,
      data: data,
      latitude: latitude,
      longitude: longitude,
      radius: [
        geo.GeofenceRadius(id: 'default radius', length: radius),
      ],
    );

    _geofenceList.add(fence);
    pp('$reds geofence added to geofenceList: ${E.broc} ${fence.data['landmarkName']} - ${fence.data['routeName']}');
  }

  Vehicle? _vehicle;

  Future _processGeofenceEvent(
      {required geo.Geofence geofence,
      required geo.GeofenceRadius geofenceRadius,
      required geo.GeofenceStatus geofenceStatus}) async {
    _user = prefs.getUser();
    _vehicle = prefs.getCar();

    String status = geofenceStatus.toString();
    switch (status) {
      case 'GeofenceStatus.ENTER':
        // pp('$xx .... IGNORING geofence ${E.redDot} ENTER ${E.redDot} '
        //     'event for either user or vehicle ');
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
          // pp('$xx user Geofence EXIT fragile?');
          // _addUserGeofenceEvent(geofence, 'GeofenceStatus.EXIT');
        }
        if (_vehicle != null) {
          // pp('$xx vehicle Geofence EXIT fragile?');
          // _addVehicleDeparture(geofence);
        }

        break;
    }
    //
  }

  void _addVehicleArrival(geo.Geofence geofence) async {
    pp('\n\n$xx _adding VehicleArrival ... 🔵 geofence status: ${geofence.status.toString()}');
    pp('$xx _adding VehicleArrival ... 🔵 geofence data: ${geofence.data}');

    final m = VehicleArrival(
      vehicleArrivalId: const UuidV4().generate(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      routeId: geofence.data['routeId'],
      routeName: geofence.data['routeName'],
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
    _vehicleArrivalController.sink.add(m);
    pp('$xx ... VehicleArrival should be OK! 🥬 🥬 ${_vehicle!.vehicleReg} 🥬 \n\n');
  }

  void _addVehicleDeparture(geo.Geofence geofence) async {
    pp('\n\n$xx _addVehicleDeparture ... geofence status: ${geofence.status.toString()}');
    var pos = Position.fromJson({
      'type': "Point",
      'coordinates': [geofence.longitude, geofence.latitude],
      'latitude': geofence.latitude,
      'longitude': geofence.longitude,
    });
    final m = VehicleDeparture(
      vehicleDepartureId: const UuidV4().generate(),
      associationId: _vehicle!.associationId,
      associationName: _vehicle!.associationName,
      created: DateTime.now().toUtc().toIso8601String(),
      landmarkId: geofence.data['landmarkId'],
      landmarkName: geofence.data['landmarkName'],
      routeId: geofence.data['routeId'],
      routeName: geofence.data['routeName'],
      position: pos,
      make: _vehicle!.make,
      model: _vehicle!.model,
      vehicleId: _vehicle!.vehicleId,
      vehicleReg: _vehicle!.vehicleReg,
      ownerId: _vehicle!.ownerId,
      ownerName: _vehicle!.ownerName,
    );
    await dataApiDog.addVehicleDeparture(m);
    _vehicleDepartureController.sink.add(m);

    pp('$xx ... VehicleDeparture should be OK! 🥬🥬 ${_vehicle!.vehicleReg} 🥬 \n');
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
      userGeofenceId: DateTime.now().toIso8601String(),
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
