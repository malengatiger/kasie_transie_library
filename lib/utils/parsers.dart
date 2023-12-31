import 'package:realm/realm.dart' as rm;

import '../data/schemas.dart';
import 'functions.dart';

///functions to parse data fromJson
///
///
Association buildAssociation(Map map) {
  late rm.ObjectId id = _getId(map);

  final m = Association(
    id,
    userId: map['userId'],
    countryId: map['countryId'],
    countryName: map['countryName'],
    cityId: map['cityId'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    active: map['active'],
    adminCellphone: map['adminCellphone'],
    adminEmail: map['adminEmail'],
    adminUserFirstName: map['adminUserFirstName'],
    adminUserLastName: map['adminUserLastName'],
    cityName: map['cityName'],
    dateRegistered: map['dateRegistered'],
  );
  return m;
}

StateProvince buildState(Map map) {
  late rm.ObjectId id = _getId(map);

  final m = StateProvince(
    id,
    stateId: map['stateId'],
    countryId: map['countryId'],
    countryName: map['countryName'],
    name: map['name'],
  );
  return m;
}

Commuter buildCommuter(Map map) {
  // pp('${E.broc}  json for User, check _id .......');
  // //myPrettyJsonPrint(map);
  late rm.ObjectId id = _getId(map);
  final m = Commuter(
    id,
    commuterId: map['commuterId'],
    name: map['name'],
    countryId: map['countryId'],
    dateRegistered: map['dateRegistered'],
    qrCodeUrl: map['qrCodeUrl'],
    profileUrl: map['profileUrl'],
    profileThumbnailUrl: map['profileThumbnailUrl'],
    password: map['password'],
    email: map['email'],
    cellphone: map['cellphone'],
    gender: map['gender'],
  );

  return m;
}

User buildUser(Map map) {
  // pp('${E.broc}  json for User, check _id .......');
  // //myPrettyJsonPrint(map);
  late rm.ObjectId id = _getId(map);
  final m = User(
    id,
    userId: map['userId'],
    firstName: map['firstName'],
    lastName: map['lastName'],
    countryId: map['countryId'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    imageUrl: map['imageUrl'],
    thumbnailUrl: map['thumbnailUrl'],
    userType: map['userType'],
    password: map['password'],
    email: map['email'],
    cellphone: map['cellphone'],
    gender: map['gender'],
    fcmToken: map['fcmToken'],
  );
  return m;
}

SettingsModel buildSettingsModel(Map map) {
  late rm.ObjectId id = _getId(map);
  final m = SettingsModel(
    id,
    associationId: map['associationId'],
    locale: map['locale'],
    refreshRateInSeconds: map['refreshRateInSeconds'],
    themeIndex: map['themeIndex'],
    distanceFilter: map['distanceFilter'],
    created: map['created'],
    commuterGeofenceRadius: map['commuterGeofenceRadius'],
    commuterGeoQueryRadius: map['commuterGeoQueryRadius'],
    commuterSearchMinutes: map['commuterSearchMinutes'],
    geofenceRadius: map['geofenceRadius'],
    heartbeatIntervalSeconds: map['heartbeatIntervalSeconds'],
    loiteringDelay: map['loiteringDelay'],
    numberOfLandmarksToScan: map['numberOfLandmarksToScan'],
    vehicleGeoQueryRadius: map['vehicleGeoQueryRadius'],
    vehicleSearchMinutes: map['vehicleSearchMinutes'],
  );
  return m;
}

Country buildCountry(Map value) {
  late Country m;
  try {
    var id = rm.ObjectId.fromHexString(value['_id'] as String);
    m = Country(id,
        countryId: value['countryId'],
        name: value['name'],
        latitude: value['latitude'] is int ? double.parse(
            '${value['latitude']}') : value['latitude'],
        longitude: value['longitude'] is int ? double.parse(
            '${value['longitude']}') : value['longitude'],
        iso2: value['iso2'],
        iso3: value['iso3'],
        capital: value['capital'],
        subregion: value['subregion'],
        region: value['region'],
        currency: value['currency'],
        emoji: value['emoji'],
        currency_name: value['currency_name'],
        currency_symbol: value['currency_symbol'],
        phone_code: value['phone_code']);
  } catch (e, stack) {
    pp("ERROR: $e : $stack");
  }
  return m;
}

//
City buildCity(Map map) {
  late rm.ObjectId id = _getId(map);

  final m = City(
    id,
    cityId: map['cityId'],
    name: map['name'],
    countryName: map['countryName'],
    countryId: map['countryId'],
    stateName: map['stateName'],
    stateId: map['stateId'],
    latitude: map['latitude'] is int
        ? double.parse('${map['latitude']}')
        : map['latitude'],
    longitude: map['longitude'] is int
        ? double.parse('${map['longitude']}')
        : map['longitude'],

    position: buildPosition(map['position']),
    distance: map['distance'],
  );
  return m;
}

Position buildPosition(Map map) {
  List st = map['coordinates'];
  var lat = st.last is int ? double.parse('${st.last}') : st.last;
  var lng = st.first is int ? double.parse('${st.first}') : st.first;
  final m = Position(
      type: point, coordinates: [lng, lat], latitude: lat, longitude: lng);

  return m;
}

Landmark buildLandmark(Map map) {
  late rm.ObjectId id = _getId(map);
  List details = map['routeDetails'];
  var info = <RouteInfo>[];
  for (var e in details) {
    info.add(RouteInfo(
      routeId: e['routeId'],
      routeName: e['routeName'],
    ));
  }
  final m = Landmark(
    id,
    landmarkId: map['landmarkId'],
    landmarkName: map['landmarkName'],
    routeDetails: info,
    longitude: map['longitude'],
    latitude: map['latitude'],
    position: buildPosition(map['position']),
    distance: map['distance'],
  );
  return m;
}

RouteLandmark buildRouteLandmark(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);
  try {
    var m = RouteLandmark(
      id,
      routeName: value['routeName'],
      routeId: value['routeId'],
      associationId: value['associationId'],
      landmarkId: value['landmarkId'],
      created: value['created'],
      routePointId: value['routePointId'],
      index: value['index'],
      routePointIndex: value['routePointIndex'],
      landmarkName: value['landmarkName'],
      position: buildPosition(value['position']),
    );
    return m;
  } catch (e, stackTrace) {
    pp('Error parsing JSON: $e');
    pp('Stack trace: $stackTrace');
    rethrow;
  }
}

RouteCity buildRouteCity(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);

  var m = RouteCity(
    id,
    routeName: value['routeName'],
    routeId: value['routeId'],
    associationId: value['associationId'],
    cityId: value['cityId'],
    created: value['created'],
    cityName: value['cityName'],
    position: buildPosition(value['position']),
  );
  return m;
}

Route buildRoute(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);

  var startEnd = value['routeStartEnd'];
  List st = startEnd['startCityPosition']['coordinates'];
  var lat = st.last as double;
  var lng = st.first as double;
  List st2 = startEnd['endCityPosition']['coordinates'];
  var lat2 = st2.last as double;
  var lng2 = st2.first as double;

  final startCityPosition = Position(
    type: point,
    coordinates: [lng, lat],
  );

  final endCityPosition = Position(
    type: point,
    coordinates: [lng2, lat2],
  );
  var se = RouteStartEnd(
    startCityId: startEnd['startCityId'],
    startCityName: startEnd['startCityName'],
    endCityId: startEnd['endCityId'],
    endCityName: startEnd['endCityName'],
    startCityPosition: startCityPosition,
    endCityPosition: endCityPosition,
  );

  try {
    var m = Route(
      id,
      countryId: value['countryId'],
      routeId: value['routeId'],
      associationId: value['associationId'],
      userId: value['userId'],
      created: value['created'],
      heading:
      value['heading'] == null ? 0.0 : double.parse('${value['heading']}'),
      name: value['name'],
      routeStartEnd: se,
      userName: value['userName'],
      userUrl: value['userUrl'],
      countryName: value['countryName'],
      color: value['color'],
      activationDate: value['activationDate'],
      associationName: value['associationName'],
      lengthInMetres: value['lengthInMetres'] == null
          ? 0
          : int.parse('${value['lengthInMetres']}'),
      routeNumber: value['routeNumber'],
    );
    return m;
  } catch (e, stackTrace) {
    pp('Error parsing JSON: $e');
    pp('Stack trace: $stackTrace');
    rethrow;
  }
}

RoutePoint buildRoutePoint(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);

  try {
    final routePointId = value['routePointId'];
    var routePoint = RoutePoint(
      id,
      routePointId: routePointId,
      longitude: value['longitude'],
      routeId: value['routeId'],
      index: value['index'],
      associationId: value['associationId'],
      latitude: value['latitude'],
      created: value['created'],
      heading:
      value['heading'] == null ? 0.0 : double.parse('${value['heading']}'),
      routeName: value['routeName'],
      geoHash: value['geoHash'],
      position: buildPosition(value['position']),
    );

    return routePoint;
  } catch (e, stackTrace) {
    pp('Error parsing JSON: $e');
    pp('Stack trace: $stackTrace');
    rethrow;
  }
}

Vehicle buildVehicle(Map vehicleJson) {
  var id = rm.ObjectId();
  try {
    var id = rm.ObjectId.fromHexString(vehicleJson['_id'] as String);
  } catch (e) {
    pp('... ignoring _id error');
  }
  var m = Vehicle(
    id,
    vehicleId: vehicleJson['vehicleId'],
    vehicleReg: vehicleJson['vehicleReg'],
    associationId: vehicleJson['associationId'],
    associationName: vehicleJson['associationName'],
    created: vehicleJson['created'],
    make: vehicleJson['make'],
    model: vehicleJson['model'],
    year: vehicleJson['year'],
    qrCodeUrl: vehicleJson['qrCodeUrl'],
    countryId: vehicleJson['countryId'],
    dateInstalled: vehicleJson['dateInstalled'],
    ownerId: vehicleJson['ownerId'],
    passengerCapacity: vehicleJson['passengerCapacity'],
    ownerName: vehicleJson['ownerName'],
  );
  return m;
}

RouteAssignment buildRouteAssignment(Map map) {
  late rm.ObjectId id = _getId(map);
  var m = RouteAssignment(
    id,
    vehicleId: map['vehicleId'],
    vehicleReg: map['vehicleReg'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    created: map['created'],
    routeId: map['routeId'],
    routeName: map['routeName'],
    active: map['active'],
  );
  return m;
}

DispatchRecord buildDispatchRecord(Map j) {
  //myPrettyJsonPrint(j);
  late rm.ObjectId id = _getId(j);
  var m = DispatchRecord(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    associationName: j['associationName'],
    created: j['created'],
    dispatchRecordId: j['dispatchRecordId'],
    passengers: j['passengers'],
    ownerId: j['ownerId'],
    marshalId: j['marshalId'],
    marshalName: j['marshalName'],
    vehicleArrivalId: j['vehicleArrivalId'],
    dispatched: j['dispatched'],
    geoHash: j['geoHash'],
    routeName: j['routeName'],
    routeLandmarkId: j['routeLandmarkId'],
    landmarkName: j['landmarkName'],
    routeId: j['routeId'],
    position: j['position'] == null? null: buildPosition(j['position']),
  );
  return m;
}

CommuterRequest buildCommuterRequest(Map j) {
  late rm.ObjectId id = _getId(j);

  var m = CommuterRequest(
    id,
    commuterId: j['commuterId'],
    commuterRequestId: j['commuterRequestId'],
    associationId: j['associationId'],
    routeId: j['routeId'],
    routeName: j['routeName'],
    dateRequested: j['dateRequested'],
    routeLandmarkId: j['routeLandmarkId'],
    routeLandmarkName: j['routeLandmarkName'],
    dateNeeded: j['dateNeeded'],
    scanned: j['scanned'],
    routePointIndex: j['routePointIndex'],
    numberOfPassengers: j['numberOfPassengers'],
    distanceToRouteLandmarkInMetres: j['distanceToRouteLandmarkInMetres'],
    distanceToRoutePointInMetres: j['distanceToRoutePointInMetres'],
    currentPosition: buildPosition(j['currentPosition']),
  );
  return m;
}

VehicleArrival buildVehicleArrival(Map j) {
  //
  //myPrettyJsonPrint(j);

  late rm.ObjectId id = _getId(j);
  var m = VehicleArrival(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    associationName: j['associationName'],
    created: j['created'],
    vehicleArrivalId: j['vehicleArrivalId'],
    landmarkName: j['landmarkName'],
    ownerId: j['ownerId'],
    make: j['make'],
    model: j['model'],
    ownerName: j['ownerName'],
    dispatched: j['dispatched'],
    geoHash: j['geoHash'],
    landmarkId: j['landmarkId'],
    position: j['position'] == null? null: buildPosition(j['position']),
  );
  return m;
}

VehicleDeparture buildVehicleDeparture(Map j) {
  //
  //myPrettyJsonPrint(j);

  late rm.ObjectId id = _getId(j);

  var m = VehicleDeparture(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    associationName: j['associationName'],
    created: j['created'],
    vehicleDepartureId: j['vehicleDepartureId'],
    landmarkName: j['landmarkName'],
    ownerId: j['ownerId'],
    make: j['make'],
    model: j['model'],
    ownerName: j['ownerName'],
    dispatched: j['dispatched'],
    geoHash: j['geoHash'],
    landmarkId: j['landmarkId'],
    position: j['position'] == null? null: buildPosition(j['position']),
  );
  return m;
}

VehicleHeartbeat buildVehicleHeartbeat(Map j) {
  //
  //myPrettyJsonPrint(j);
  late rm.ObjectId id = _getId(j);
  var m = VehicleHeartbeat(
    id,
    vehicleId: j['vehicleId'],
    vehicleHeartbeatId: j['vehicleHeartbeatId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    created: j['created'],
    ownerId: j['ownerId'],
    appToBackground: j['appToBackground'],
    make: j['make'],
    model: j['model'],
    ownerName: j['ownerName'],
    geoHash: j['geoHash'],
    position: j['position'] == null? null: buildPosition(j['position']),
    longDate: j['longDate'],
  );
  return m;
}

rm.ObjectId _getId(Map<dynamic, dynamic> j) {
  // late rm.ObjectId id;
  // try {
  //   if (j['_id'] == null) {
  //       id = rm.ObjectId();
  //     } else {
  //       id = rm.ObjectId.fromHexString(j['_id'] as String);
  //     }
  // } catch (e,s) {
  //   pp('.... PROBLEM WITH ID .......');
  //   pp('$e $s');
  // }
  return rm.ObjectId();
}

CalculatedDistance buildCalculatedDistance(Map map) {
  late rm.ObjectId id = _getId(map);

  final m = CalculatedDistance(
    id,
    routeId: map['routeId'],
    index: map['index'],
    distanceFromStart: map['distanceFromStart'],
    fromLandmark: map['fromLandmark'],
    toLandmarkId: map['toLandmarkId'],
    associationId: map['associationId'],
    distanceInMetres: map['distanceInMetres'],
    fromLandmarkId: map['fromLandmarkId'],
    fromRoutePointIndex: map['fromRoutePointIndex'],
    routeName: map['routeName'],
    toLandmark: map['toLandmark'],
    toRoutePointIndex: map['toRoutePointIndex'],
  );
  return m;
}

UserGeofenceEvent buildUserGeofenceEvent(Map j) {
  late rm.ObjectId id = _getId(j);
  var m = UserGeofenceEvent(
    id,
    userId: j['userId'],
    action: j['action'],
    associationId: j['associationId'],
    associationName: j['associationName'],
    created: j['created'],
    activityType: j['activityType'],
    landmarkName: j['landmarkName'],
    confidence: j['confidence'],
    odometer: j['odometer'],
    geoHash: j['geoHash'],
    landmarkId: j['landmarkId'],
    position: buildPosition(j['position']),
  );
  return m;
}

LocationRequest buildLocationRequest(Map j) {
  late rm.ObjectId id = _getId(j);
  var m = LocationRequest(
    id,
    userId: j['userId'],
    vehicleId: j['vehicleId'],
    associationId: j['associationId'],
    vehicleReg: j['vehicleReg'],
    userName: j['userName'],
    created: j['created'],
  );
  return m;
}

AmbassadorCheckIn buildAmbassadorCheckIn(Map j) {
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = AmbassadorCheckIn(
    id,
    userId: j['userId'],
    vehicleId: j['vehicleId'],
    associationId: j['associationId'],
    vehicleReg: j['vehicleReg'],
    userName: j['userName'],
    created: j['created'],
    position: buildPosition(j['position']),
  );
  return m;
}

AmbassadorPassengerCount buildAmbassadorPassengerCount(Map j) {
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = AmbassadorPassengerCount(
    id,
    userId: j['userId'],
    vehicleId: j['vehicleId'],
    associationId: j['associationId'],
    vehicleReg: j['vehicleReg'],
    userName: j['userName'],
    created: j['created'],
    ownerId: j['ownerId'],
    ownerName: j['ownerName'],
    position: buildPosition(j['position']),
    routeId: j['routeId'],
    routeName: j['routeName'],
    passengersIn: j['passengersIn'],
    passengersOut: j['passengersOut'],
    currentPassengers: j['currentPassengers'],
  );
  return m;
}

LocationResponse buildLocationResponse(Map j) {
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = LocationResponse(
    id,
    userId: j['userId'],
    vehicleId: j['vehicleId'],
    associationId: j['associationId'],
    vehicleReg: j['vehicleReg'],
    userName: j['userName'],
    created: j['created'],
    geoHash: j['geoHash'],
    position: buildPosition(j['position']),
  );
  return m;
}

VehiclePhoto buildVehiclePhoto(Map j) {
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = VehiclePhoto(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    userName: j['associationName'],
    created: j['created'],
    vehiclePhotoId: j['vehiclePhotoId'],
    landmarkName: j['landmarkName'],
    userId: j['userId'],
    url: j['url'],
    thumbNailUrl: j['thumbNailUrl'],
    geoHash: j['geoHash'],
    landmarkId: j['landmarkId'],
    position: buildPosition(j['position']),
  );
  return m;
}

VehicleVideo buildVehicleVideo(Map j) {
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = VehicleVideo(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    userName: j['associationName'],
    created: j['created'],
    vehicleVideoId: j['vehicleVideoId'],
    landmarkName: j['landmarkName'],
    userId: j['userId'],
    url: j['url'],
    thumbNailUrl: j['thumbNailUrl'],
    geoHash: j['geoHash'],
    landmarkId: j['landmarkId'],
    position: buildPosition(j['position']),
  );
  return m;
}

VehicleMediaRequest buildVehicleMediaRequest(Map j) {
  //myPrettyJsonPrint(j);
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = VehicleMediaRequest(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    addVideo: j['addVideo'],
    created: j['created'],
    requesterId: j['requesterId'],
    requesterName: j['requesterName'],
    userId: j['userId'],
  );
  return m;
}

AppError buildAppError(Map j) {
  //myPrettyJsonPrint(j);
  var id = rm.ObjectId.fromHexString(j['_id'] as String);

  var m = AppError(
    id,
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    errorMessage: j['errorMessage'],
    created: j['created'],
    appErrorId: j['appErrorId'],
    deviceType: j['deviceType'],
    baseOS: j['baseOS'],
    model: j['model'],
    uploadedDate: j['uploadedDate'],
    brand: j['brand'],
    errorPosition: j['errorPosition'] == null ? null : buildPosition(
        j['errorPosition']),
    userUrl: j['userUrl'],
    userName: j['userName'],
    userId: j['userId'],
    manufacturer: j['manufacturer'],
    versionCodeName: j['versionCodeName'],
    iosName: j['iosName'],
    iosSystemName: j['iosSystemName'],
  );
  return m;
}


RouteUpdateRequest buildRouteUpdateRequest(Map j) {
  //myPrettyJsonPrint(j);
  var id = rm.ObjectId.fromHexString(j['_id'] as String);
  var m = RouteUpdateRequest(
    id,
    routeId: j['routeId'],
    routeName: j['routeName'],
    associationId: j['associationId'],
    userName: j['userName'],
    created: j['created'],
    userId: j['userId'],
  );
  return m;
}

const point = 'Point';
