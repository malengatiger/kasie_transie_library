import '../data/schemas.dart';
import 'package:realm/realm.dart' as rm;

import 'emojis.dart';
import 'functions.dart';

///functions to parse data fromJson
///
///
Association buildAssociation(Map map) {
  var id = rm.ObjectId.fromHexString(map['_id'] as String);

  final m = Association(id,
    userId: map['userId'],
    countryId: map['countryId'],
    countryName: map['countryName'],
    cityId: map['cityId'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    status: map['status'],
    adminCellphone: map['adminCellphone'],
    adminEmail: map['adminEmail'],
    adminUserFirstName: map['adminUserFirstName'],
    adminUserLastName: map['adminUserLastName'],
    cityName: map['cityName'],
    date: map['date'],
    dateRegistered: map['dateRegistered'],
  );
  return m;
}

User buildUser(Map map) {
  // pp('${E.broc}  json for User, check _id .......');
  // myPrettyJsonPrint(map);
  var id = rm.ObjectId.fromHexString(map['_id'] as String);
  final m = User(id,
    userId: map['userId'],
    firstName: map['firstName'],
    lastName: map['lastName'],
    countryId: map['countryId'],
    associationId: map['associationId'],
    associationName: map['associationName'],
    imageUrl: map['imageUrl'],
    thumbnailUrl: map['thumbnailUrl'],
    userType: map['userType'],
    email: map['email'],
    cellphone: map['cellphone'],
    gender: map['gender'],
    fcmToken: map['fcmToken'],
  );
  return m;
}

SettingsModel buildSettingsModel(Map map) {
  var id = rm.ObjectId.fromHexString(map['_id'] as String);
  final m = SettingsModel(id,
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
  var id = rm.ObjectId.fromHexString(value['_id'] as String);
  var m = Country(id,
      countryId: value['countryId'],
      name: value['name'],
      latitude: value['latitude'],
      longitude: value['longitude'],
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

  return m;
}
//
City buildCity(Map map) {
  var id = rm.ObjectId.fromHexString(map['_id'] as String);

  final m = City(id,
    cityId: map['cityId'],
    name: map['name'],
    countryName: map['countryName'],
    countryId: map['countryId'],
    stateName: map['stateName'],
    longitude: map['longitude'],
    latitude: map['latitude'],
    position: Position(
        type: 'Point',
        latitude: map['position']['latitude'],
        longitude: map['position']['longitude'],
        coordinates: [
          map['position']['longitude'],
          map['position']['latitude']
        ]),
    distance: map['distance'],
  );
  return m;
}

Route buildRoute(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);
  var distances = <CalculatedDistance>[];
  List list = value['calculatedDistances'];
  for (var d in list) {
    distances.add(buildCalculatedDistance(d));
  }
  var ids = <String>[];
  List mList = value['landmarkIds'];
  for (var element in mList) {
    ids.add(element as String);
  }

  var dd = value['routeStartEnd'];

  // pp('🔵🔵🔵 buildRoute: check startCityPosition:  ${dd['startCityPosition']}');

  List st = dd['startCityPosition']['coordinates'];
  var lat = st.last as double;
  var lng = st.first as double;
  List st2 = dd['endCityPosition']['coordinates'];
  var lat2 = st.last as double;
  var lng2 = st.first as double;

  final startCityPosition = Position(
    type: 'Point',
    coordinates: [lng, lat],
  );
  // pp('🔵🔵🔵 buildRoute: check endCityPosition:  ${dd['endCityPosition']}');

  final endCityPosition = Position(
    type: 'Point',
    coordinates: [lng2, lat2],
  );
  var se = RouteStartEnd(
    startCityId: dd['startCityId'],
    startCityName: dd['startCityName'],
    endCityId: dd['endCityId'],
    endCityName: dd['endCityName'],
    startCityPosition: startCityPosition,
    endCityPosition: endCityPosition,
  );
  
  var m = Route(id,
    countryId: value['countryId'],
    routeId: value['routeId'],
    associationId: value['associationId'],
    userId: value['userId'],
    created: value['created'],
    heading: value['heading'],
    name: value['name'],
    routeStartEnd: se,
    userName: value['userName'],
    userUrl: value['userUrl'],
    countryName: value['countryName'],
    color: value['color'],
    activationDate: value['activationDate'],
    associationName: value['associationName'],
    calculatedDistances: distances,
    landmarkIds: ids,
    lengthInMetres: value['lengthInMetres'],
    routeNumber: value['routeNumber'],
  );
  return m;
}

RoutePoint buildRoutePoint(Map value) {
  var id = rm.ObjectId.fromHexString(value['_id'] as String);

  var m = RoutePoint(id,
    routePointId: value['routePointId'],
    longitude: value['longitude'],
    routeId: value['routeId'],
    index: value['index'],
    latitude: value['userId'],
    created: value['created'],
    heading: value['heading'],
    landmarkId: value['landmarkId'],
    landmarkName: value['landmarkName'],
    geoHash: value['geoHash'],

    position: Position(
      type: 'Point',
      latitude: value['position']['latitude'],
      longitude: value['position']['longitude'],
      coordinates: [
        value['position']['longitude'],
        value['position']['latitude'],
      ],
    ),
  );
  return m;
}

Vehicle buildVehicle(Map vehicleJson) {
  var id = rm.ObjectId.fromHexString(vehicleJson['_id'] as String);
  var m = Vehicle(id,
    vehicleId: vehicleJson['vehicleId'],
    vehicleReg: vehicleJson['vehicleReg'],
    associationId: vehicleJson['associationId'],
    associationName: vehicleJson['associationName'],
    created: vehicleJson['created'],
    make: vehicleJson['make'],
    model: vehicleJson['model'],
    year: vehicleJson['year'],
    countryId: vehicleJson['countryId'],
    dateInstalled: vehicleJson['dateInstalled'],
    ownerId: vehicleJson['ownerId'],
    ownerName: vehicleJson['ownerName'],
  );
  return m;
}

CalculatedDistance buildCalculatedDistance(Map map) {
  final m = CalculatedDistance(
    routeId: map['routeId'],
    distanceFromStart: map['distanceFromStart'],
    fromLandmark: map['fromLandmark'],
    toLandmarkId: map['toLandmarkId'],
    distanceInMetres: map['distanceInMetres'],
    fromLandmarkId: map['fromLandmarkId'],
    fromRoutePointIndex: map['fromRoutePointIndex'],
    routeName: map['routeName'],
    toLandmark: map['toLandmark'],
    toRoutePointIndex: map['toRoutePointIndex'],
  );
  return m;
}

