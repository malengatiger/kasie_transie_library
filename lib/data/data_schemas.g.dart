// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_schemas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleTelemetry _$VehicleTelemetryFromJson(Map<String, dynamic> json) =>
    VehicleTelemetry(
      vehicleTelemetryId: json['vehicleTelemetryId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      created: json['created'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      passengerCapacity: (json['passengerCapacity'] as num?)?.toInt(),
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      nearestRouteName: json['nearestRouteName'] as String?,
      routeId: json['routeId'] as String?,
      nearestRouteLandmarkName: json['nearestRouteLandmarkName'] as String?,
      routeLandmarkId: json['routeLandmarkId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      altitudeAccuracy: (json['altitudeAccuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      speedAccuracy: (json['speedAccuracy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleTelemetryToJson(VehicleTelemetry instance) =>
    <String, dynamic>{
      'vehicleTelemetryId': instance.vehicleTelemetryId,
      'vehicleId': instance.vehicleId,
      'created': instance.created,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'passengerCapacity': instance.passengerCapacity,
      'position': instance.position?.toJson(),
      'nearestRouteName': instance.nearestRouteName,
      'routeId': instance.routeId,
      'nearestRouteLandmarkName': instance.nearestRouteLandmarkName,
      'routeLandmarkId': instance.routeLandmarkId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'accuracy': instance.accuracy,
      'heading': instance.heading,
      'altitude': instance.altitude,
      'altitudeAccuracy': instance.altitudeAccuracy,
      'speed': instance.speed,
      'speedAccuracy': instance.speedAccuracy,
    };

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      json['countryId'] as String?,
      json['name'] as String?,
      json['iso2'] as String?,
      json['iso3'] as String?,
      json['capital'] as String?,
      json['currency'] as String?,
      json['region'] as String?,
      json['subregion'] as String?,
      json['emoji'] as String?,
      json['phoneCode'] as String?,
      json['currencyName'] as String?,
      json['currencySymbol'] as String?,
      (json['latitude'] as num?)?.toDouble(),
      (json['longitude'] as num?)?.toDouble(),
      json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      json['geoHash'] as String?,
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'countryId': instance.countryId,
      'name': instance.name,
      'iso2': instance.iso2,
      'iso3': instance.iso3,
      'capital': instance.capital,
      'currency': instance.currency,
      'region': instance.region,
      'subregion': instance.subregion,
      'emoji': instance.emoji,
      'phoneCode': instance.phoneCode,
      'currencyName': instance.currencyName,
      'currencySymbol': instance.currencySymbol,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
    };

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geoHash: json['geoHash'] as String?,
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geoHash': instance.geoHash,
    };

City _$CityFromJson(Map<String, dynamic> json) => City(
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
      name: json['name'] as String?,
      distance: json['distance'] as String?,
      stateName: json['stateName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      countryName: json['countryName'] as String?,
      stateId: json['stateId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      created: json['created'] as String?,
      geoHash: json['geoHash'] as String?,
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'cityId': instance.cityId,
      'countryId': instance.countryId,
      'name': instance.name,
      'distance': instance.distance,
      'stateName': instance.stateName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'countryName': instance.countryName,
      'stateId': instance.stateId,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
    };

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      tripId: json['tripId'] as String?,
      dateStarted: json['dateStarted'] as String?,
      dateEnded: json['dateEnded'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'tripId': instance.tripId,
      'userId': instance.userId,
      'userName': instance.userName,
      'dateStarted': instance.dateStarted,
      'dateEnded': instance.dateEnded,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'position': instance.position?.toJson(),
      'created': instance.created,
    };

DispatchRecord _$DispatchRecordFromJson(Map<String, dynamic> json) =>
    DispatchRecord(
      dispatchRecordId: json['dispatchRecordId'] as String?,
      marshalId: json['marshalId'] as String?,
      passengers: (json['passengers'] as num?)?.toInt(),
      ownerId: json['ownerId'] as String?,
      created: json['created'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      landmarkName: json['landmarkName'] as String?,
      marshalName: json['marshalName'] as String?,
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleArrivalId: json['vehicleArrivalId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      routeLandmarkId: json['routeLandmarkId'] as String?,
      dispatched: json['dispatched'] as bool?,
    );

Map<String, dynamic> _$DispatchRecordToJson(DispatchRecord instance) =>
    <String, dynamic>{
      'dispatchRecordId': instance.dispatchRecordId,
      'marshalId': instance.marshalId,
      'passengers': instance.passengers,
      'ownerId': instance.ownerId,
      'created': instance.created,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'landmarkName': instance.landmarkName,
      'marshalName': instance.marshalName,
      'routeName': instance.routeName,
      'routeId': instance.routeId,
      'vehicleId': instance.vehicleId,
      'vehicleArrivalId': instance.vehicleArrivalId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'routeLandmarkId': instance.routeLandmarkId,
      'dispatched': instance.dispatched,
    };

Association _$AssociationFromJson(Map<String, dynamic> json) => Association(
      countryId: json['countryId'] as String?,
      associationName: json['associationName'] as String?,
      associationId: json['associationId'] as String?,
      active: (json['active'] as num?)?.toInt(),
      countryName: json['countryName'] as String?,
      dateRegistered: json['dateRegistered'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      adminUser: json['adminUser'] == null
          ? null
          : User.fromJson(json['adminUser'] as Map<String, dynamic>),
      carUser: json['carUser'] == null
          ? null
          : User.fromJson(json['carUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssociationToJson(Association instance) =>
    <String, dynamic>{
      'countryId': instance.countryId,
      'associationName': instance.associationName,
      'associationId': instance.associationId,
      'active': instance.active,
      'countryName': instance.countryName,
      'dateRegistered': instance.dateRegistered,
      'position': instance.position?.toJson(),
      'carUser': instance.carUser?.toJson(),
      'adminUser': instance.adminUser?.toJson(),
    };

RouteUpdateRequest _$RouteUpdateRequestFromJson(Map<String, dynamic> json) =>
    RouteUpdateRequest(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      userId: json['userId'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$RouteUpdateRequestToJson(RouteUpdateRequest instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'userId': instance.userId,
      'created': instance.created,
      'associationId': instance.associationId,
      'userName': instance.userName,
    };

VehicleMediaRequest _$VehicleMediaRequestFromJson(Map<String, dynamic> json) =>
    VehicleMediaRequest(
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      requesterId: json['requesterId'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      requesterName: json['requesterName'] as String?,
      addVideo: json['addVideo'] as bool?,
    );

Map<String, dynamic> _$VehicleMediaRequestToJson(
        VehicleMediaRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'requesterId': instance.requesterId,
      'created': instance.created,
      'associationId': instance.associationId,
      'requesterName': instance.requesterName,
      'addVideo': instance.addVideo,
    };

VehicleArrival _$VehicleArrivalFromJson(Map<String, dynamic> json) =>
    VehicleArrival(
      vehicleArrivalId: json['vehicleArrivalId'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      dispatched: json['dispatched'] as bool?,
    );

Map<String, dynamic> _$VehicleArrivalToJson(VehicleArrival instance) =>
    <String, dynamic>{
      'vehicleArrivalId': instance.vehicleArrivalId,
      'landmarkId': instance.landmarkId,
      'routeId': instance.routeId,
      'landmarkName': instance.landmarkName,
      'routeName': instance.routeName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'dispatched': instance.dispatched,
    };

VehiclePhoto _$VehiclePhotoFromJson(Map<String, dynamic> json) => VehiclePhoto(
      vehiclePhotoId: json['vehiclePhotoId'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      thumbNailUrl: json['thumbNailUrl'] as String?,
      url: json['url'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$VehiclePhotoToJson(VehiclePhoto instance) =>
    <String, dynamic>{
      'vehiclePhotoId': instance.vehiclePhotoId,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'vehicleReg': instance.vehicleReg,
      'thumbNailUrl': instance.thumbNailUrl,
      'url': instance.url,
      'userId': instance.userId,
      'userName': instance.userName,
    };

UserPhoto _$UserPhotoFromJson(Map<String, dynamic> json) => UserPhoto(
      userPhotoId: json['userPhotoId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      userName: json['userName'] as String?,
      userId: json['userId'] as String?,
      created: json['created'] as String?,
      thumbNailUrl: json['thumbNailUrl'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$UserPhotoToJson(UserPhoto instance) => <String, dynamic>{
      'userPhotoId': instance.userPhotoId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'userName': instance.userName,
      'userId': instance.userId,
      'created': instance.created,
      'thumbNailUrl': instance.thumbNailUrl,
      'url': instance.url,
    };

VehicleVideo _$VehicleVideoFromJson(Map<String, dynamic> json) => VehicleVideo(
      vehicleVideoId: json['vehicleVideoId'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      thumbNailUrl: json['thumbNailUrl'] as String?,
      url: json['url'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$VehicleVideoToJson(VehicleVideo instance) =>
    <String, dynamic>{
      'vehicleVideoId': instance.vehicleVideoId,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'vehicleReg': instance.vehicleReg,
      'thumbNailUrl': instance.thumbNailUrl,
      'url': instance.url,
      'userId': instance.userId,
      'userName': instance.userName,
    };

VehicleDeparture _$VehicleDepartureFromJson(Map<String, dynamic> json) =>
    VehicleDeparture(
      vehicleDepartureId: json['vehicleDepartureId'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      dispatched: json['dispatched'] as bool?,
    );

Map<String, dynamic> _$VehicleDepartureToJson(VehicleDeparture instance) =>
    <String, dynamic>{
      'vehicleDepartureId': instance.vehicleDepartureId,
      'landmarkId': instance.landmarkId,
      'routeId': instance.routeId,
      'landmarkName': instance.landmarkName,
      'routeName': instance.routeName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'dispatched': instance.dispatched,
    };

UserGeofenceEvent _$UserGeofenceEventFromJson(Map<String, dynamic> json) =>
    UserGeofenceEvent(
      userGeofenceId: json['userGeofenceId'] as String?,
      activityType: json['activityType'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      action: json['action'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      userId: json['userId'] as String?,
      confidence: (json['confidence'] as num?)?.toInt(),
      odometer: (json['odometer'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserGeofenceEventToJson(UserGeofenceEvent instance) =>
    <String, dynamic>{
      'userGeofenceId': instance.userGeofenceId,
      'activityType': instance.activityType,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'action': instance.action,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'userId': instance.userId,
      'confidence': instance.confidence,
      'odometer': instance.odometer,
    };

VehicleHeartbeat _$VehicleHeartbeatFromJson(Map<String, dynamic> json) =>
    VehicleHeartbeat(
      vehicleHeartbeatId: json['vehicleHeartbeatId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      longDate: (json['longDate'] as num?)?.toInt(),
      appToBackground: json['appToBackground'] as bool?,
    );

Map<String, dynamic> _$VehicleHeartbeatToJson(VehicleHeartbeat instance) =>
    <String, dynamic>{
      'vehicleHeartbeatId': instance.vehicleHeartbeatId,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'longDate': instance.longDate,
      'appToBackground': instance.appToBackground,
    };

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) => RoutePoint(
      routePointId: json['routePointId'] as String?,
      associationId: json['associationId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      index: (json['index'] as num?)?.toInt(),
      created: json['created'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
    );

Map<String, dynamic> _$RoutePointToJson(RoutePoint instance) =>
    <String, dynamic>{
      'routePointId': instance.routePointId,
      'associationId': instance.associationId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heading': instance.heading,
      'index': instance.index,
      'created': instance.created,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
    };

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      routeId: json['routeId'] as String?,
      countryId: json['countryId'] as String?,
      countryName: json['countryName'] as String?,
      name: json['name'] as String?,
      routeNumber: json['routeNumber'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      color: json['color'] as String?,
      isActive: json['isActive'] as bool?,
      activationDate: json['activationDate'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      heading: (json['heading'] as num?)?.toDouble(),
      lengthInMetres: (json['lengthInMetres'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userUrl: json['userUrl'] as String?,
      routeStartEnd: json['routeStartEnd'] == null
          ? null
          : RouteStartEnd.fromJson(
              json['routeStartEnd'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'routeId': instance.routeId,
      'countryId': instance.countryId,
      'countryName': instance.countryName,
      'name': instance.name,
      'routeNumber': instance.routeNumber,
      'created': instance.created,
      'updated': instance.updated,
      'color': instance.color,
      'isActive': instance.isActive,
      'activationDate': instance.activationDate,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'heading': instance.heading,
      'lengthInMetres': instance.lengthInMetres,
      'userId': instance.userId,
      'userName': instance.userName,
      'userUrl': instance.userUrl,
      'routeStartEnd': instance.routeStartEnd?.toJson(),
    };

RouteAssignment _$RouteAssignmentFromJson(Map<String, dynamic> json) =>
    RouteAssignment(
      vehicleId: json['vehicleId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      created: json['created'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      active: (json['active'] as num?)?.toInt(),
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
    );

Map<String, dynamic> _$RouteAssignmentToJson(RouteAssignment instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'created': instance.created,
      'vehicleReg': instance.vehicleReg,
      'active': instance.active,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
    };

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      vehicleId: json['vehicleId'] as String?,
      countryId: json['countryId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerId: json['ownerId'] as String?,
      created: json['created'] as String?,
      dateInstalled: json['dateInstalled'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      cellphone: json['cellphone'] as String?,
      active: (json['active'] as num?)?.toInt(),
      passengerCapacity: (json['passengerCapacity'] as num?)?.toInt(),
      associationId: json['associationId'] as String?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => VehiclePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => VehicleVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      associationName: json['associationName'] as String?,
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'countryId': instance.countryId,
      'ownerName': instance.ownerName,
      'ownerId': instance.ownerId,
      'cellphone': instance.cellphone,
      'created': instance.created,
      'dateInstalled': instance.dateInstalled,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'qrCodeUrl': instance.qrCodeUrl,
      'passengerCapacity': instance.passengerCapacity,
      'active': instance.active,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'photos': instance.photos?.map((e) => e.toJson()).toList(),
      'videos': instance.videos?.map((e) => e.toJson()).toList(),
    };

CalculatedDistance _$CalculatedDistanceFromJson(Map<String, dynamic> json) =>
    CalculatedDistance(
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      fromLandmark: json['fromLandmark'] as String?,
      toLandmark: json['toLandmark'] as String?,
      fromLandmarkId: json['fromLandmarkId'] as String?,
      toLandmarkId: json['toLandmarkId'] as String?,
      associationId: json['associationId'] as String?,
      distanceInMetres: (json['distanceInMetres'] as num?)?.toInt(),
      distanceFromStart: (json['distanceFromStart'] as num?)?.toInt(),
      fromRoutePointIndex: (json['fromRoutePointIndex'] as num?)?.toInt(),
      toRoutePointIndex: (json['toRoutePointIndex'] as num?)?.toInt(),
      index: (json['index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CalculatedDistanceToJson(CalculatedDistance instance) =>
    <String, dynamic>{
      'routeName': instance.routeName,
      'routeId': instance.routeId,
      'fromLandmark': instance.fromLandmark,
      'toLandmark': instance.toLandmark,
      'fromLandmarkId': instance.fromLandmarkId,
      'toLandmarkId': instance.toLandmarkId,
      'associationId': instance.associationId,
      'distanceInMetres': instance.distanceInMetres,
      'distanceFromStart': instance.distanceFromStart,
      'fromRoutePointIndex': instance.fromRoutePointIndex,
      'toRoutePointIndex': instance.toRoutePointIndex,
      'index': instance.index,
    };

AppError _$AppErrorFromJson(Map<String, dynamic> json) => AppError(
      appErrorId: json['appErrorId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      created: json['created'] as String?,
      brand: json['brand'] as String?,
      userId: json['userId'] as String?,
      associationId: json['associationId'] as String?,
      userName: json['userName'] as String?,
      errorPosition: json['errorPosition'] == null
          ? null
          : Position.fromJson(json['errorPosition'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      iosName: json['iosName'] as String?,
      versionCodeName: json['versionCodeName'] as String?,
      baseOS: json['baseOS'] as String?,
      deviceType: json['deviceType'] as String?,
      iosSystemName: json['iosSystemName'] as String?,
      userUrl: json['userUrl'] as String?,
      uploadedDate: json['uploadedDate'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
    );

Map<String, dynamic> _$AppErrorToJson(AppError instance) => <String, dynamic>{
      'appErrorId': instance.appErrorId,
      'errorMessage': instance.errorMessage,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'created': instance.created,
      'brand': instance.brand,
      'userId': instance.userId,
      'associationId': instance.associationId,
      'userName': instance.userName,
      'errorPosition': instance.errorPosition?.toJson(),
      'geoHash': instance.geoHash,
      'iosName': instance.iosName,
      'versionCodeName': instance.versionCodeName,
      'baseOS': instance.baseOS,
      'deviceType': instance.deviceType,
      'iosSystemName': instance.iosSystemName,
      'userUrl': instance.userUrl,
      'uploadedDate': instance.uploadedDate,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
    };

CommuterRequest _$CommuterRequestFromJson(Map<String, dynamic> json) =>
    CommuterRequest(
      commuterId: json['commuterId'] as String?,
      commuterRequestId: json['commuterRequestId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      dateRequested: json['dateRequested'] as String?,
      associationId: json['associationId'] as String?,
      dateNeeded: json['dateNeeded'] as String?,
      scanned: json['scanned'] as bool?,
      fcmToken: json['fcmToken'] as String?,
      currentPosition: json['currentPosition'] == null
          ? null
          : Position.fromJson(json['currentPosition'] as Map<String, dynamic>),
      numberOfPassengers: (json['numberOfPassengers'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CommuterRequestToJson(CommuterRequest instance) =>
    <String, dynamic>{
      'commuterId': instance.commuterId,
      'commuterRequestId': instance.commuterRequestId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'dateRequested': instance.dateRequested,
      'associationId': instance.associationId,
      'dateNeeded': instance.dateNeeded,
      'fcmToken': instance.fcmToken,
      'scanned': instance.scanned,
      'currentPosition': instance.currentPosition?.toJson(),
      'numberOfPassengers': instance.numberOfPassengers,
    };

CommuterResponse _$CommuterResponseFromJson(Map<String, dynamic> json) =>
    CommuterResponse(
      json['commuterId'] as String?,
      json['commuterResponseId'] as String?,
      json['commuterRequestId'] as String?,
      json['routeId'] as String?,
      json['routeName'] as String?,
      json['message'] as String?,
      json['associationId'] as String?,
      json['fcmToken'] as String?,
    );

Map<String, dynamic> _$CommuterResponseToJson(CommuterResponse instance) =>
    <String, dynamic>{
      'commuterId': instance.commuterId,
      'commuterResponseId': instance.commuterResponseId,
      'commuterRequestId': instance.commuterRequestId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'message': instance.message,
      'associationId': instance.associationId,
      'fcmToken': instance.fcmToken,
    };

Commuter _$CommuterFromJson(Map<String, dynamic> json) => Commuter(
      commuterId: json['commuterId'] as String?,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      countryId: json['countryId'] as String?,
      dateRegistered: json['dateRegistered'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      profileUrl: json['profileUrl'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      fcmToken: json['fcmToken'] as String?,
      cellphone: json['cellphone'] as String?,
      profileThumbnailUrl: json['profileThumbnailUrl'] as String?,
    );

Map<String, dynamic> _$CommuterToJson(Commuter instance) => <String, dynamic>{
      'commuterId': instance.commuterId,
      'name': instance.name,
      'gender': instance.gender,
      'countryId': instance.countryId,
      'dateRegistered': instance.dateRegistered,
      'qrCodeUrl': instance.qrCodeUrl,
      'profileUrl': instance.profileUrl,
      'password': instance.password,
      'email': instance.email,
      'fcmToken': instance.fcmToken,
      'cellphone': instance.cellphone,
      'profileThumbnailUrl': instance.profileThumbnailUrl,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userType: json['userType'] as String?,
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      countryId: json['countryId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      fcmToken: json['fcmToken'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      cellphone: json['cellphone'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      profileThumbnail: json['profileThumbnail'] as String?,
      created: json['created'] as String?,
      profileUrl: json['profileUrl'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userType': instance.userType,
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'countryId': instance.countryId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'fcmToken': instance.fcmToken,
      'password': instance.password,
      'email': instance.email,
      'qrCodeUrl': instance.qrCodeUrl,
      'cellphone': instance.cellphone,
      'profileThumbnail': instance.profileThumbnail,
      'profileUrl': instance.profileUrl,
      'created': instance.created,
    };

RegistrationBag _$RegistrationBagFromJson(Map<String, dynamic> json) =>
    RegistrationBag(
      association: json['association'] == null
          ? null
          : Association.fromJson(json['association'] as Map<String, dynamic>),
      adminUser: json['adminUser'] == null
          ? null
          : User.fromJson(json['adminUser'] as Map<String, dynamic>),
    )..carUser = json['carUser'] == null
        ? null
        : User.fromJson(json['carUser'] as Map<String, dynamic>);

Map<String, dynamic> _$RegistrationBagToJson(RegistrationBag instance) =>
    <String, dynamic>{
      'association': instance.association?.toJson(),
      'adminUser': instance.adminUser?.toJson(),
      'carUser': instance.carUser?.toJson(),
    };

RouteInfo _$RouteInfoFromJson(Map<String, dynamic> json) => RouteInfo(
      json['routeName'] as String?,
      json['routeId'] as String?,
    );

Map<String, dynamic> _$RouteInfoToJson(RouteInfo instance) => <String, dynamic>{
      'routeName': instance.routeName,
      'routeId': instance.routeId,
    };

AmbassadorPassengerCount _$AmbassadorPassengerCountFromJson(
        Map<String, dynamic> json) =>
    AmbassadorPassengerCount(
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      ownerId: json['ownerId'] as String?,
      tripId: json['tripId'] as String?,
      ownerName: json['ownerName'] as String?,
      passengersIn: (json['passengersIn'] as num?)?.toInt(),
      passengersOut: (json['passengersOut'] as num?)?.toInt(),
      currentPassengers: (json['currentPassengers'] as num?)?.toInt(),
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    )..passengerCountId = json['passengerCountId'] as String?;

Map<String, dynamic> _$AmbassadorPassengerCountToJson(
        AmbassadorPassengerCount instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'tripId': instance.tripId,
      'passengerCountId': instance.passengerCountId,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'passengersIn': instance.passengersIn,
      'passengersOut': instance.passengersOut,
      'currentPassengers': instance.currentPassengers,
      'position': instance.position?.toJson(),
    };

AmbassadorCheckIn _$AmbassadorCheckInFromJson(Map<String, dynamic> json) =>
    AmbassadorCheckIn(
      json['vehicleId'] as String?,
      json['vehicleReg'] as String?,
      json['userId'] as String?,
      json['userName'] as String?,
      json['created'] as String?,
      json['associationId'] as String?,
      json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AmbassadorCheckInToJson(AmbassadorCheckIn instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
      'position': instance.position?.toJson(),
    };

LocationRequest _$LocationRequestFromJson(Map<String, dynamic> json) =>
    LocationRequest(
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
    );

Map<String, dynamic> _$LocationRequestToJson(LocationRequest instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
    };

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      geoHash: json['geoHash'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationResponseToJson(LocationResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'geoHash': instance.geoHash,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
      'position': instance.position?.toJson(),
    };

RouteLandmark _$RouteLandmarkFromJson(Map<String, dynamic> json) =>
    RouteLandmark(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      routePointId: json['routePointId'] as String?,
      routePointIndex: (json['routePointIndex'] as num?)?.toInt(),
      index: (json['index'] as num?)?.toInt(),
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteLandmarkToJson(RouteLandmark instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'created': instance.created,
      'associationId': instance.associationId,
      'routePointId': instance.routePointId,
      'routePointIndex': instance.routePointIndex,
      'index': instance.index,
      'position': instance.position?.toJson(),
    };

RouteCity _$RouteCityFromJson(Map<String, dynamic> json) => RouteCity(
      json['routeId'] as String?,
      json['routeName'] as String?,
      json['cityId'] as String?,
      json['cityName'] as String?,
      json['created'] as String?,
      json['associationId'] as String?,
      json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteCityToJson(RouteCity instance) => <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'cityId': instance.cityId,
      'cityName': instance.cityName,
      'created': instance.created,
      'associationId': instance.associationId,
      'position': instance.position?.toJson(),
    };

StateProvince _$StateProvinceFromJson(Map<String, dynamic> json) =>
    StateProvince(
      json['stateId'] as String?,
      json['name'] as String?,
      json['countryId'] as String?,
      json['countryName'] as String?,
    );

Map<String, dynamic> _$StateProvinceToJson(StateProvince instance) =>
    <String, dynamic>{
      'stateId': instance.stateId,
      'name': instance.name,
      'countryId': instance.countryId,
      'countryName': instance.countryName,
    };

Landmark _$LandmarkFromJson(Map<String, dynamic> json) => Landmark(
      json['landmarkId'] as String?,
      (json['latitude'] as num?)?.toDouble(),
      (json['longitude'] as num?)?.toDouble(),
      (json['distance'] as num?)?.toDouble(),
      json['landmarkName'] as String?,
      (json['routeDetails'] as List<dynamic>)
          .map((e) => RouteInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      json['geoHash'] as String?,
    );

Map<String, dynamic> _$LandmarkToJson(Landmark instance) => <String, dynamic>{
      'landmarkId': instance.landmarkId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distance': instance.distance,
      'landmarkName': instance.landmarkName,
      'routeDetails': instance.routeDetails.map((e) => e.toJson()).toList(),
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
    };

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      json['associationId'] as String?,
      json['locale'] as String?,
      json['created'] as String?,
      (json['refreshRateInSeconds'] as num?)?.toInt(),
      (json['themeIndex'] as num?)?.toInt(),
      (json['geofenceRadius'] as num?)?.toInt(),
      (json['commuterGeofenceRadius'] as num?)?.toInt(),
      (json['vehicleSearchMinutes'] as num?)?.toInt(),
      (json['heartbeatIntervalSeconds'] as num?)?.toInt(),
      (json['loiteringDelay'] as num?)?.toInt(),
      (json['commuterSearchMinutes'] as num?)?.toInt(),
      (json['commuterGeoQueryRadius'] as num?)?.toInt(),
      (json['vehicleGeoQueryRadius'] as num?)?.toInt(),
      (json['numberOfLandmarksToScan'] as num?)?.toInt(),
      (json['distanceFilter'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'associationId': instance.associationId,
      'locale': instance.locale,
      'created': instance.created,
      'refreshRateInSeconds': instance.refreshRateInSeconds,
      'themeIndex': instance.themeIndex,
      'geofenceRadius': instance.geofenceRadius,
      'commuterGeofenceRadius': instance.commuterGeofenceRadius,
      'vehicleSearchMinutes': instance.vehicleSearchMinutes,
      'heartbeatIntervalSeconds': instance.heartbeatIntervalSeconds,
      'loiteringDelay': instance.loiteringDelay,
      'commuterSearchMinutes': instance.commuterSearchMinutes,
      'commuterGeoQueryRadius': instance.commuterGeoQueryRadius,
      'vehicleGeoQueryRadius': instance.vehicleGeoQueryRadius,
      'numberOfLandmarksToScan': instance.numberOfLandmarksToScan,
      'distanceFilter': instance.distanceFilter,
    };

RouteStartEnd _$RouteStartEndFromJson(Map<String, dynamic> json) =>
    RouteStartEnd(
      startCityId: json['startCityId'] as String?,
      startCityName: json['startCityName'] as String?,
      endCityId: json['endCityId'] as String?,
      endCityName: json['endCityName'] as String?,
      startCityPosition: json['startCityPosition'] == null
          ? null
          : Position.fromJson(
              json['startCityPosition'] as Map<String, dynamic>),
      endCityPosition: json['endCityPosition'] == null
          ? null
          : Position.fromJson(json['endCityPosition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteStartEndToJson(RouteStartEnd instance) =>
    <String, dynamic>{
      'startCityId': instance.startCityId,
      'startCityName': instance.startCityName,
      'endCityId': instance.endCityId,
      'endCityName': instance.endCityName,
      'startCityPosition': instance.startCityPosition?.toJson(),
      'endCityPosition': instance.endCityPosition?.toJson(),
    };

AddCarsResponse _$AddCarsResponseFromJson(Map<String, dynamic> json) =>
    AddCarsResponse(
      (json['cars'] as List<dynamic>)
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['errors'] as List<dynamic>)
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddCarsResponseToJson(AddCarsResponse instance) =>
    <String, dynamic>{
      'cars': instance.cars.map((e) => e.toJson()).toList(),
      'errors': instance.errors.map((e) => e.toJson()).toList(),
    };

AddUsersResponse _$AddUsersResponseFromJson(Map<String, dynamic> json) =>
    AddUsersResponse(
      (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['errors'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddUsersResponseToJson(AddUsersResponse instance) =>
    <String, dynamic>{
      'users': instance.users.map((e) => e.toJson()).toList(),
      'errors': instance.errors.map((e) => e.toJson()).toList(),
    };
