import 'package:realm/realm.dart';

import '../utils/functions.dart';
part 'schemas.g.dart';

@RealmModel()
class _Country {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? countryId;
  String? name;
  String? iso2;
  String? iso3;
  String? capital;
  String? currency;
  String? region;
  String? subregion;
  String? emoji;
  String? phone_code;
  String? currency_name;
  String? currency_symbol;
  double? latitude, longitude;
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() {
    var map = {
      '_id': id.hexString,
      'countryId': countryId,
      'name': name,
      'iso2': iso2,
      'iso3': iso3,
      'capital': capital,
      'region': region,
      'subregion': subregion,
      'emoji': emoji,
      'phone_code': phone_code,
      'currency_name': currency_name,
      'currency_symbol': currency_symbol,
      'latitude': latitude,
      'longitude': longitude,
    };
    return map;
  }
}

@RealmModel(ObjectType.embeddedObject)
class _Position {
  String? type = 'Point';
  List<double> coordinates = [];
  double? latitude, longitude;
  String? geoHash;

  Map<String, dynamic> toJson() {
    var m = [];
    for (var element in coordinates) {
      m.add(element);
    }
    Map<String, dynamic> map = {
      'type': type,
      'longitude': longitude,
      'latitude': latitude,
      'coordinates': m,
    };
    return map;
  }
}

@RealmModel()
class _City {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? cityId;
  String? countryId;
  String? name, distance;
  String? stateName;
  double? latitude;
  double? longitude;
  String? countryName;
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id.hexString,
        'cityId': cityId,
        'countryId': countryId,
        'name': name,
        'stateName': stateName,
        'latitude': latitude,
        'longitude': longitude,
        'countryName': countryName,
        'position': position == null ? null : position!.toJson(),
        'distance': distance,
      };
}

@RealmModel()
class _RoutePoint {
  @PrimaryKey()
  late ObjectId id;
  String? routePointId;
  double? latitude;
  double? longitude;
  double? heading;
  int? index;
  String? created;
  @Indexed()
  String? routeId;
  String? landmarkId, landmarkName;
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['routePointId'] = routePointId;
    map['created'] = created;
    map['index'] = index;
    map['_id'] = id.hexString;
    map['latitude'] = latitude;
    map['longitude'] = longitude;

    if (routeId != null) {
      map['routeId'] = routeId;
    }
    if (position != null) {
      map['position'] = position!.toJson();
    }
    if (landmarkId != null) {
      map['landmarkId'] = landmarkId;
    }
    if (landmarkName != null) {
      map['landmarkName'] = landmarkName;
    }
    map['heading'] = heading;
    map['geoHash'] = geoHash;
    return map;
  }
}

@RealmModel()
class _Route {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? routeId;
  String? countryId, countryName, name, routeNumber;
  String? created, updated;
  String? color;
  bool? isActive;
  String? activationDate;
  String? associationId, associationName;
  double? heading;
  int? lengthInMetres;
  String? userId;
  String? userName;
  String? userUrl;
  _RouteStartEnd? routeStartEnd;

  List<_CalculatedDistance> calculatedDistances = [];
  List<String> geoHashes = [];
  List<String> landmarkIds = [];

  Map<String, dynamic> toJson() {
    var distances = [];
    if (calculatedDistances.isNotEmpty) {
      for (var v in calculatedDistances!) {
        distances.add(v.toJson());
      }
    }
    var se = {};
    if (routeStartEnd != null) {
      final pos1 = {
        'type': 'Point',
        'coordinates': routeStartEnd!.startCityPosition!.coordinates,
      };
      final pos2 = {
        'type': 'Point',
        'coordinates': routeStartEnd!.endCityPosition!.coordinates,

      };
      se['startCityId'] = routeStartEnd!.startCityId!;
      se['startCityName'] = routeStartEnd!.startCityName!;
      se['endCityId'] = routeStartEnd!.endCityId!;
      se['endCityName'] = routeStartEnd!.endCityName!;
      se['startCityPosition'] = pos1;
      se['endCityPosition'] = pos2;

    }
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'routeId': routeId,
      'countryId': countryId,
      'name': name,
      'lengthInMetres': lengthInMetres,
      'countryName': countryName,
      'routeNumber': routeNumber,
      'created': created,
      'updated': updated,
      'color': color,
      'activationDate': activationDate,
      'isActive': isActive,
      'heading': heading ?? 0.0,
      'associationId': associationId,
      'associationName': associationName,
      'calculatedDistances': distances,
      'userId': userId,
      'userName': userName,
      'userUrl': userUrl,
      'routeStartEnd': se,
    };

    return map;
  }
}

//
@RealmModel()
class _Vehicle {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? vehicleId;
  String? countryId, ownerName, ownerId;
  String? created, dateInstalled;
  String? vehicleReg;
  String? make;
  String? model;
  String? year;
  int? passengerCapacity;
  String? associationId, associationName;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'vehicleId': vehicleId,
      'countryId': countryId,
      'ownerName': ownerName,
      'vehicleReg': vehicleReg,
      'ownerId': ownerId,
      'created': created,
      'dateInstalled': dateInstalled,
      'make': make,
      'model': model,
      'year': year,
      'passengerCapacity': passengerCapacity,
      'associationId': associationId,
      'associationName': associationName,
    };
    return map;
  }
}

@RealmModel(ObjectType.embeddedObject)
class _CalculatedDistance {
  String? routeName, routeId;
  String? fromLandmark, toLandmark, fromLandmarkId, toLandmarkId;
  double? distanceInMetres, distanceFromStart;
  int? fromRoutePointIndex, toRoutePointIndex;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeId': routeId,
      'routeName': routeName,
      'fromLandmark': fromLandmark,
      'toLandmark': toLandmark,
      'fromLandmarkId': fromLandmarkId,
      'toLandmarkId': toLandmarkId,
      'distanceInMetres': distanceInMetres,
      'distanceFromStart': distanceFromStart,
      'fromRoutePointIndex': fromRoutePointIndex,
      'toRoutePointIndex': toRoutePointIndex,
    };
    return map;
  }

  String getPrintOut() {
    String sb = '${(distanceInMetres! / 1000).toStringAsFixed(1)} km '
        'from $fromLandmark to $toLandmark ';
    //p('${sb.toString()}');
    return sb;
  }
}

@RealmModel()
class _Association {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? associationId;
  String? cityId;
  String? countryId;
  String? associationName;
  String? phone;
  String? status;
  String? countryName;
  String? cityName;
  String? stringDate;
  int? date;
  String? path;
  String? dateRegistered;
  _Position? position;
  String? geoHash;
  String? adminUserFirstName;
  String? adminUserLastName;
  String? userId;
  String? adminCellphone;
  String? adminEmail;

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id.hexString,
        'associationId': associationId,
        'cityId': cityId,
        'countryId': countryId,
        'associationName': associationName,
        'phone': phone,
        'status': status,
        'countryName': countryName,
        'cityName': cityName,
        'stringDate': stringDate,
        'date': date,
        'path': path,
        'position': position == null ? null : position!.toJson(),
      };
}

@RealmModel()
class _AppError {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? appErrorId;
  String? errorMessage;
  String? manufacturer;
  String? model;
  String? created;
  String? brand;
  String? userId;
  String? associationId;
  String? userName;
  _Position? errorPosition;
  String? geoHash;
  String? iosName;
  String? versionCodeName;
  String? baseOS;
  String? deviceType;
  String? iosSystemName;
  String? userUrl;
  String? uploadedDate;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'errorMessage': errorMessage,
      'userUrl': userUrl,
      'iosSystemName': iosSystemName,
      'model': model,
      'created': created,
      'deviceType': deviceType,
      'baseOS': baseOS,
      'userId': userId,
      'associationId': associationId,
      'brand': brand,
      'uploadedDate': uploadedDate,
      'userName': userName,
      'iosName': iosName,
      'versionCodeName': versionCodeName,
      'manufacturer': manufacturer,
      'errorPosition': errorPosition == null ? null : errorPosition!.toJson()
    };
    return map;
  }
}

@RealmModel()
class _User {
  String? userType;
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? userId;
  String? firstName, lastName, gender;
  String? countryId;
  String? associationId;
  String? associationName;
  String? fcmToken;
  String? email;
  String? cellphone, thumbnailUrl, imageUrl;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'userType': userType,
      'userId': userId,
      'lastName': lastName,
      'firstName': firstName,
      'countryId': countryId,
      'associationId': associationId,
      'associationName': associationName,
      'fcmToken': fcmToken,
      'email': email,
      'cellphone': cellphone,
      'gender': gender,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
    };
    return map;
  }

  String get name => '$firstName $lastName';
}

@RealmModel(ObjectType.embeddedObject)
class _RouteInfo {
  String? name, routeId, associationId, associationName;
  String? number;
  String? color;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeId': routeId,
      'name': name,
      'number': number,
      'color': color,
      'associationId': associationId,
      'associationName': associationName,
    };
    return map;
  }
}

@RealmModel()
class _Landmark {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? landmarkId;
  double? latitude;
  double? longitude;
  double? distance;
  String? landmarkName;
  List<_RouteInfo> routeDetails = [];
  List<String> cityIds = [];
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() {
    List names = [];
    if (routeDetails.isNotEmpty) {
      for (var v in routeDetails) {
        names.add(v.toJson());
      }
    }
    List mCities = [];
    if (cityIds.isNotEmpty) {
      for (var v in cityIds) {
        mCities.add(v);
      }
    }

    Map<String, dynamic> map = {
      '_id': id.hexString,
      'landmarkId': landmarkId,
      'latitude': position != null ? position!.coordinates![1] : null,
      'longitude': position != null ? position!.coordinates![0] : null,
      'distance': distance ?? 0.0,
      'landmarkName': landmarkName,
      'position': position != null ? position!.toJson() : null,
      'routeDetails': names,
      'cities': mCities,
    };
    return map;
  }

  setPosition(position) {
    this.position = position;
  }
}

@RealmModel()
class _SettingsModel {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? associationId;
  String? locale, created;
  int? refreshRateInSeconds, themeIndex;
  int? geofenceRadius, commuterGeofenceRadius;
  int? vehicleSearchMinutes,
      heartbeatIntervalSeconds,
      loiteringDelay,
      commuterSearchMinutes,
      commuterGeoQueryRadius,
      vehicleGeoQueryRadius,
      numberOfLandmarksToScan;
  int? distanceFilter;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'locale': locale,
      'loiteringDelay': loiteringDelay,
      'created': created,
      'refreshRateInSeconds': refreshRateInSeconds,
      'themeIndex': themeIndex,
      'distanceFilter': distanceFilter,
      'associationId': associationId,
      'geofenceRadius': geofenceRadius,
      'commuterGeofenceRadius': commuterGeofenceRadius,
      'vehicleSearchMinutes': vehicleSearchMinutes,
      'heartbeatIntervalSeconds': heartbeatIntervalSeconds,
      'commuterGeoQueryRadius': commuterGeoQueryRadius,
      'vehicleGeoQueryRadius': vehicleGeoQueryRadius,
      'numberOfLandmarksToScan': numberOfLandmarksToScan,
    };
    return map;
  }
}

// @RealmModel()
// class _RouteNew {
//   @PrimaryKey()
//   late ObjectId id;
//   @Indexed()
//   String? routeId;
//   String? countryId, countryName, name, routeNumber;
//   String? created, updated;
//   String? color;
//   bool? isActive;
//   String? activationDate;
//   String? associationId, associationName;
//   double? heading;
//   int? lengthInMetres;
//   String? userId;
//   String? userName;
//   String? userUrl;
//   _RouteStartEnd? routeStartEnd;
//
//   List<_CalculatedDistance> calculatedDistances = [];
//   List<String> geoHashes = [];
//   List<String> landmarkIds = [];
//
//   Map<String, dynamic> toJson() {
//     var distances = [];
//     if (calculatedDistances.isNotEmpty) {
//       for (var v in calculatedDistances!) {
//         distances.add(v.toJson());
//       }
//     }
//     var se = {};
//     if (routeStartEnd != null) {
//       se['startCityId'] = routeStartEnd!.startCityId!;
//       se['startCityName'] = routeStartEnd!.startCityName!;
//       se['endCityId'] = routeStartEnd!.endCityId!;
//       se['endCityName'] = routeStartEnd!.endCityName!;
//       se['startLatitude'] = routeStartEnd!.startLatitude!;
//       se['startLongitude'] = routeStartEnd!.startLongitude!;
//       se['endLatitude'] = routeStartEnd!.endLatitude!;
//       se['endLongitude'] = routeStartEnd!.endLongitude!;
//     }
//
//     Map<String, dynamic> map = {
//       '_id': id.hexString,
//       'routeId': routeId,
//       'countryId': countryId,
//       'name': name,
//       'lengthInMetres': lengthInMetres,
//       'countryName': countryName,
//       'routeNumber': routeNumber,
//       'created': created,
//       'updated': updated,
//       'color': color,
//       'routeStartEnd': se,
//       'activationDate': activationDate,
//       'isActive': isActive,
//       'heading': heading ?? 0.0,
//       'associationId': associationId,
//       'associationName': associationName,
//       'calculatedDistances': distances,
//       'userId': userId,
//       'userName': userName,
//       'userUrl': userUrl,
//     };
//     return map;
//   }
// }
//
// @RealmModel()
// class _RoutePointNew {
//   @PrimaryKey()
//   late ObjectId id;
//   String? routePointId;
//   double? latitude;
//   double? longitude;
//   double? heading;
//   int? index;
//   String? created;
//   @Indexed()
//   String? routeId;
//   String? landmarkId, landmarkName;
//   _Position? position;
//   String? geoHash;
//
//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> map = Map();
//     map['created'] = created;
//     map['index'] = index;
//     map['_id'] = id.hexString;
//     map['latitude'] = latitude;
//     map['longitude'] = longitude;
//
//     if (routeId != null) {
//       map['routeId'] = routeId;
//     }
//     if (position != null) {
//       map['position'] = position!.toJson();
//     }
//     if (landmarkId != null) {
//       map['landmarkId'] = landmarkId;
//     }
//     if (landmarkName != null) {
//       map['landmarkName'] = landmarkName;
//     }
//     map['heading'] = heading;
//
//     return map;
//   }
// }

@RealmModel(ObjectType.embeddedObject)
class _RouteStartEnd {
  String? startCityId, startCityName;
  String? endCityId, endCityName;

  _Position? startCityPosition;
  _Position? endCityPosition;

  Map<String, dynamic> toJson() {
    var sp = {};
    var ep = {};
    if (endCityPosition != null) {
      ep['coordinates'] = endCityPosition!.coordinates;
      ep['type'] = 'Point';
    }
    if (startCityPosition != null) {
      sp['coordinates'] = startCityPosition!.coordinates;
      sp['type'] = 'Point';
    }
    Map<String, dynamic> map = {
      'startCityPosition': sp,
      'endCityPosition': ep,
      'startCityId': startCityId,
      'startCityName': startCityName,
      'endCityId': endCityId,
      'endCityName': endCityName,
    };
    return map;
  }
}
