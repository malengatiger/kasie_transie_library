import 'package:json_annotation/json_annotation.dart';
part 'data_schemas.g.dart';

@JsonSerializable(explicitToJson: true)
class Country {
  String? countryId;
  String? name;
  String? iso2;
  String? iso3;
  String? capital;
  String? currency;
  String? region;
  String? subregion;
  String? emoji;
  String? phoneCode;
  String? currencyName;
  String? currencySymbol;
  double? latitude, longitude;
  Position? position;
  String? geoHash;

  Country(
      this.countryId,
      this.name,
      this.iso2,
      this.iso3,
      this.capital,
      this.currency,
      this.region,
      this.subregion,
      this.emoji,
      this.phoneCode,
      this.currencyName,
      this.currencySymbol,
      this.latitude,
      this.longitude,
      this.position,
      this.geoHash);
  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Position {
  String? type = 'Point';
  List<double> coordinates = [];
  double? latitude, longitude;
  String? geoHash;

  Position(
      {this.type,
      required this.coordinates,
      this.latitude,
      this.longitude,
      this.geoHash});
  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  Map<String, dynamic> toJson() => _$PositionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class City {
  String? cityId;
  String? countryId;
  String? name, distance;
  String? stateName;
  double? latitude;
  double? longitude;
  String? countryName;
  String? stateId;
  Position? position;
  String? geoHash, created;

  City(
      {this.cityId,
      this.countryId,
      this.name,
      this.distance,
      this.stateName,
      this.latitude,
      this.longitude,
      this.countryName,
      this.stateId,
      this.position,
      this.created,
      this.geoHash});
  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DispatchRecord {
  String? dispatchRecordId;
  String? marshalId;
  int? passengers;
  String? ownerId;
  String? created;
  Position? position;
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
  String? routeLandmarkId;
  bool? dispatched;

  DispatchRecord(
      {this.dispatchRecordId,
      this.marshalId,
      this.passengers,
      this.ownerId,
      this.created,
      this.position,
      this.geoHash,
      this.landmarkName,
      this.marshalName,
      this.routeName,
      this.routeId,
      this.vehicleId,
      this.vehicleArrivalId,
      this.vehicleReg,
      this.associationId,
      this.associationName,
      this.routeLandmarkId,
      this.dispatched});

  factory DispatchRecord.fromJson(Map<String, dynamic> json) =>
      _$DispatchRecordFromJson(json);

  Map<String, dynamic> toJson() => _$DispatchRecordToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Association {
  String? cityId;
  String? countryId;
  String? cityName, associationName, associationId;
  int? active;
  String? countryName;
  String? dateRegistered;
  Position? position;
  String? geoHash;
  String? adminUserFirstName, adminUserLastName;
  String? userId;
  String? adminCellphone;
  String? adminEmail;
  String? password;

  Association(
      {this.cityId,
      this.countryId,
      this.cityName,
      this.associationName,
      this.associationId,
      this.active,
      this.countryName,
      this.dateRegistered,
      this.position,
      this.geoHash,
      this.adminUserFirstName,
      this.adminUserLastName,
      this.userId,
      this.password,
      this.adminCellphone,
      this.adminEmail});

  factory Association.fromJson(Map<String, dynamic> json) =>
      _$AssociationFromJson(json);

  Map<String, dynamic> toJson() => _$AssociationToJson(this);
}
//

@JsonSerializable(explicitToJson: true)
class RouteUpdateRequest {
  String? routeId;
  String? routeName;
  String? userId;
  String? created;
  String? associationId;
  String? userName;

  RouteUpdateRequest(
      {this.routeId,
      this.routeName,
      this.userId,
      this.created,
      this.associationId,
      this.userName});
  factory RouteUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$RouteUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RouteUpdateRequestToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class VehicleMediaRequest {
  String? userId;
  String? vehicleId;
  String? vehicleReg;
  String? requesterId;
  String? created;
  String? associationId;
  String? requesterName;

  bool? addVideo;

  VehicleMediaRequest(
      {this.userId,
      this.vehicleId,
      this.vehicleReg,
      this.requesterId,
      this.created,
      this.associationId,
      this.requesterName,
      this.addVideo});
  factory VehicleMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$VehicleMediaRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleMediaRequestToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class VehicleArrival {
  String? vehicleArrivalId;
  String? landmarkId;
  String? landmarkName;
  Position? position;
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

  VehicleArrival(
      {this.vehicleArrivalId,
      this.landmarkId,
      this.landmarkName,
      this.position,
      this.geoHash,
      this.created,
      this.vehicleId,
      this.associationId,
      this.associationName,
      this.vehicleReg,
      this.make,
      this.model,
      this.ownerId,
      this.ownerName,
      this.dispatched});
  factory VehicleArrival.fromJson(Map<String, dynamic> json) =>
      _$VehicleArrivalFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleArrivalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VehiclePhoto {
  String? vehiclePhotoId;
  String? landmarkId;
  String? landmarkName;
  Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? thumbNailUrl;
  String? url;
  String? userId, userName;

  VehiclePhoto(
      {this.vehiclePhotoId,
      this.landmarkId,
      this.landmarkName,
      this.position,
      this.geoHash,
      this.created,
      this.vehicleId,
      this.associationId,
      this.vehicleReg,
      this.thumbNailUrl,
      this.url,
      this.userId,
      this.userName});
  factory VehiclePhoto.fromJson(Map<String, dynamic> json) =>
      _$VehiclePhotoFromJson(json);

  Map<String, dynamic> toJson() => _$VehiclePhotoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VehicleVideo {
  String? vehicleVideoId;
  String? landmarkId;
  String? landmarkName;
  Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? thumbNailUrl;
  String? url;
  String? userId, userName;

  VehicleVideo(
      {this.vehicleVideoId,
      this.landmarkId,
      this.landmarkName,
      this.position,
      this.geoHash,
      this.created,
      this.vehicleId,
      this.associationId,
      this.vehicleReg,
      this.thumbNailUrl,
      this.url,
      this.userId,
      this.userName});
  factory VehicleVideo.fromJson(Map<String, dynamic> json) =>
      _$VehicleVideoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleVideoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VehicleDeparture {
  String? vehicleDepartureId;
  String? landmarkId;
  String? landmarkName;
  Position? position;
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

  VehicleDeparture(
      {this.vehicleDepartureId,
      this.landmarkId,
      this.landmarkName,
      this.position,
      this.geoHash,
      this.created,
      this.vehicleId,
      this.associationId,
      this.associationName,
      this.vehicleReg,
      this.make,
      this.model,
      this.ownerId,
      this.ownerName,
      this.dispatched});
  factory VehicleDeparture.fromJson(Map<String, dynamic> json) =>
      _$VehicleDepartureFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleDepartureToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserGeofenceEvent {
  String? userGeofenceId;
  String? activityType;
  String? landmarkId;
  String? landmarkName;
  Position? position;
  String? geoHash;
  String? created;
  String? action;
  String? associationId;
  String? associationName;
  String? userId;
  int? confidence;
  double? odometer;

  UserGeofenceEvent(
      {this.userGeofenceId,
      this.activityType,
      this.landmarkId,
      this.landmarkName,
      this.position,
      this.geoHash,
      this.created,
      this.action,
      this.associationId,
      this.associationName,
      this.userId,
      this.confidence,
      this.odometer});
  factory UserGeofenceEvent.fromJson(Map<String, dynamic> json) =>
      _$UserGeofenceEventFromJson(json);

  Map<String, dynamic> toJson() => _$UserGeofenceEventToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VehicleHeartbeat {
  String? vehicleHeartbeatId;

  Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  int? longDate;
  bool? appToBackground = false;

  VehicleHeartbeat(
      {this.vehicleHeartbeatId,
      this.position,
      this.geoHash,
      this.created,
      this.vehicleId,
      this.associationId,
      this.vehicleReg,
      this.make,
      this.model,
      this.ownerId,
      this.ownerName,
      this.longDate,
      this.appToBackground});
  factory VehicleHeartbeat.fromJson(Map<String, dynamic> json) =>
      _$VehicleHeartbeatFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleHeartbeatToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RoutePoint {
  String? routePointId;
  String? associationId;
  double? latitude;
  double? longitude;
  double? heading;
  int? index;
  String? created;
  String? routeId;
  String? routeName;
  Position? position;
  String? geoHash;

  RoutePoint(
      {this.routePointId,
      this.associationId,
      this.latitude,
      this.longitude,
      this.heading,
      this.index,
      this.created,
      this.routeId,
      this.routeName,
      this.position,
      this.geoHash});
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Route {
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
  RouteStartEnd? routeStartEnd;

  Route(
      {this.routeId,
      this.countryId,
      this.countryName,
      this.name,
      this.routeNumber,
      this.created,
      this.updated,
      this.color,
      this.isActive,
      this.activationDate,
      this.associationId,
      this.associationName,
      this.heading,
      this.lengthInMetres,
      this.userId,
      this.userName,
      this.userUrl,
      this.routeStartEnd});
  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);

  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class RouteAssignment {
  String? vehicleId;
  String? routeId, routeName;
  String? created;
  String? vehicleReg;
  int? active;
  String? associationId, associationName;

  RouteAssignment(
      {this.vehicleId,
      this.routeId,
      this.routeName,
      this.created,
      this.vehicleReg,
      this.active,
      this.associationId,
      this.associationName});
  factory RouteAssignment.fromJson(Map<String, dynamic> json) =>
      _$RouteAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$RouteAssignmentToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class Vehicle {
  String? vehicleId;
  String? countryId, ownerName, ownerId, ownerCellphone;
  String? created, dateInstalled;
  String? vehicleReg;
  String? make;
  String? model;
  String? year;
  String? qrCodeUrl;
  int? passengerCapacity;
  String? associationId, associationName;

  Vehicle(
      {this.vehicleId,
      this.countryId,
      this.ownerName,
      this.ownerId,
      this.created,
      this.dateInstalled,
      this.vehicleReg,
      this.make,
      this.model,
      this.year,
      this.qrCodeUrl, this.ownerCellphone,
      this.passengerCapacity,
      this.associationId,
      this.associationName});
  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CalculatedDistance {
  String? routeName, routeId;
  String? fromLandmark, toLandmark, fromLandmarkId, toLandmarkId, associationId;
  int? distanceInMetres, distanceFromStart;
  int? fromRoutePointIndex, toRoutePointIndex, index;

  CalculatedDistance(
      {this.routeName,
      this.routeId,
      this.fromLandmark,
      this.toLandmark,
      this.fromLandmarkId,
      this.toLandmarkId,
      this.associationId,
      this.distanceInMetres,
      this.distanceFromStart,
      this.fromRoutePointIndex,
      this.toRoutePointIndex,
      this.index});
  factory CalculatedDistance.fromJson(Map<String, dynamic> json) =>
      _$CalculatedDistanceFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatedDistanceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AppError {
  String? appErrorId;
  String? errorMessage;
  String? manufacturer;
  String? model;
  String? created;
  String? brand;
  String? userId;
  String? associationId;
  String? userName;
  Position? errorPosition;
  String? geoHash;
  String? iosName;
  String? versionCodeName;
  String? baseOS;
  String? deviceType;
  String? iosSystemName;
  String? userUrl;
  String? uploadedDate;
  String? vehicleId;
  String? vehicleReg;

  AppError(
      {this.appErrorId,
      this.errorMessage,
      this.manufacturer,
      this.model,
      this.created,
      this.brand,
      this.userId,
      this.associationId,
      this.userName,
      this.errorPosition,
      this.geoHash,
      this.iosName,
      this.versionCodeName,
      this.baseOS,
      this.deviceType,
      this.iosSystemName,
      this.userUrl,
      this.uploadedDate,
      this.vehicleId,
      this.vehicleReg});
  factory AppError.fromJson(Map<String, dynamic> json) =>
      _$AppErrorFromJson(json);

  Map<String, dynamic> toJson() => _$AppErrorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CommuterRequest {
  String? commuterId;
  String? commuterRequestId, routeId;
  String? routeName;
  String? dateRequested;
  String? routeLandmarkId;
  String? routeLandmarkName;
  String? associationId;
  String? dateNeeded;
  bool? scanned;

  Position? currentPosition;
  int? routePointIndex, numberOfPassengers;
  double? distanceToRouteLandmarkInMetres, distanceToRoutePointInMetres;

  CommuterRequest(
      this.commuterId,
      this.commuterRequestId,
      this.routeId,
      this.routeName,
      this.dateRequested,
      this.routeLandmarkId,
      this.routeLandmarkName,
      this.associationId,
      this.dateNeeded,
      this.scanned,
      this.currentPosition,
      this.routePointIndex,
      this.numberOfPassengers,
      this.distanceToRouteLandmarkInMetres,
      this.distanceToRoutePointInMetres);
  factory CommuterRequest.fromJson(Map<String, dynamic> json) =>
      _$CommuterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterRequestToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class Commuter {
  String? commuterId;
  String? name, gender;
  String? countryId;
  String? dateRegistered;
  String? qrCodeUrl;
  String? profileUrl;
  String? password;
  String? email;
  String? cellphone, profileThumbnailUrl;

  Commuter(
      this.commuterId,
      this.name,
      this.gender,
      this.countryId,
      this.dateRegistered,
      this.qrCodeUrl,
      this.profileUrl,
      this.password,
      this.email,
      this.cellphone,
      this.profileThumbnailUrl);
  factory Commuter.fromJson(Map<String, dynamic> json) =>
      _$CommuterFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class User {
  String? userType;

  String? userId;
  String? firstName, lastName, gender;
  String? countryId;
  String? associationId;
  String? associationName;
  String? fcmToken;
  String? password;
  String? email;
  String? cellphone, thumbnailUrl, imageUrl, created;

  User(
      {this.userType,
      this.userId,
      this.firstName,
      this.lastName,
      this.gender,
      this.countryId,
      this.associationId,
      this.associationName,
      this.fcmToken,
      this.password,
      this.email,
      this.cellphone,
      this.thumbnailUrl,
      this.created,
      this.imageUrl});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get name => '$firstName $lastName';
}

@JsonSerializable(explicitToJson: true)
class RegistrationBag {
  Association? association;
  User? user;

  RegistrationBag({this.association, this.user});

  factory RegistrationBag.fromJson(Map<String, dynamic> json) =>
      _$RegistrationBagFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationBagToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteInfo {
  String? routeName, routeId;

  RouteInfo(this.routeName, this.routeId);
  factory RouteInfo.fromJson(Map<String, dynamic> json) =>
      _$RouteInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AmbassadorPassengerCount {
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;
  String? routeId;
  String? routeName;
  String? ownerId;
  String? ownerName;
  int? passengersIn;
  int? passengersOut;
  int? currentPassengers;
  Position? position;

  AmbassadorPassengerCount(
      {this.vehicleId,
      this.vehicleReg,
      this.userId,
      this.userName,
      this.created,
      this.associationId,
      this.routeId,
      this.routeName,
      this.ownerId,
      this.ownerName,
      this.passengersIn,
      this.passengersOut,
      this.currentPassengers,
      this.position});
  factory AmbassadorPassengerCount.fromJson(Map<String, dynamic> json) =>
      _$AmbassadorPassengerCountFromJson(json);

  Map<String, dynamic> toJson() => _$AmbassadorPassengerCountToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AmbassadorCheckIn {
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;
  Position? position;

  AmbassadorCheckIn(this.vehicleId, this.vehicleReg, this.userId, this.userName,
      this.created, this.associationId, this.position);
  factory AmbassadorCheckIn.fromJson(Map<String, dynamic> json) =>
      _$AmbassadorCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$AmbassadorCheckInToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LocationRequest {
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;

  LocationRequest(
      {this.vehicleId,
      this.vehicleReg,
      this.userId,
      this.userName,
      this.created,
      this.associationId});
  factory LocationRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LocationResponse {
  String? userId;
  String? vehicleId, vehicleReg;
  String? geoHash;
  String? userName;
  String? created;
  String? associationId;
  Position? position;

  LocationResponse(
      {this.userId,
      this.vehicleId,
      this.vehicleReg,
      this.geoHash,
      this.userName,
      this.created,
      this.associationId,
      this.position});
  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LocationResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteLandmark {
  String? routeId, routeLandmarkId;
  String? routeName;
  String? landmarkId;
  String? landmarkName;
  String? created;
  String? associationId;
  String? routePointId;
  int? routePointIndex;
  int? index;
  Position? position;

  RouteLandmark(
      {this.routeId,
      this.routeName,
      this.landmarkId,
      this.landmarkName,
      this.created,
      this.associationId,
      this.routePointId,
      this.routePointIndex,
      this.index,
      this.routeLandmarkId,
      this.position});
  factory RouteLandmark.fromJson(Map<String, dynamic> json) =>
      _$RouteLandmarkFromJson(json);

  Map<String, dynamic> toJson() => _$RouteLandmarkToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteCity {
  String? routeId;
  String? routeName;
  String? cityId;
  String? cityName;
  String? created;
  String? associationId;
  Position? position;

  RouteCity(this.routeId, this.routeName, this.cityId, this.cityName,
      this.created, this.associationId, this.position);
  factory RouteCity.fromJson(Map<String, dynamic> json) =>
      _$RouteCityFromJson(json);

  Map<String, dynamic> toJson() => _$RouteCityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StateProvince {
  String? stateId;
  String? name;
  String? countryId;
  String? countryName;

  StateProvince(this.stateId, this.name, this.countryId, this.countryName);
  factory StateProvince.fromJson(Map<String, dynamic> json) =>
      _$StateProvinceFromJson(json);

  Map<String, dynamic> toJson() => _$StateProvinceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Landmark {
  String? landmarkId;
  double? latitude;
  double? longitude;
  double? distance;
  String? landmarkName;
  List<RouteInfo> routeDetails = [];
  Position? position;
  String? geoHash;

  Landmark(this.landmarkId, this.latitude, this.longitude, this.distance,
      this.landmarkName, this.routeDetails, this.position, this.geoHash);
  factory Landmark.fromJson(Map<String, dynamic> json) =>
      _$LandmarkFromJson(json);

  Map<String, dynamic> toJson() => _$LandmarkToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SettingsModel {
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

  SettingsModel(
      this.associationId,
      this.locale,
      this.created,
      this.refreshRateInSeconds,
      this.themeIndex,
      this.geofenceRadius,
      this.commuterGeofenceRadius,
      this.vehicleSearchMinutes,
      this.heartbeatIntervalSeconds,
      this.loiteringDelay,
      this.commuterSearchMinutes,
      this.commuterGeoQueryRadius,
      this.vehicleGeoQueryRadius,
      this.numberOfLandmarksToScan,
      this.distanceFilter);

  SettingsModel.name();

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteStartEnd {
  String? startCityId, startCityName;
  String? endCityId, endCityName;

  Position? startCityPosition;
  Position? endCityPosition;

  RouteStartEnd(
      {this.startCityId,
      this.startCityName,
      this.endCityId,
      this.endCityName,
      this.startCityPosition,
      this.endCityPosition});

  factory RouteStartEnd.fromJson(Map<String, dynamic> json) =>
      _$RouteStartEndFromJson(json);

  Map<String, dynamic> toJson() => _$RouteStartEndToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AddCarsResponse {
  List<Vehicle> cars = [];
  List<Vehicle> errors = [];

  AddCarsResponse(this.cars, this.errors);
  factory AddCarsResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCarsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddCarsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AddUsersResponse {
  List<User> users = [];
  List<User> errors = [];

  AddUsersResponse(this.users, this.errors);

  factory AddUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$AddUsersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddUsersResponseToJson(this);
}
