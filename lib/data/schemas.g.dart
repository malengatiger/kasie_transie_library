// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Country extends _Country with RealmEntity, RealmObjectBase, RealmObject {
  Country({
    String? countryId,
    String? name,
    String? iso2,
  }) {
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'iso2', iso2);
  }

  Country._();

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get iso2 => RealmObjectBase.get<String>(this, 'iso2') as String?;
  @override
  set iso2(String? value) => RealmObjectBase.set(this, 'iso2', value);

  @override
  Stream<RealmObjectChanges<Country>> get changes =>
      RealmObjectBase.getChanges<Country>(this);

  @override
  Country freeze() => RealmObjectBase.freezeObject<Country>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Country._);
    return const SchemaObject(ObjectType.realmObject, Country, 'Country', [
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('iso2', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Position extends _Position
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  Position({
    String? type = 'Point',
    double? latitude,
    double? longitude,
    Iterable<double> coordinates = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Position>({
        'type': 'Point',
      });
    }
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set<RealmList<double>>(
        this, 'coordinates', RealmList<double>(coordinates));
  }

  Position._();

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  RealmList<double> get coordinates =>
      RealmObjectBase.get<double>(this, 'coordinates') as RealmList<double>;
  @override
  set coordinates(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  Stream<RealmObjectChanges<Position>> get changes =>
      RealmObjectBase.getChanges<Position>(this);

  @override
  Position freeze() => RealmObjectBase.freezeObject<Position>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Position._);
    return const SchemaObject(ObjectType.embeddedObject, Position, 'Position', [
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('coordinates', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
    ]);
  }
}

class City extends _City with RealmEntity, RealmObjectBase, RealmObject {
  City({
    String? cityId,
    String? countryId,
    String? name,
    String? distance,
    String? stateName,
    double? latitude,
    double? longitude,
    String? countryName,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'cityId', cityId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'distance', distance);
    RealmObjectBase.set(this, 'stateName', stateName);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'countryName', countryName);
    RealmObjectBase.set(this, 'position', position);
  }

  City._();

  @override
  String? get cityId => RealmObjectBase.get<String>(this, 'cityId') as String?;
  @override
  set cityId(String? value) => RealmObjectBase.set(this, 'cityId', value);

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get distance =>
      RealmObjectBase.get<String>(this, 'distance') as String?;
  @override
  set distance(String? value) => RealmObjectBase.set(this, 'distance', value);

  @override
  String? get stateName =>
      RealmObjectBase.get<String>(this, 'stateName') as String?;
  @override
  set stateName(String? value) => RealmObjectBase.set(this, 'stateName', value);

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  String? get countryName =>
      RealmObjectBase.get<String>(this, 'countryName') as String?;
  @override
  set countryName(String? value) =>
      RealmObjectBase.set(this, 'countryName', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<City>> get changes =>
      RealmObjectBase.getChanges<City>(this);

  @override
  City freeze() => RealmObjectBase.freezeObject<City>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(City._);
    return const SchemaObject(ObjectType.realmObject, City, 'City', [
      SchemaProperty('cityId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('distance', RealmPropertyType.string, optional: true),
      SchemaProperty('stateName', RealmPropertyType.string, optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class RoutePoint extends _RoutePoint
    with RealmEntity, RealmObjectBase, RealmObject {
  RoutePoint({
    double? latitude,
    double? longitude,
    double? heading,
    int? index,
    String? created,
    String? routeId,
    String? landmarkId,
    String? landmarkName,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'heading', heading);
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
  }

  RoutePoint._();

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  double? get heading =>
      RealmObjectBase.get<double>(this, 'heading') as double?;
  @override
  set heading(double? value) => RealmObjectBase.set(this, 'heading', value);

  @override
  int? get index => RealmObjectBase.get<int>(this, 'index') as int?;
  @override
  set index(int? value) => RealmObjectBase.set(this, 'index', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get landmarkId =>
      RealmObjectBase.get<String>(this, 'landmarkId') as String?;
  @override
  set landmarkId(String? value) =>
      RealmObjectBase.set(this, 'landmarkId', value);

  @override
  String? get landmarkName =>
      RealmObjectBase.get<String>(this, 'landmarkName') as String?;
  @override
  set landmarkName(String? value) =>
      RealmObjectBase.set(this, 'landmarkName', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<RoutePoint>> get changes =>
      RealmObjectBase.getChanges<RoutePoint>(this);

  @override
  RoutePoint freeze() => RealmObjectBase.freezeObject<RoutePoint>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RoutePoint._);
    return const SchemaObject(
        ObjectType.realmObject, RoutePoint, 'RoutePoint', [
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('heading', RealmPropertyType.double, optional: true),
      SchemaProperty('index', RealmPropertyType.int, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class Route extends _Route with RealmEntity, RealmObjectBase, RealmObject {
  Route({
    String? routeId,
    String? countryId,
    String? countryName,
    String? name,
    String? routeNumber,
    String? created,
    String? updated,
    String? color,
    bool? isActive,
    String? activationDate,
    String? associationId,
    String? associationName,
    double? heading,
    int? lengthInMetres,
    String? userId,
    String? userName,
    String? userUrl,
    Iterable<CalculatedDistance> calculatedDistances = const [],
    Iterable<String> landmarkIds = const [],
  }) {
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'countryName', countryName);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'routeNumber', routeNumber);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'updated', updated);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'isActive', isActive);
    RealmObjectBase.set(this, 'activationDate', activationDate);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'heading', heading);
    RealmObjectBase.set(this, 'lengthInMetres', lengthInMetres);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'userUrl', userUrl);
    RealmObjectBase.set<RealmList<CalculatedDistance>>(
        this,
        'calculatedDistances',
        RealmList<CalculatedDistance>(calculatedDistances));
    RealmObjectBase.set<RealmList<String>>(
        this, 'landmarkIds', RealmList<String>(landmarkIds));
  }

  Route._();

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get countryName =>
      RealmObjectBase.get<String>(this, 'countryName') as String?;
  @override
  set countryName(String? value) =>
      RealmObjectBase.set(this, 'countryName', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get routeNumber =>
      RealmObjectBase.get<String>(this, 'routeNumber') as String?;
  @override
  set routeNumber(String? value) =>
      RealmObjectBase.set(this, 'routeNumber', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get updated =>
      RealmObjectBase.get<String>(this, 'updated') as String?;
  @override
  set updated(String? value) => RealmObjectBase.set(this, 'updated', value);

  @override
  String? get color => RealmObjectBase.get<String>(this, 'color') as String?;
  @override
  set color(String? value) => RealmObjectBase.set(this, 'color', value);

  @override
  bool? get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool?;
  @override
  set isActive(bool? value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  String? get activationDate =>
      RealmObjectBase.get<String>(this, 'activationDate') as String?;
  @override
  set activationDate(String? value) =>
      RealmObjectBase.set(this, 'activationDate', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get associationName =>
      RealmObjectBase.get<String>(this, 'associationName') as String?;
  @override
  set associationName(String? value) =>
      RealmObjectBase.set(this, 'associationName', value);

  @override
  RealmList<CalculatedDistance> get calculatedDistances =>
      RealmObjectBase.get<CalculatedDistance>(this, 'calculatedDistances')
          as RealmList<CalculatedDistance>;
  @override
  set calculatedDistances(covariant RealmList<CalculatedDistance> value) =>
      throw RealmUnsupportedSetError();

  @override
  double? get heading =>
      RealmObjectBase.get<double>(this, 'heading') as double?;
  @override
  set heading(double? value) => RealmObjectBase.set(this, 'heading', value);

  @override
  int? get lengthInMetres =>
      RealmObjectBase.get<int>(this, 'lengthInMetres') as int?;
  @override
  set lengthInMetres(int? value) =>
      RealmObjectBase.set(this, 'lengthInMetres', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get userName =>
      RealmObjectBase.get<String>(this, 'userName') as String?;
  @override
  set userName(String? value) => RealmObjectBase.set(this, 'userName', value);

  @override
  String? get userUrl =>
      RealmObjectBase.get<String>(this, 'userUrl') as String?;
  @override
  set userUrl(String? value) => RealmObjectBase.set(this, 'userUrl', value);

  @override
  RealmList<String> get landmarkIds =>
      RealmObjectBase.get<String>(this, 'landmarkIds') as RealmList<String>;
  @override
  set landmarkIds(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Route>> get changes =>
      RealmObjectBase.getChanges<Route>(this);

  @override
  Route freeze() => RealmObjectBase.freezeObject<Route>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Route._);
    return const SchemaObject(ObjectType.realmObject, Route, 'Route', [
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('routeNumber', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('updated', RealmPropertyType.string, optional: true),
      SchemaProperty('color', RealmPropertyType.string, optional: true),
      SchemaProperty('isActive', RealmPropertyType.bool, optional: true),
      SchemaProperty('activationDate', RealmPropertyType.string,
          optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('calculatedDistances', RealmPropertyType.object,
          linkTarget: 'CalculatedDistance',
          collectionType: RealmCollectionType.list),
      SchemaProperty('heading', RealmPropertyType.double, optional: true),
      SchemaProperty('lengthInMetres', RealmPropertyType.int, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('userUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkIds', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class CalculatedDistance extends _CalculatedDistance
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  CalculatedDistance({
    String? routeName,
    String? routeID,
    String? fromLandmark,
    String? toLandmark,
    String? fromLandmarkID,
    String? toLandmarkID,
    double? distanceInMetres,
    double? distanceFromStart,
    int? fromRoutePointIndex,
    int? toRoutePointIndex,
  }) {
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'routeID', routeID);
    RealmObjectBase.set(this, 'fromLandmark', fromLandmark);
    RealmObjectBase.set(this, 'toLandmark', toLandmark);
    RealmObjectBase.set(this, 'fromLandmarkID', fromLandmarkID);
    RealmObjectBase.set(this, 'toLandmarkID', toLandmarkID);
    RealmObjectBase.set(this, 'distanceInMetres', distanceInMetres);
    RealmObjectBase.set(this, 'distanceFromStart', distanceFromStart);
    RealmObjectBase.set(this, 'fromRoutePointIndex', fromRoutePointIndex);
    RealmObjectBase.set(this, 'toRoutePointIndex', toRoutePointIndex);
  }

  CalculatedDistance._();

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get routeID =>
      RealmObjectBase.get<String>(this, 'routeID') as String?;
  @override
  set routeID(String? value) => RealmObjectBase.set(this, 'routeID', value);

  @override
  String? get fromLandmark =>
      RealmObjectBase.get<String>(this, 'fromLandmark') as String?;
  @override
  set fromLandmark(String? value) =>
      RealmObjectBase.set(this, 'fromLandmark', value);

  @override
  String? get toLandmark =>
      RealmObjectBase.get<String>(this, 'toLandmark') as String?;
  @override
  set toLandmark(String? value) =>
      RealmObjectBase.set(this, 'toLandmark', value);

  @override
  String? get fromLandmarkID =>
      RealmObjectBase.get<String>(this, 'fromLandmarkID') as String?;
  @override
  set fromLandmarkID(String? value) =>
      RealmObjectBase.set(this, 'fromLandmarkID', value);

  @override
  String? get toLandmarkID =>
      RealmObjectBase.get<String>(this, 'toLandmarkID') as String?;
  @override
  set toLandmarkID(String? value) =>
      RealmObjectBase.set(this, 'toLandmarkID', value);

  @override
  double? get distanceInMetres =>
      RealmObjectBase.get<double>(this, 'distanceInMetres') as double?;
  @override
  set distanceInMetres(double? value) =>
      RealmObjectBase.set(this, 'distanceInMetres', value);

  @override
  double? get distanceFromStart =>
      RealmObjectBase.get<double>(this, 'distanceFromStart') as double?;
  @override
  set distanceFromStart(double? value) =>
      RealmObjectBase.set(this, 'distanceFromStart', value);

  @override
  int? get fromRoutePointIndex =>
      RealmObjectBase.get<int>(this, 'fromRoutePointIndex') as int?;
  @override
  set fromRoutePointIndex(int? value) =>
      RealmObjectBase.set(this, 'fromRoutePointIndex', value);

  @override
  int? get toRoutePointIndex =>
      RealmObjectBase.get<int>(this, 'toRoutePointIndex') as int?;
  @override
  set toRoutePointIndex(int? value) =>
      RealmObjectBase.set(this, 'toRoutePointIndex', value);

  @override
  Stream<RealmObjectChanges<CalculatedDistance>> get changes =>
      RealmObjectBase.getChanges<CalculatedDistance>(this);

  @override
  CalculatedDistance freeze() =>
      RealmObjectBase.freezeObject<CalculatedDistance>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CalculatedDistance._);
    return const SchemaObject(
        ObjectType.embeddedObject, CalculatedDistance, 'CalculatedDistance', [
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeID', RealmPropertyType.string, optional: true),
      SchemaProperty('fromLandmark', RealmPropertyType.string, optional: true),
      SchemaProperty('toLandmark', RealmPropertyType.string, optional: true),
      SchemaProperty('fromLandmarkID', RealmPropertyType.string,
          optional: true),
      SchemaProperty('toLandmarkID', RealmPropertyType.string, optional: true),
      SchemaProperty('distanceInMetres', RealmPropertyType.double,
          optional: true),
      SchemaProperty('distanceFromStart', RealmPropertyType.double,
          optional: true),
      SchemaProperty('fromRoutePointIndex', RealmPropertyType.int,
          optional: true),
      SchemaProperty('toRoutePointIndex', RealmPropertyType.int,
          optional: true),
    ]);
  }
}

class Association extends _Association
    with RealmEntity, RealmObjectBase, RealmObject {
  Association({
    String? associationId,
    String? cityId,
    String? countryId,
    String? associationName,
    String? phone,
    String? status,
    String? countryName,
    String? cityName,
    String? stringDate,
    int? date,
    String? path,
    String? dateRegistered,
    Position? position,
    String? adminUserFirstName,
    String? adminUserLastName,
    String? userId,
    String? adminCellphone,
    String? adminEmail,
  }) {
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'cityId', cityId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'countryName', countryName);
    RealmObjectBase.set(this, 'cityName', cityName);
    RealmObjectBase.set(this, 'stringDate', stringDate);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'path', path);
    RealmObjectBase.set(this, 'dateRegistered', dateRegistered);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'adminUserFirstName', adminUserFirstName);
    RealmObjectBase.set(this, 'adminUserLastName', adminUserLastName);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'adminCellphone', adminCellphone);
    RealmObjectBase.set(this, 'adminEmail', adminEmail);
  }

  Association._();

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get cityId => RealmObjectBase.get<String>(this, 'cityId') as String?;
  @override
  set cityId(String? value) => RealmObjectBase.set(this, 'cityId', value);

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get associationName =>
      RealmObjectBase.get<String>(this, 'associationName') as String?;
  @override
  set associationName(String? value) =>
      RealmObjectBase.set(this, 'associationName', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get countryName =>
      RealmObjectBase.get<String>(this, 'countryName') as String?;
  @override
  set countryName(String? value) =>
      RealmObjectBase.set(this, 'countryName', value);

  @override
  String? get cityName =>
      RealmObjectBase.get<String>(this, 'cityName') as String?;
  @override
  set cityName(String? value) => RealmObjectBase.set(this, 'cityName', value);

  @override
  String? get stringDate =>
      RealmObjectBase.get<String>(this, 'stringDate') as String?;
  @override
  set stringDate(String? value) =>
      RealmObjectBase.set(this, 'stringDate', value);

  @override
  int? get date => RealmObjectBase.get<int>(this, 'date') as int?;
  @override
  set date(int? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get path => RealmObjectBase.get<String>(this, 'path') as String?;
  @override
  set path(String? value) => RealmObjectBase.set(this, 'path', value);

  @override
  String? get dateRegistered =>
      RealmObjectBase.get<String>(this, 'dateRegistered') as String?;
  @override
  set dateRegistered(String? value) =>
      RealmObjectBase.set(this, 'dateRegistered', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get adminUserFirstName =>
      RealmObjectBase.get<String>(this, 'adminUserFirstName') as String?;
  @override
  set adminUserFirstName(String? value) =>
      RealmObjectBase.set(this, 'adminUserFirstName', value);

  @override
  String? get adminUserLastName =>
      RealmObjectBase.get<String>(this, 'adminUserLastName') as String?;
  @override
  set adminUserLastName(String? value) =>
      RealmObjectBase.set(this, 'adminUserLastName', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get adminCellphone =>
      RealmObjectBase.get<String>(this, 'adminCellphone') as String?;
  @override
  set adminCellphone(String? value) =>
      RealmObjectBase.set(this, 'adminCellphone', value);

  @override
  String? get adminEmail =>
      RealmObjectBase.get<String>(this, 'adminEmail') as String?;
  @override
  set adminEmail(String? value) =>
      RealmObjectBase.set(this, 'adminEmail', value);

  @override
  Stream<RealmObjectChanges<Association>> get changes =>
      RealmObjectBase.getChanges<Association>(this);

  @override
  Association freeze() => RealmObjectBase.freezeObject<Association>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Association._);
    return const SchemaObject(
        ObjectType.realmObject, Association, 'Association', [
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('cityId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('status', RealmPropertyType.string, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
      SchemaProperty('cityName', RealmPropertyType.string, optional: true),
      SchemaProperty('stringDate', RealmPropertyType.string, optional: true),
      SchemaProperty('date', RealmPropertyType.int, optional: true),
      SchemaProperty('path', RealmPropertyType.string, optional: true),
      SchemaProperty('dateRegistered', RealmPropertyType.string,
          optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('adminUserFirstName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('adminUserLastName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('adminCellphone', RealmPropertyType.string,
          optional: true),
      SchemaProperty('adminEmail', RealmPropertyType.string, optional: true),
    ]);
  }
}

class AppError extends _AppError
    with RealmEntity, RealmObjectBase, RealmObject {
  AppError({
    String? errorMessage,
    String? manufacturer,
    String? model,
    String? created,
    String? brand,
    String? userId,
    String? associationId,
    String? userName,
    Position? errorPosition,
    String? iosName,
    String? versionCodeName,
    String? baseOS,
    String? deviceType,
    String? iosSystemName,
    String? userUrl,
    String? uploadedDate,
    String? id,
  }) {
    RealmObjectBase.set(this, 'errorMessage', errorMessage);
    RealmObjectBase.set(this, 'manufacturer', manufacturer);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'brand', brand);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'errorPosition', errorPosition);
    RealmObjectBase.set(this, 'iosName', iosName);
    RealmObjectBase.set(this, 'versionCodeName', versionCodeName);
    RealmObjectBase.set(this, 'baseOS', baseOS);
    RealmObjectBase.set(this, 'deviceType', deviceType);
    RealmObjectBase.set(this, 'iosSystemName', iosSystemName);
    RealmObjectBase.set(this, 'userUrl', userUrl);
    RealmObjectBase.set(this, 'uploadedDate', uploadedDate);
    RealmObjectBase.set(this, 'id', id);
  }

  AppError._();

  @override
  String? get errorMessage =>
      RealmObjectBase.get<String>(this, 'errorMessage') as String?;
  @override
  set errorMessage(String? value) =>
      RealmObjectBase.set(this, 'errorMessage', value);

  @override
  String? get manufacturer =>
      RealmObjectBase.get<String>(this, 'manufacturer') as String?;
  @override
  set manufacturer(String? value) =>
      RealmObjectBase.set(this, 'manufacturer', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get brand => RealmObjectBase.get<String>(this, 'brand') as String?;
  @override
  set brand(String? value) => RealmObjectBase.set(this, 'brand', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get userName =>
      RealmObjectBase.get<String>(this, 'userName') as String?;
  @override
  set userName(String? value) => RealmObjectBase.set(this, 'userName', value);

  @override
  Position? get errorPosition =>
      RealmObjectBase.get<Position>(this, 'errorPosition') as Position?;
  @override
  set errorPosition(covariant Position? value) =>
      RealmObjectBase.set(this, 'errorPosition', value);

  @override
  String? get iosName =>
      RealmObjectBase.get<String>(this, 'iosName') as String?;
  @override
  set iosName(String? value) => RealmObjectBase.set(this, 'iosName', value);

  @override
  String? get versionCodeName =>
      RealmObjectBase.get<String>(this, 'versionCodeName') as String?;
  @override
  set versionCodeName(String? value) =>
      RealmObjectBase.set(this, 'versionCodeName', value);

  @override
  String? get baseOS => RealmObjectBase.get<String>(this, 'baseOS') as String?;
  @override
  set baseOS(String? value) => RealmObjectBase.set(this, 'baseOS', value);

  @override
  String? get deviceType =>
      RealmObjectBase.get<String>(this, 'deviceType') as String?;
  @override
  set deviceType(String? value) =>
      RealmObjectBase.set(this, 'deviceType', value);

  @override
  String? get iosSystemName =>
      RealmObjectBase.get<String>(this, 'iosSystemName') as String?;
  @override
  set iosSystemName(String? value) =>
      RealmObjectBase.set(this, 'iosSystemName', value);

  @override
  String? get userUrl =>
      RealmObjectBase.get<String>(this, 'userUrl') as String?;
  @override
  set userUrl(String? value) => RealmObjectBase.set(this, 'userUrl', value);

  @override
  String? get uploadedDate =>
      RealmObjectBase.get<String>(this, 'uploadedDate') as String?;
  @override
  set uploadedDate(String? value) =>
      RealmObjectBase.set(this, 'uploadedDate', value);

  @override
  String? get id => RealmObjectBase.get<String>(this, 'id') as String?;
  @override
  set id(String? value) => RealmObjectBase.set(this, 'id', value);

  @override
  Stream<RealmObjectChanges<AppError>> get changes =>
      RealmObjectBase.getChanges<AppError>(this);

  @override
  AppError freeze() => RealmObjectBase.freezeObject<AppError>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AppError._);
    return const SchemaObject(ObjectType.realmObject, AppError, 'AppError', [
      SchemaProperty('errorMessage', RealmPropertyType.string, optional: true),
      SchemaProperty('manufacturer', RealmPropertyType.string, optional: true),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('brand', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('errorPosition', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('iosName', RealmPropertyType.string, optional: true),
      SchemaProperty('versionCodeName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('baseOS', RealmPropertyType.string, optional: true),
      SchemaProperty('deviceType', RealmPropertyType.string, optional: true),
      SchemaProperty('iosSystemName', RealmPropertyType.string, optional: true),
      SchemaProperty('userUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('uploadedDate', RealmPropertyType.string, optional: true),
      SchemaProperty('id', RealmPropertyType.string, optional: true),
    ]);
  }
}

class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
  User({
    String? userType,
    String? userId,
    String? firstName,
    String? lastName,
    String? gender,
    String? countryId,
    String? associationId,
    String? associationName,
    String? fcmToken,
    String? email,
    String? cellphone,
    String? thumbnailUrl,
    String? imageUrl,
  }) {
    RealmObjectBase.set(this, 'userType', userType);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'firstName', firstName);
    RealmObjectBase.set(this, 'lastName', lastName);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'fcmToken', fcmToken);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'cellphone', cellphone);
    RealmObjectBase.set(this, 'thumbnailUrl', thumbnailUrl);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
  }

  User._();

  @override
  String? get userType =>
      RealmObjectBase.get<String>(this, 'userType') as String?;
  @override
  set userType(String? value) => RealmObjectBase.set(this, 'userType', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get firstName =>
      RealmObjectBase.get<String>(this, 'firstName') as String?;
  @override
  set firstName(String? value) => RealmObjectBase.set(this, 'firstName', value);

  @override
  String? get lastName =>
      RealmObjectBase.get<String>(this, 'lastName') as String?;
  @override
  set lastName(String? value) => RealmObjectBase.set(this, 'lastName', value);

  @override
  String? get gender => RealmObjectBase.get<String>(this, 'gender') as String?;
  @override
  set gender(String? value) => RealmObjectBase.set(this, 'gender', value);

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get associationName =>
      RealmObjectBase.get<String>(this, 'associationName') as String?;
  @override
  set associationName(String? value) =>
      RealmObjectBase.set(this, 'associationName', value);

  @override
  String? get fcmToken =>
      RealmObjectBase.get<String>(this, 'fcmToken') as String?;
  @override
  set fcmToken(String? value) => RealmObjectBase.set(this, 'fcmToken', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get cellphone =>
      RealmObjectBase.get<String>(this, 'cellphone') as String?;
  @override
  set cellphone(String? value) => RealmObjectBase.set(this, 'cellphone', value);

  @override
  String? get thumbnailUrl =>
      RealmObjectBase.get<String>(this, 'thumbnailUrl') as String?;
  @override
  set thumbnailUrl(String? value) =>
      RealmObjectBase.set(this, 'thumbnailUrl', value);

  @override
  String? get imageUrl =>
      RealmObjectBase.get<String>(this, 'imageUrl') as String?;
  @override
  set imageUrl(String? value) => RealmObjectBase.set(this, 'imageUrl', value);

  @override
  Stream<RealmObjectChanges<User>> get changes =>
      RealmObjectBase.getChanges<User>(this);

  @override
  User freeze() => RealmObjectBase.freezeObject<User>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(User._);
    return const SchemaObject(ObjectType.realmObject, User, 'User', [
      SchemaProperty('userType', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('firstName', RealmPropertyType.string, optional: true),
      SchemaProperty('lastName', RealmPropertyType.string, optional: true),
      SchemaProperty('gender', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('fcmToken', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('cellphone', RealmPropertyType.string, optional: true),
      SchemaProperty('thumbnailUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
    ]);
  }
}

class RouteInfo extends _RouteInfo
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RouteInfo({
    String? name,
    String? routeID,
    String? associationID,
    String? associationName,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'routeID', routeID);
    RealmObjectBase.set(this, 'associationID', associationID);
    RealmObjectBase.set(this, 'associationName', associationName);
  }

  RouteInfo._();

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get routeID =>
      RealmObjectBase.get<String>(this, 'routeID') as String?;
  @override
  set routeID(String? value) => RealmObjectBase.set(this, 'routeID', value);

  @override
  String? get associationID =>
      RealmObjectBase.get<String>(this, 'associationID') as String?;
  @override
  set associationID(String? value) =>
      RealmObjectBase.set(this, 'associationID', value);

  @override
  String? get associationName =>
      RealmObjectBase.get<String>(this, 'associationName') as String?;
  @override
  set associationName(String? value) =>
      RealmObjectBase.set(this, 'associationName', value);

  @override
  Stream<RealmObjectChanges<RouteInfo>> get changes =>
      RealmObjectBase.getChanges<RouteInfo>(this);

  @override
  RouteInfo freeze() => RealmObjectBase.freezeObject<RouteInfo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteInfo._);
    return const SchemaObject(
        ObjectType.embeddedObject, RouteInfo, 'RouteInfo', [
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('routeID', RealmPropertyType.string, optional: true),
      SchemaProperty('associationID', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
    ]);
  }
}

class Landmark extends _Landmark
    with RealmEntity, RealmObjectBase, RealmObject {
  Landmark({
    String? landmarkID,
    double? latitude,
    double? longitude,
    double? distance,
    String? landmarkName,
    Position? position,
    Iterable<RouteInfo> routeDetails = const [],
    Iterable<String> cityIds = const [],
    Iterable<String> routePointIds = const [],
  }) {
    RealmObjectBase.set(this, 'landmarkID', landmarkID);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'distance', distance);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set<RealmList<RouteInfo>>(
        this, 'routeDetails', RealmList<RouteInfo>(routeDetails));
    RealmObjectBase.set<RealmList<String>>(
        this, 'cityIds', RealmList<String>(cityIds));
    RealmObjectBase.set<RealmList<String>>(
        this, 'routePointIds', RealmList<String>(routePointIds));
  }

  Landmark._();

  @override
  String? get landmarkID =>
      RealmObjectBase.get<String>(this, 'landmarkID') as String?;
  @override
  set landmarkID(String? value) =>
      RealmObjectBase.set(this, 'landmarkID', value);

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  double? get distance =>
      RealmObjectBase.get<double>(this, 'distance') as double?;
  @override
  set distance(double? value) => RealmObjectBase.set(this, 'distance', value);

  @override
  String? get landmarkName =>
      RealmObjectBase.get<String>(this, 'landmarkName') as String?;
  @override
  set landmarkName(String? value) =>
      RealmObjectBase.set(this, 'landmarkName', value);

  @override
  RealmList<RouteInfo> get routeDetails =>
      RealmObjectBase.get<RouteInfo>(this, 'routeDetails')
          as RealmList<RouteInfo>;
  @override
  set routeDetails(covariant RealmList<RouteInfo> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get cityIds =>
      RealmObjectBase.get<String>(this, 'cityIds') as RealmList<String>;
  @override
  set cityIds(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  RealmList<String> get routePointIds =>
      RealmObjectBase.get<String>(this, 'routePointIds') as RealmList<String>;
  @override
  set routePointIds(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Landmark>> get changes =>
      RealmObjectBase.getChanges<Landmark>(this);

  @override
  Landmark freeze() => RealmObjectBase.freezeObject<Landmark>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Landmark._);
    return const SchemaObject(ObjectType.realmObject, Landmark, 'Landmark', [
      SchemaProperty('landmarkID', RealmPropertyType.string, optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('distance', RealmPropertyType.double, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeDetails', RealmPropertyType.object,
          linkTarget: 'RouteInfo', collectionType: RealmCollectionType.list),
      SchemaProperty('cityIds', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('routePointIds', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class SettingsModel extends _SettingsModel
    with RealmEntity, RealmObjectBase, RealmObject {
  SettingsModel({
    String? associationId,
    String? locale,
    int? refreshRateInSeconds,
    int? themeIndex,
  }) {
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'locale', locale);
    RealmObjectBase.set(this, 'refreshRateInSeconds', refreshRateInSeconds);
    RealmObjectBase.set(this, 'themeIndex', themeIndex);
  }

  SettingsModel._();

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get locale => RealmObjectBase.get<String>(this, 'locale') as String?;
  @override
  set locale(String? value) => RealmObjectBase.set(this, 'locale', value);

  @override
  int? get refreshRateInSeconds =>
      RealmObjectBase.get<int>(this, 'refreshRateInSeconds') as int?;
  @override
  set refreshRateInSeconds(int? value) =>
      RealmObjectBase.set(this, 'refreshRateInSeconds', value);

  @override
  int? get themeIndex => RealmObjectBase.get<int>(this, 'themeIndex') as int?;
  @override
  set themeIndex(int? value) => RealmObjectBase.set(this, 'themeIndex', value);

  @override
  Stream<RealmObjectChanges<SettingsModel>> get changes =>
      RealmObjectBase.getChanges<SettingsModel>(this);

  @override
  SettingsModel freeze() => RealmObjectBase.freezeObject<SettingsModel>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(SettingsModel._);
    return const SchemaObject(
        ObjectType.realmObject, SettingsModel, 'SettingsModel', [
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('locale', RealmPropertyType.string, optional: true),
      SchemaProperty('refreshRateInSeconds', RealmPropertyType.int,
          optional: true),
      SchemaProperty('themeIndex', RealmPropertyType.int, optional: true),
    ]);
  }
}
