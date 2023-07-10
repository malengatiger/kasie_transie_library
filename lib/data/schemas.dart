import 'package:realm/realm.dart';

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
  String? stateId;
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id.hexString,
        'cityId': cityId,
        'countryId': countryId,
        'name': name,
        'stateId': stateId,
        'stateName': stateName,
        'latitude': latitude,
        'longitude': longitude,
        'countryName': countryName,
        'position': position == null ? null : position!.toJson(),
        'distance': distance,
      };
}

@RealmModel()
class _DispatchRecord {
  @PrimaryKey()
  late ObjectId id;
  String? dispatchRecordId;
  String? landmarkId;
  String? marshalId;
  int? passengers;
  String? ownerId;
  String? created;
  _Position? position;
  String? geoHash;
  String? landmarkName;
  String? marshalName;
  String? routeName;
  String? routeId;
  String? vehicleId;
  String? vehicleArrivalId;
  String? vehicleReg;
  String? associationId;
  String? associationName;
  bool? dispatched;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['dispatchRecordId'] = dispatchRecordId;
    map['_id'] = id.hexString;
    map['landmarkId'] = landmarkId;
    map['passengers'] = passengers;
    map['vehicleId'] = vehicleId;
    map['ownerId'] = ownerId;
    map['routeId'] = routeId;
    map['marshalId'] = marshalId;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['marshalName'] = marshalName;
    map['routeName'] = routeName;
    map['vehicleArrivalId'] = vehicleArrivalId;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['associationName'] = associationName;
    map['dispatched'] = dispatched;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

/*
 String associationId;
    String cityId;
    String countryId;
    String associationName;
    int active;
    String countryName;
    String cityName;
    String dateRegistered;
    Position position;
    String geoHash;
    String adminUserFirstName;
    String adminUserLastName;
    String userId;
    String adminCellphone;
    String adminEmail;
 */
@RealmModel()
class _Association {
  @PrimaryKey()
  late ObjectId id;
  String? cityId;
  String? countryId;
  String? cityName, associationName, associationId;
  int? active;
  String? countryName;
  String? dateRegistered;
  _Position? position;
  String? geoHash;
  String? adminUserFirstName;
  String? adminUserLastName;
  String? userId;
  String? adminCellphone;
  String? adminEmail;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['cityId'] = cityId;
    map['countryId'] = countryId;
    map['associationId'] = associationId;
    map['associationName'] = associationName;
    map['cityName'] = cityName;
    map['active'] = active;
    map['_id'] = id.hexString;
    map['countryName'] = countryName;
    map['dateRegistered'] = dateRegistered;
    map['geoHash'] = geoHash;
    map['adminUserFirstName'] = adminUserFirstName;
    map['adminUserLastName'] = adminUserLastName;
    map['userId'] = userId;
    map['adminCellphone'] = adminCellphone;
    map['adminEmail'] = adminEmail;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}
//

@RealmModel()
class _RouteUpdateRequest {
  @PrimaryKey()
  late ObjectId id;
  String? routeId;
  String? routeName;
  String? userId;
  String? created;
  String? associationId;
  String? userName;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['userId'] = userId;
    map['_id'] = id.hexString;
    map['routeId'] = routeId;
    map['routeName'] = routeName;
    map['userId'] = userId;
    map['created'] = created;
    map['userName'] = userName;
    map['associationId'] = associationId;
    return map;
  }
}

//
@RealmModel()
class _VehicleMediaRequest {
  @PrimaryKey()
  late ObjectId id;
  String? userId;
  String? vehicleId;
  String? vehicleReg;
  String? requesterId;
  String? created;
  String? associationId;
  String? requesterName;

  bool? addVideo;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['userId'] = userId;
    map['_id'] = id.hexString;
    map['requesterId'] = requesterId;
    map['vehicleId'] = vehicleId;
    map['requesterName'] = requesterName;
    map['created'] = created;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['addVideo'] = addVideo;
    return map;
  }
}
//
@RealmModel()
class _VehicleArrival {
  @PrimaryKey()
  late ObjectId id;
  String? vehicleArrivalId;
  String? landmarkId;
  String? landmarkName;
  _Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? associationName;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  bool? dispatched;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['landmarkId'] = landmarkId;
    map['_id'] = id.hexString;
    map['ownerId'] = ownerId;
    map['vehicleId'] = vehicleId;
    map['ownerId'] = ownerId;
    map['ownerName'] = ownerName;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['vehicleArrivalId'] = vehicleArrivalId;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['associationName'] = associationName;
    map['dispatched'] = dispatched;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}
@RealmModel()
class _VehiclePhoto {
  @PrimaryKey()
  late ObjectId id;
  String? vehiclePhotoId;
  String? landmarkId;
  String? landmarkName;
  _Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? thumbNailUrl;
  String? url;
  String? userId, userName;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['landmarkId'] = landmarkId;
    map['_id'] = id.hexString;
    map['url'] = url;
    map['vehicleId'] = vehicleId;
    map['thumbNailUrl'] = thumbNailUrl;
    map['userId'] = userId;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['vehiclePhotoId'] = vehiclePhotoId;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['userName'] = userName;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

@RealmModel()
class _VehicleVideo {
  @PrimaryKey()
  late ObjectId id;
  String? vehicleVideoId;
  String? landmarkId;
  String? landmarkName;
  _Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? thumbNailUrl;
  String? url;
  String? userId, userName;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['landmarkId'] = landmarkId;
    map['_id'] = id.hexString;
    map['url'] = url;
    map['vehicleId'] = vehicleId;
    map['thumbNailUrl'] = thumbNailUrl;
    map['userId'] = userId;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['vehicleVideoId'] = vehicleVideoId;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['userName'] = userName;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

@RealmModel()
class _VehicleDeparture {
  @PrimaryKey()
  late ObjectId id;
  String? vehicleDepartureId;
  String? landmarkId;
  String? landmarkName;
  _Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? associationName;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  bool? dispatched;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['landmarkId'] = landmarkId;
    map['_id'] = id.hexString;
    map['ownerId'] = ownerId;
    map['vehicleId'] = vehicleId;
    map['ownerId'] = ownerId;
    map['ownerName'] = ownerName;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['vehicleDepartureId'] = vehicleDepartureId;
    map['vehicleReg'] = vehicleReg;
    map['associationId'] = associationId;
    map['associationName'] = associationName;
    map['dispatched'] = dispatched;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

@RealmModel()
class _UserGeofenceEvent {
  @PrimaryKey()
  late ObjectId id;
  String? userGeofenceId;
  String? activityType;
  String? landmarkId;
  String? landmarkName;
  _Position? position;
  String? geoHash;
  String? created;
  String? action;
  String? associationId;
  String? associationName;
  String? userId;
  int? confidence;
  double? odometer;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['userGeofenceId'] = userGeofenceId;
    map['_id'] = id.hexString;
    map['landmarkId'] = landmarkId;
    map['action'] = action;
    map['userId'] = userId;
    map['confidence'] = confidence;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['landmarkName'] = landmarkName;
    map['activityType'] = activityType;
    map['associationId'] = associationId;
    map['associationName'] = associationName;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

@RealmModel()
class _VehicleHeartbeat {
  @PrimaryKey()
  late ObjectId id;
  String? vehicleHeartbeatId;

  _Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  int? longDate;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['ownerId'] = ownerId;
    map['_id'] = id.hexString;
    map['vehicleId'] = vehicleId;
    map['ownerName'] = ownerName;
    map['created'] = created;
    map['geoHash'] = geoHash;
    map['longDate'] = longDate;
    map['vehicleReg'] = vehicleReg;
    map['vehicleHeartbeatId'] = vehicleHeartbeatId;

    map['associationId'] = associationId;
    map['make'] = make;
    map['model'] = model;
    map['position'] = position == null ? null : position!.toJson();
    return map;
  }
}

@RealmModel()
class _RoutePoint {
  @PrimaryKey()
  late ObjectId id;
  String? routePointId;
  String? associationId;
  double? latitude;
  double? longitude;
  double? heading;
  int? index;
  String? created;
  @Indexed()
  String? routeId;
  String? routeName;
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['routePointId'] = routePointId;
    map['associationId'] = associationId;
    map['created'] = created;
    map['index'] = index;
    map['_id'] = id.hexString;

    map['latitude'] = latitude;
    map['longitude'] = longitude;

    map['routeId'] = routeId;
    map['routeName'] = routeName;

    if (position != null) {
      map['position'] = position!.toJson();
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

  Map<String, dynamic> toJson() {
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
  String? qrCodeUrl;
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
      'qrCodeUrl': qrCodeUrl,
      'passengerCapacity': passengerCapacity,
      'associationId': associationId,
      'associationName': associationName,
    };
    return map;
  }
}

@RealmModel()
class _CalculatedDistance {
  @PrimaryKey()
  late ObjectId id;

  String? routeName, routeId;
  String? fromLandmark, toLandmark, fromLandmarkId, toLandmarkId, associationId;
  double? distanceInMetres, distanceFromStart;
  int? fromRoutePointIndex, toRoutePointIndex, index;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeId': routeId,
      'index': index,
      '_id': id.hexString,
      'associationId': associationId,
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
  String? routeName, routeId;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeId': routeId,
      'routeName': routeName,
    };
    return map;
  }
}

@RealmModel()
class _AmbassadorPassengerCount {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;
  String? routeId;
  String? routeName;
  int? passengersIn;
  int? passengersOut;
  int? currentPassengers;
  _Position? position;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'userId': userId,
      'vehicleId': vehicleId,
      'userName': userName,
      'vehicleReg': vehicleReg,
      'created': created,
      'associationId': associationId,

      'routeId': routeId,
      'routeName': routeName,
      'passengersIn': passengersIn,
      'passengersOut': passengersOut,
      'currentPassengers': currentPassengers,
      'position': position == null ? null : position!.toJson(),

    };
    return map;
  }
}

@RealmModel()
class _AmbassadorCheckIn {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;
  _Position? position;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'userId': userId,
      'vehicleId': vehicleId,
      'userName': userName,
      'vehicleReg': vehicleReg,
      'created': created,
      'associationId': associationId,
      'position': position == null ? null : position!.toJson(),

    };
    return map;
  }
}
@RealmModel()
class _LocationRequest {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'userId': userId,
      'vehicleId': vehicleId,
      'userName': userName,
      'vehicleReg': vehicleReg,
      'created': created,
      'associationId': associationId,
    };
    return map;
  }
}

@RealmModel()
class _LocationResponse {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? userId;
  String? vehicleId, vehicleReg;
  String? geoHash;
  String? userName;
  String? created;
  String? associationId;
  _Position? position;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'geoHash': geoHash,
      'userId': userId,
      'vehicleReg': vehicleReg,
      'position': position == null ? null : position!.toJson(),
      'vehicleId': vehicleId,
      'userName': userName,
      'created': created,
      'associationId': associationId,
    };
    return map;
  }
}

@RealmModel()
class _RouteLandmark {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? routeId;
  String? routeName;
  String? landmarkId;
  String? landmarkName;
  String? created;
  String? associationId;
  String? routePointId;
  int? routePointIndex;
  int? index;
  _Position? position;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'landmarkId': landmarkId,
      'routeId': routeId,
      'routePointId': routePointId,
      'index': index,
      'routePointIndex': routePointIndex,
      'position': position == null ? null : position!.toJson(),
      'routeName': routeName,
      'landmarkName': landmarkName,
      'created': created,
      'associationId': associationId,
    };
    return map;
  }
}

@RealmModel()
class _RouteCity {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? routeId;
  String? routeName;
  String? cityId;
  String? cityName;
  String? created;
  String? associationId;
  _Position? position;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'cityId': cityId,
      'routeId': routeId,
      'position': position == null ? null : position!.toJson(),
      'routeName': routeName,
      'cityName': cityName,
      'created': created,
      'associationId': associationId,
    };
    return map;
  }
}

@RealmModel()
class _State {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  String? stateId;
  String? name;
  String? countryId;
  String? countryName;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '_id': id.hexString,
      'countryId': countryId,
      'stateId': stateId,
      'name': name,
      'countryName': countryName,
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
  _Position? position;
  String? geoHash;

  Map<String, dynamic> toJson() {
    List names = [];
    if (routeDetails.isNotEmpty) {
      for (var v in routeDetails) {
        names.add(v.toJson());
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
