import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Country {
  String? countryId;
  String? name;
  String? iso2;

  Map<String, dynamic> toJson() {
    var map = {
      'countryId': countryId,
      'name': name,
      'iso2': iso2,
    };
    return map;
  }
}
@RealmModel(ObjectType.embeddedObject)
class _Position  {

  String? type = 'Point';
  List<double> coordinates = [];
  double? latitude, longitude;


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
  String? cityId;
  String? countryId;
  String? name, distance;
  String? stateName;
  double? latitude;
  double? longitude;
  String? countryName;
  _Position? position;




  Map<String, dynamic> toJson() => <String, dynamic>{
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
  double? latitude;
  double? longitude;
  double? heading;
  int? index;
  String? created, routeId;
  String? landmarkId, landmarkName;
  _Position? position;


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['created'] = created;
    map['index'] = index;

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

    return map;
  }
}
@RealmModel()
class _Route {
  String? routeId, countryId, countryName, name, routeNumber;
  String? created, updated;
  String? color;
  bool? isActive;
  String? activationDate;
  String? associationId, associationName;
  List<_CalculatedDistance> calculatedDistances = [];
  double? heading;
  int? lengthInMetres;
  String? userId;
  String? userName;
  String? userUrl;
  List<String> landmarkIds = [];


  Map<String, dynamic> toJson() {
    
    var distances = [];
    if (calculatedDistances.isNotEmpty) {
      for (var v in calculatedDistances!) {
        distances.add(v.toJson());
      }
    }

    Map<String, dynamic> map = {
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
    };
    return map;
  }
}
@RealmModel(ObjectType.embeddedObject)
class _CalculatedDistance {
  String? routeName, routeID;
  String? fromLandmark, toLandmark, fromLandmarkID, toLandmarkID;
  double? distanceInMetres, distanceFromStart;
  int? fromRoutePointIndex, toRoutePointIndex;


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeID': routeID,
      'name': routeName,
      'fromLandmark': fromLandmark,
      'toLandmark': toLandmark,
      'fromLandmarkID': fromLandmarkID,
      'toLandmarkID': toLandmarkID,
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
  String? adminUserFirstName;
  String? adminUserLastName;
  String? userId;
  String? adminCellphone;
  String? adminEmail;


  Map<String, dynamic> toJson() => <String, dynamic>{
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
    'position': position == null? null: position!.toJson(),

  };

}
@RealmModel()
class _AppError {
  String? errorMessage;
  String? manufacturer;
  String? model;
  String? created;
  String? brand;
  String? userId;
  String? associationId;
  String? userName;
  _Position? errorPosition;
  String? iosName;
  String? versionCodeName;

  String? baseOS;
  String? deviceType;
  String? iosSystemName;
  String? userUrl;
  String? uploadedDate;
  String? id;



  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
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
      'id': id,
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
  String? name, routeID, associationID, associationName;
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'routeID': routeID,
      'name': name,
      'associationID': associationID,
      'associationName': associationName,
    };
    return map;
  }
}

@RealmModel()
class _Landmark {
  String? landmarkID;
  double? latitude;
  double? longitude;
  double? distance;
  String? landmarkName;
  List<_RouteInfo> routeDetails = [];
  List<String> cityIds = [];
  _Position? position;
  List<String> routePointIds = [];



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
    List mPoints = [];
    if (routePointIds.isNotEmpty) {
      for (var v in routePointIds) {
        mPoints.add(v);
      }
    }

    Map<String, dynamic> map = {
      'landmarkID': landmarkID,
      'latitude': position != null ? position!.coordinates![1] : null,
      'longitude': position != null ? position!.coordinates![0] : null,
      'distance': distance ?? 0.0,
      'landmarkName': landmarkName,
      'position': position != null ? position!.toJson() : null,
      'routeDetails': names,
      'cities': mCities,
      'routePoints': mPoints,
    };
    return map;
  }

  setPosition(position) {
    this.position = position;
  }
}
@RealmModel()
class _SettingsModel {
  String? associationId, locale;
  int? refreshRateInSeconds, themeIndex;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'locale': locale,
      'refreshRateInSeconds': refreshRateInSeconds,
      'themeIndex': themeIndex,
      'associationId': associationId,
    };
    return map;
  }
}





