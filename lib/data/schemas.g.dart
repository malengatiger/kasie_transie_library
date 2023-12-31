// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Country extends _Country with RealmEntity, RealmObjectBase, RealmObject {
  Country(
    ObjectId id, {
    String? countryId,
    String? name,
    String? iso2,
    String? iso3,
    String? capital,
    String? currency,
    String? region,
    String? subregion,
    String? emoji,
    String? phone_code,
    String? currency_name,
    String? currency_symbol,
    double? latitude,
    double? longitude,
    Position? position,
    String? geoHash,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'iso2', iso2);
    RealmObjectBase.set(this, 'iso3', iso3);
    RealmObjectBase.set(this, 'capital', capital);
    RealmObjectBase.set(this, 'currency', currency);
    RealmObjectBase.set(this, 'region', region);
    RealmObjectBase.set(this, 'subregion', subregion);
    RealmObjectBase.set(this, 'emoji', emoji);
    RealmObjectBase.set(this, 'phone_code', phone_code);
    RealmObjectBase.set(this, 'currency_name', currency_name);
    RealmObjectBase.set(this, 'currency_symbol', currency_symbol);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
  }

  Country._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  String? get iso3 => RealmObjectBase.get<String>(this, 'iso3') as String?;
  @override
  set iso3(String? value) => RealmObjectBase.set(this, 'iso3', value);

  @override
  String? get capital =>
      RealmObjectBase.get<String>(this, 'capital') as String?;
  @override
  set capital(String? value) => RealmObjectBase.set(this, 'capital', value);

  @override
  String? get currency =>
      RealmObjectBase.get<String>(this, 'currency') as String?;
  @override
  set currency(String? value) => RealmObjectBase.set(this, 'currency', value);

  @override
  String? get region => RealmObjectBase.get<String>(this, 'region') as String?;
  @override
  set region(String? value) => RealmObjectBase.set(this, 'region', value);

  @override
  String? get subregion =>
      RealmObjectBase.get<String>(this, 'subregion') as String?;
  @override
  set subregion(String? value) => RealmObjectBase.set(this, 'subregion', value);

  @override
  String? get emoji => RealmObjectBase.get<String>(this, 'emoji') as String?;
  @override
  set emoji(String? value) => RealmObjectBase.set(this, 'emoji', value);

  @override
  String? get phone_code =>
      RealmObjectBase.get<String>(this, 'phone_code') as String?;
  @override
  set phone_code(String? value) =>
      RealmObjectBase.set(this, 'phone_code', value);

  @override
  String? get currency_name =>
      RealmObjectBase.get<String>(this, 'currency_name') as String?;
  @override
  set currency_name(String? value) =>
      RealmObjectBase.set(this, 'currency_name', value);

  @override
  String? get currency_symbol =>
      RealmObjectBase.get<String>(this, 'currency_symbol') as String?;
  @override
  set currency_symbol(String? value) =>
      RealmObjectBase.set(this, 'currency_symbol', value);

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
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('countryId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('iso2', RealmPropertyType.string, optional: true),
      SchemaProperty('iso3', RealmPropertyType.string, optional: true),
      SchemaProperty('capital', RealmPropertyType.string, optional: true),
      SchemaProperty('currency', RealmPropertyType.string, optional: true),
      SchemaProperty('region', RealmPropertyType.string, optional: true),
      SchemaProperty('subregion', RealmPropertyType.string, optional: true),
      SchemaProperty('emoji', RealmPropertyType.string, optional: true),
      SchemaProperty('phone_code', RealmPropertyType.string, optional: true),
      SchemaProperty('currency_name', RealmPropertyType.string, optional: true),
      SchemaProperty('currency_symbol', RealmPropertyType.string,
          optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
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
    String? geoHash,
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
    RealmObjectBase.set(this, 'geoHash', geoHash);
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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
    ]);
  }
}

class City extends _City with RealmEntity, RealmObjectBase, RealmObject {
  City(
    ObjectId id, {
    String? cityId,
    String? countryId,
    String? name,
    String? distance,
    String? stateName,
    double? latitude,
    double? longitude,
    String? countryName,
    String? stateId,
    Position? position,
    String? geoHash,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'cityId', cityId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'distance', distance);
    RealmObjectBase.set(this, 'stateName', stateName);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'countryName', countryName);
    RealmObjectBase.set(this, 'stateId', stateId);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
  }

  City._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  String? get stateId =>
      RealmObjectBase.get<String>(this, 'stateId') as String?;
  @override
  set stateId(String? value) => RealmObjectBase.set(this, 'stateId', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('cityId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('distance', RealmPropertyType.string, optional: true),
      SchemaProperty('stateName', RealmPropertyType.string, optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
      SchemaProperty('stateId', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
    ]);
  }
}

class DispatchRecord extends _DispatchRecord
    with RealmEntity, RealmObjectBase, RealmObject {
  DispatchRecord(
    ObjectId id, {
    String? dispatchRecordId,
    String? marshalId,
    int? passengers,
    String? ownerId,
    String? created,
    Position? position,
    String? geoHash,
    String? landmarkName,
    String? marshalName,
    String? routeName,
    String? routeId,
    String? vehicleId,
    String? vehicleArrivalId,
    String? vehicleReg,
    String? associationId,
    String? associationName,
    String? routeLandmarkId,
    bool? dispatched,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'dispatchRecordId', dispatchRecordId);
    RealmObjectBase.set(this, 'marshalId', marshalId);
    RealmObjectBase.set(this, 'passengers', passengers);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'marshalName', marshalName);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleArrivalId', vehicleArrivalId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'routeLandmarkId', routeLandmarkId);
    RealmObjectBase.set(this, 'dispatched', dispatched);
  }

  DispatchRecord._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get dispatchRecordId =>
      RealmObjectBase.get<String>(this, 'dispatchRecordId') as String?;
  @override
  set dispatchRecordId(String? value) =>
      RealmObjectBase.set(this, 'dispatchRecordId', value);

  @override
  String? get marshalId =>
      RealmObjectBase.get<String>(this, 'marshalId') as String?;
  @override
  set marshalId(String? value) => RealmObjectBase.set(this, 'marshalId', value);

  @override
  int? get passengers => RealmObjectBase.get<int>(this, 'passengers') as int?;
  @override
  set passengers(int? value) => RealmObjectBase.set(this, 'passengers', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get landmarkName =>
      RealmObjectBase.get<String>(this, 'landmarkName') as String?;
  @override
  set landmarkName(String? value) =>
      RealmObjectBase.set(this, 'landmarkName', value);

  @override
  String? get marshalName =>
      RealmObjectBase.get<String>(this, 'marshalName') as String?;
  @override
  set marshalName(String? value) =>
      RealmObjectBase.set(this, 'marshalName', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleArrivalId =>
      RealmObjectBase.get<String>(this, 'vehicleArrivalId') as String?;
  @override
  set vehicleArrivalId(String? value) =>
      RealmObjectBase.set(this, 'vehicleArrivalId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

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
  String? get routeLandmarkId =>
      RealmObjectBase.get<String>(this, 'routeLandmarkId') as String?;
  @override
  set routeLandmarkId(String? value) =>
      RealmObjectBase.set(this, 'routeLandmarkId', value);

  @override
  bool? get dispatched =>
      RealmObjectBase.get<bool>(this, 'dispatched') as bool?;
  @override
  set dispatched(bool? value) => RealmObjectBase.set(this, 'dispatched', value);

  @override
  Stream<RealmObjectChanges<DispatchRecord>> get changes =>
      RealmObjectBase.getChanges<DispatchRecord>(this);

  @override
  DispatchRecord freeze() => RealmObjectBase.freezeObject<DispatchRecord>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(DispatchRecord._);
    return const SchemaObject(
        ObjectType.realmObject, DispatchRecord, 'DispatchRecord', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('dispatchRecordId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('marshalId', RealmPropertyType.string, optional: true),
      SchemaProperty('passengers', RealmPropertyType.int, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('marshalName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleArrivalId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('routeLandmarkId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('dispatched', RealmPropertyType.bool, optional: true),
    ]);
  }
}

class Association extends _Association
    with RealmEntity, RealmObjectBase, RealmObject {
  Association(
    ObjectId id, {
    String? cityId,
    String? countryId,
    String? cityName,
    String? associationName,
    String? associationId,
    int? active,
    String? countryName,
    String? dateRegistered,
    Position? position,
    String? geoHash,
    String? adminUserFirstName,
    String? adminUserLastName,
    String? userId,
    String? adminCellphone,
    String? adminEmail,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'cityId', cityId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'cityName', cityName);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'active', active);
    RealmObjectBase.set(this, 'countryName', countryName);
    RealmObjectBase.set(this, 'dateRegistered', dateRegistered);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'adminUserFirstName', adminUserFirstName);
    RealmObjectBase.set(this, 'adminUserLastName', adminUserLastName);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'adminCellphone', adminCellphone);
    RealmObjectBase.set(this, 'adminEmail', adminEmail);
  }

  Association._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  String? get cityName =>
      RealmObjectBase.get<String>(this, 'cityName') as String?;
  @override
  set cityName(String? value) => RealmObjectBase.set(this, 'cityName', value);

  @override
  String? get associationName =>
      RealmObjectBase.get<String>(this, 'associationName') as String?;
  @override
  set associationName(String? value) =>
      RealmObjectBase.set(this, 'associationName', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  int? get active => RealmObjectBase.get<int>(this, 'active') as int?;
  @override
  set active(int? value) => RealmObjectBase.set(this, 'active', value);

  @override
  String? get countryName =>
      RealmObjectBase.get<String>(this, 'countryName') as String?;
  @override
  set countryName(String? value) =>
      RealmObjectBase.set(this, 'countryName', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('cityId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('cityName', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('active', RealmPropertyType.int, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
      SchemaProperty('dateRegistered', RealmPropertyType.string,
          optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
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

class RouteUpdateRequest extends _RouteUpdateRequest
    with RealmEntity, RealmObjectBase, RealmObject {
  RouteUpdateRequest(
    ObjectId id, {
    String? routeId,
    String? routeName,
    String? userId,
    String? created,
    String? associationId,
    String? userName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'userName', userName);
  }

  RouteUpdateRequest._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

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
  Stream<RealmObjectChanges<RouteUpdateRequest>> get changes =>
      RealmObjectBase.getChanges<RouteUpdateRequest>(this);

  @override
  RouteUpdateRequest freeze() =>
      RealmObjectBase.freezeObject<RouteUpdateRequest>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteUpdateRequest._);
    return const SchemaObject(
        ObjectType.realmObject, RouteUpdateRequest, 'RouteUpdateRequest', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
    ]);
  }
}

class VehicleMediaRequest extends _VehicleMediaRequest
    with RealmEntity, RealmObjectBase, RealmObject {
  VehicleMediaRequest(
    ObjectId id, {
    String? userId,
    String? vehicleId,
    String? vehicleReg,
    String? requesterId,
    String? created,
    String? associationId,
    String? requesterName,
    bool? addVideo,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'requesterId', requesterId);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'requesterName', requesterName);
    RealmObjectBase.set(this, 'addVideo', addVideo);
  }

  VehicleMediaRequest._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get requesterId =>
      RealmObjectBase.get<String>(this, 'requesterId') as String?;
  @override
  set requesterId(String? value) =>
      RealmObjectBase.set(this, 'requesterId', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get requesterName =>
      RealmObjectBase.get<String>(this, 'requesterName') as String?;
  @override
  set requesterName(String? value) =>
      RealmObjectBase.set(this, 'requesterName', value);

  @override
  bool? get addVideo => RealmObjectBase.get<bool>(this, 'addVideo') as bool?;
  @override
  set addVideo(bool? value) => RealmObjectBase.set(this, 'addVideo', value);

  @override
  Stream<RealmObjectChanges<VehicleMediaRequest>> get changes =>
      RealmObjectBase.getChanges<VehicleMediaRequest>(this);

  @override
  VehicleMediaRequest freeze() =>
      RealmObjectBase.freezeObject<VehicleMediaRequest>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehicleMediaRequest._);
    return const SchemaObject(
        ObjectType.realmObject, VehicleMediaRequest, 'VehicleMediaRequest', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('requesterId', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('requesterName', RealmPropertyType.string, optional: true),
      SchemaProperty('addVideo', RealmPropertyType.bool, optional: true),
    ]);
  }
}

class VehicleArrival extends _VehicleArrival
    with RealmEntity, RealmObjectBase, RealmObject {
  VehicleArrival(
    ObjectId id, {
    String? vehicleArrivalId,
    String? landmarkId,
    String? landmarkName,
    Position? position,
    String? geoHash,
    String? created,
    String? vehicleId,
    String? associationId,
    String? associationName,
    String? vehicleReg,
    String? make,
    String? model,
    String? ownerId,
    String? ownerName,
    bool? dispatched,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleArrivalId', vehicleArrivalId);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'ownerName', ownerName);
    RealmObjectBase.set(this, 'dispatched', dispatched);
  }

  VehicleArrival._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleArrivalId =>
      RealmObjectBase.get<String>(this, 'vehicleArrivalId') as String?;
  @override
  set vehicleArrivalId(String? value) =>
      RealmObjectBase.set(this, 'vehicleArrivalId', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

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
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get make => RealmObjectBase.get<String>(this, 'make') as String?;
  @override
  set make(String? value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get ownerName =>
      RealmObjectBase.get<String>(this, 'ownerName') as String?;
  @override
  set ownerName(String? value) => RealmObjectBase.set(this, 'ownerName', value);

  @override
  bool? get dispatched =>
      RealmObjectBase.get<bool>(this, 'dispatched') as bool?;
  @override
  set dispatched(bool? value) => RealmObjectBase.set(this, 'dispatched', value);

  @override
  Stream<RealmObjectChanges<VehicleArrival>> get changes =>
      RealmObjectBase.getChanges<VehicleArrival>(this);

  @override
  VehicleArrival freeze() => RealmObjectBase.freezeObject<VehicleArrival>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehicleArrival._);
    return const SchemaObject(
        ObjectType.realmObject, VehicleArrival, 'VehicleArrival', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleArrivalId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('make', RealmPropertyType.string, optional: true),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerName', RealmPropertyType.string, optional: true),
      SchemaProperty('dispatched', RealmPropertyType.bool, optional: true),
    ]);
  }
}

class VehiclePhoto extends _VehiclePhoto
    with RealmEntity, RealmObjectBase, RealmObject {
  VehiclePhoto(
    ObjectId id, {
    String? vehiclePhotoId,
    String? landmarkId,
    String? landmarkName,
    Position? position,
    String? geoHash,
    String? created,
    String? vehicleId,
    String? associationId,
    String? vehicleReg,
    String? thumbNailUrl,
    String? url,
    String? userId,
    String? userName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehiclePhotoId', vehiclePhotoId);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'thumbNailUrl', thumbNailUrl);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
  }

  VehiclePhoto._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehiclePhotoId =>
      RealmObjectBase.get<String>(this, 'vehiclePhotoId') as String?;
  @override
  set vehiclePhotoId(String? value) =>
      RealmObjectBase.set(this, 'vehiclePhotoId', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get thumbNailUrl =>
      RealmObjectBase.get<String>(this, 'thumbNailUrl') as String?;
  @override
  set thumbNailUrl(String? value) =>
      RealmObjectBase.set(this, 'thumbNailUrl', value);

  @override
  String? get url => RealmObjectBase.get<String>(this, 'url') as String?;
  @override
  set url(String? value) => RealmObjectBase.set(this, 'url', value);

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
  Stream<RealmObjectChanges<VehiclePhoto>> get changes =>
      RealmObjectBase.getChanges<VehiclePhoto>(this);

  @override
  VehiclePhoto freeze() => RealmObjectBase.freezeObject<VehiclePhoto>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehiclePhoto._);
    return const SchemaObject(
        ObjectType.realmObject, VehiclePhoto, 'VehiclePhoto', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehiclePhotoId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('thumbNailUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('url', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
    ]);
  }
}

class VehicleVideo extends _VehicleVideo
    with RealmEntity, RealmObjectBase, RealmObject {
  VehicleVideo(
    ObjectId id, {
    String? vehicleVideoId,
    String? landmarkId,
    String? landmarkName,
    Position? position,
    String? geoHash,
    String? created,
    String? vehicleId,
    String? associationId,
    String? vehicleReg,
    String? thumbNailUrl,
    String? url,
    String? userId,
    String? userName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleVideoId', vehicleVideoId);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'thumbNailUrl', thumbNailUrl);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
  }

  VehicleVideo._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleVideoId =>
      RealmObjectBase.get<String>(this, 'vehicleVideoId') as String?;
  @override
  set vehicleVideoId(String? value) =>
      RealmObjectBase.set(this, 'vehicleVideoId', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get thumbNailUrl =>
      RealmObjectBase.get<String>(this, 'thumbNailUrl') as String?;
  @override
  set thumbNailUrl(String? value) =>
      RealmObjectBase.set(this, 'thumbNailUrl', value);

  @override
  String? get url => RealmObjectBase.get<String>(this, 'url') as String?;
  @override
  set url(String? value) => RealmObjectBase.set(this, 'url', value);

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
  Stream<RealmObjectChanges<VehicleVideo>> get changes =>
      RealmObjectBase.getChanges<VehicleVideo>(this);

  @override
  VehicleVideo freeze() => RealmObjectBase.freezeObject<VehicleVideo>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehicleVideo._);
    return const SchemaObject(
        ObjectType.realmObject, VehicleVideo, 'VehicleVideo', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleVideoId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('thumbNailUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('url', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
    ]);
  }
}

class VehicleDeparture extends _VehicleDeparture
    with RealmEntity, RealmObjectBase, RealmObject {
  VehicleDeparture(
    ObjectId id, {
    String? vehicleDepartureId,
    String? landmarkId,
    String? landmarkName,
    Position? position,
    String? geoHash,
    String? created,
    String? vehicleId,
    String? associationId,
    String? associationName,
    String? vehicleReg,
    String? make,
    String? model,
    String? ownerId,
    String? ownerName,
    bool? dispatched,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleDepartureId', vehicleDepartureId);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'ownerName', ownerName);
    RealmObjectBase.set(this, 'dispatched', dispatched);
  }

  VehicleDeparture._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleDepartureId =>
      RealmObjectBase.get<String>(this, 'vehicleDepartureId') as String?;
  @override
  set vehicleDepartureId(String? value) =>
      RealmObjectBase.set(this, 'vehicleDepartureId', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

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
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get make => RealmObjectBase.get<String>(this, 'make') as String?;
  @override
  set make(String? value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get ownerName =>
      RealmObjectBase.get<String>(this, 'ownerName') as String?;
  @override
  set ownerName(String? value) => RealmObjectBase.set(this, 'ownerName', value);

  @override
  bool? get dispatched =>
      RealmObjectBase.get<bool>(this, 'dispatched') as bool?;
  @override
  set dispatched(bool? value) => RealmObjectBase.set(this, 'dispatched', value);

  @override
  Stream<RealmObjectChanges<VehicleDeparture>> get changes =>
      RealmObjectBase.getChanges<VehicleDeparture>(this);

  @override
  VehicleDeparture freeze() =>
      RealmObjectBase.freezeObject<VehicleDeparture>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehicleDeparture._);
    return const SchemaObject(
        ObjectType.realmObject, VehicleDeparture, 'VehicleDeparture', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleDepartureId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('make', RealmPropertyType.string, optional: true),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerName', RealmPropertyType.string, optional: true),
      SchemaProperty('dispatched', RealmPropertyType.bool, optional: true),
    ]);
  }
}

class UserGeofenceEvent extends _UserGeofenceEvent
    with RealmEntity, RealmObjectBase, RealmObject {
  UserGeofenceEvent(
    ObjectId id, {
    String? userGeofenceId,
    String? activityType,
    String? landmarkId,
    String? landmarkName,
    Position? position,
    String? geoHash,
    String? created,
    String? action,
    String? associationId,
    String? associationName,
    String? userId,
    int? confidence,
    double? odometer,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userGeofenceId', userGeofenceId);
    RealmObjectBase.set(this, 'activityType', activityType);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'action', action);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'confidence', confidence);
    RealmObjectBase.set(this, 'odometer', odometer);
  }

  UserGeofenceEvent._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get userGeofenceId =>
      RealmObjectBase.get<String>(this, 'userGeofenceId') as String?;
  @override
  set userGeofenceId(String? value) =>
      RealmObjectBase.set(this, 'userGeofenceId', value);

  @override
  String? get activityType =>
      RealmObjectBase.get<String>(this, 'activityType') as String?;
  @override
  set activityType(String? value) =>
      RealmObjectBase.set(this, 'activityType', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get action => RealmObjectBase.get<String>(this, 'action') as String?;
  @override
  set action(String? value) => RealmObjectBase.set(this, 'action', value);

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
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  int? get confidence => RealmObjectBase.get<int>(this, 'confidence') as int?;
  @override
  set confidence(int? value) => RealmObjectBase.set(this, 'confidence', value);

  @override
  double? get odometer =>
      RealmObjectBase.get<double>(this, 'odometer') as double?;
  @override
  set odometer(double? value) => RealmObjectBase.set(this, 'odometer', value);

  @override
  Stream<RealmObjectChanges<UserGeofenceEvent>> get changes =>
      RealmObjectBase.getChanges<UserGeofenceEvent>(this);

  @override
  UserGeofenceEvent freeze() =>
      RealmObjectBase.freezeObject<UserGeofenceEvent>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(UserGeofenceEvent._);
    return const SchemaObject(
        ObjectType.realmObject, UserGeofenceEvent, 'UserGeofenceEvent', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('userGeofenceId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('activityType', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('action', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('confidence', RealmPropertyType.int, optional: true),
      SchemaProperty('odometer', RealmPropertyType.double, optional: true),
    ]);
  }
}

class VehicleHeartbeat extends _VehicleHeartbeat
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  VehicleHeartbeat(
    ObjectId id, {
    String? vehicleHeartbeatId,
    Position? position,
    String? geoHash,
    String? created,
    String? vehicleId,
    String? associationId,
    String? vehicleReg,
    String? make,
    String? model,
    String? ownerId,
    String? ownerName,
    int? longDate,
    bool? appToBackground = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<VehicleHeartbeat>({
        'appToBackground': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleHeartbeatId', vehicleHeartbeatId);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'ownerName', ownerName);
    RealmObjectBase.set(this, 'longDate', longDate);
    RealmObjectBase.set(this, 'appToBackground', appToBackground);
  }

  VehicleHeartbeat._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleHeartbeatId =>
      RealmObjectBase.get<String>(this, 'vehicleHeartbeatId') as String?;
  @override
  set vehicleHeartbeatId(String? value) =>
      RealmObjectBase.set(this, 'vehicleHeartbeatId', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get make => RealmObjectBase.get<String>(this, 'make') as String?;
  @override
  set make(String? value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get ownerName =>
      RealmObjectBase.get<String>(this, 'ownerName') as String?;
  @override
  set ownerName(String? value) => RealmObjectBase.set(this, 'ownerName', value);

  @override
  int? get longDate => RealmObjectBase.get<int>(this, 'longDate') as int?;
  @override
  set longDate(int? value) => RealmObjectBase.set(this, 'longDate', value);

  @override
  bool? get appToBackground =>
      RealmObjectBase.get<bool>(this, 'appToBackground') as bool?;
  @override
  set appToBackground(bool? value) =>
      RealmObjectBase.set(this, 'appToBackground', value);

  @override
  Stream<RealmObjectChanges<VehicleHeartbeat>> get changes =>
      RealmObjectBase.getChanges<VehicleHeartbeat>(this);

  @override
  VehicleHeartbeat freeze() =>
      RealmObjectBase.freezeObject<VehicleHeartbeat>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(VehicleHeartbeat._);
    return const SchemaObject(
        ObjectType.realmObject, VehicleHeartbeat, 'VehicleHeartbeat', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleHeartbeatId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('make', RealmPropertyType.string, optional: true),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerName', RealmPropertyType.string, optional: true),
      SchemaProperty('longDate', RealmPropertyType.int, optional: true),
      SchemaProperty('appToBackground', RealmPropertyType.bool, optional: true),
    ]);
  }
}

class RoutePoint extends _RoutePoint
    with RealmEntity, RealmObjectBase, RealmObject {
  RoutePoint(
    ObjectId id, {
    String? routePointId,
    String? associationId,
    double? latitude,
    double? longitude,
    double? heading,
    int? index,
    String? created,
    String? routeId,
    String? routeName,
    Position? position,
    String? geoHash,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'routePointId', routePointId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'heading', heading);
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
  }

  RoutePoint._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get routePointId =>
      RealmObjectBase.get<String>(this, 'routePointId') as String?;
  @override
  set routePointId(String? value) =>
      RealmObjectBase.set(this, 'routePointId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

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
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routePointId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('heading', RealmPropertyType.double, optional: true),
      SchemaProperty('index', RealmPropertyType.int, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Route extends _Route with RealmEntity, RealmObjectBase, RealmObject {
  Route(
    ObjectId id, {
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
    RouteStartEnd? routeStartEnd,
  }) {
    RealmObjectBase.set(this, 'id', id);
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
    RealmObjectBase.set(this, 'routeStartEnd', routeStartEnd);
  }

  Route._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  RouteStartEnd? get routeStartEnd =>
      RealmObjectBase.get<RouteStartEnd>(this, 'routeStartEnd')
          as RouteStartEnd?;
  @override
  set routeStartEnd(covariant RouteStartEnd? value) =>
      RealmObjectBase.set(this, 'routeStartEnd', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routeId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
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
      SchemaProperty('heading', RealmPropertyType.double, optional: true),
      SchemaProperty('lengthInMetres', RealmPropertyType.int, optional: true),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('userUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('routeStartEnd', RealmPropertyType.object,
          optional: true, linkTarget: 'RouteStartEnd'),
    ]);
  }
}

class RouteAssignment extends _RouteAssignment
    with RealmEntity, RealmObjectBase, RealmObject {
  RouteAssignment(
    ObjectId id, {
    String? vehicleId,
    String? routeId,
    String? routeName,
    String? created,
    String? vehicleReg,
    int? active,
    String? associationId,
    String? associationName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'active', active);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
  }

  RouteAssignment._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  int? get active => RealmObjectBase.get<int>(this, 'active') as int?;
  @override
  set active(int? value) => RealmObjectBase.set(this, 'active', value);

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
  Stream<RealmObjectChanges<RouteAssignment>> get changes =>
      RealmObjectBase.getChanges<RouteAssignment>(this);

  @override
  RouteAssignment freeze() =>
      RealmObjectBase.freezeObject<RouteAssignment>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteAssignment._);
    return const SchemaObject(
        ObjectType.realmObject, RouteAssignment, 'RouteAssignment', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('active', RealmPropertyType.int, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
    ]);
  }
}

class Vehicle extends _Vehicle with RealmEntity, RealmObjectBase, RealmObject {
  Vehicle(
    ObjectId id, {
    String? vehicleId,
    String? countryId,
    String? ownerName,
    String? ownerId,
    String? created,
    String? dateInstalled,
    String? vehicleReg,
    String? make,
    String? model,
    String? year,
    String? qrCodeUrl,
    int? passengerCapacity,
    String? associationId,
    String? associationName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'ownerName', ownerName);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'dateInstalled', dateInstalled);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'make', make);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'qrCodeUrl', qrCodeUrl);
    RealmObjectBase.set(this, 'passengerCapacity', passengerCapacity);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
  }

  Vehicle._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get countryId =>
      RealmObjectBase.get<String>(this, 'countryId') as String?;
  @override
  set countryId(String? value) => RealmObjectBase.set(this, 'countryId', value);

  @override
  String? get ownerName =>
      RealmObjectBase.get<String>(this, 'ownerName') as String?;
  @override
  set ownerName(String? value) => RealmObjectBase.set(this, 'ownerName', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get dateInstalled =>
      RealmObjectBase.get<String>(this, 'dateInstalled') as String?;
  @override
  set dateInstalled(String? value) =>
      RealmObjectBase.set(this, 'dateInstalled', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get make => RealmObjectBase.get<String>(this, 'make') as String?;
  @override
  set make(String? value) => RealmObjectBase.set(this, 'make', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  String? get year => RealmObjectBase.get<String>(this, 'year') as String?;
  @override
  set year(String? value) => RealmObjectBase.set(this, 'year', value);

  @override
  String? get qrCodeUrl =>
      RealmObjectBase.get<String>(this, 'qrCodeUrl') as String?;
  @override
  set qrCodeUrl(String? value) => RealmObjectBase.set(this, 'qrCodeUrl', value);

  @override
  int? get passengerCapacity =>
      RealmObjectBase.get<int>(this, 'passengerCapacity') as int?;
  @override
  set passengerCapacity(int? value) =>
      RealmObjectBase.set(this, 'passengerCapacity', value);

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
  Stream<RealmObjectChanges<Vehicle>> get changes =>
      RealmObjectBase.getChanges<Vehicle>(this);

  @override
  Vehicle freeze() => RealmObjectBase.freezeObject<Vehicle>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Vehicle._);
    return const SchemaObject(ObjectType.realmObject, Vehicle, 'Vehicle', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerName', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('dateInstalled', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('make', RealmPropertyType.string, optional: true),
      SchemaProperty('model', RealmPropertyType.string, optional: true),
      SchemaProperty('year', RealmPropertyType.string, optional: true),
      SchemaProperty('qrCodeUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('passengerCapacity', RealmPropertyType.int,
          optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
    ]);
  }
}

class CalculatedDistance extends _CalculatedDistance
    with RealmEntity, RealmObjectBase, RealmObject {
  CalculatedDistance(
    ObjectId id, {
    String? routeName,
    String? routeId,
    String? fromLandmark,
    String? toLandmark,
    String? fromLandmarkId,
    String? toLandmarkId,
    String? associationId,
    int? distanceInMetres,
    int? distanceFromStart,
    int? fromRoutePointIndex,
    int? toRoutePointIndex,
    int? index,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'fromLandmark', fromLandmark);
    RealmObjectBase.set(this, 'toLandmark', toLandmark);
    RealmObjectBase.set(this, 'fromLandmarkId', fromLandmarkId);
    RealmObjectBase.set(this, 'toLandmarkId', toLandmarkId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'distanceInMetres', distanceInMetres);
    RealmObjectBase.set(this, 'distanceFromStart', distanceFromStart);
    RealmObjectBase.set(this, 'fromRoutePointIndex', fromRoutePointIndex);
    RealmObjectBase.set(this, 'toRoutePointIndex', toRoutePointIndex);
    RealmObjectBase.set(this, 'index', index);
  }

  CalculatedDistance._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

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
  String? get fromLandmarkId =>
      RealmObjectBase.get<String>(this, 'fromLandmarkId') as String?;
  @override
  set fromLandmarkId(String? value) =>
      RealmObjectBase.set(this, 'fromLandmarkId', value);

  @override
  String? get toLandmarkId =>
      RealmObjectBase.get<String>(this, 'toLandmarkId') as String?;
  @override
  set toLandmarkId(String? value) =>
      RealmObjectBase.set(this, 'toLandmarkId', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  int? get distanceInMetres =>
      RealmObjectBase.get<int>(this, 'distanceInMetres') as int?;
  @override
  set distanceInMetres(int? value) =>
      RealmObjectBase.set(this, 'distanceInMetres', value);

  @override
  int? get distanceFromStart =>
      RealmObjectBase.get<int>(this, 'distanceFromStart') as int?;
  @override
  set distanceFromStart(int? value) =>
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
  int? get index => RealmObjectBase.get<int>(this, 'index') as int?;
  @override
  set index(int? value) => RealmObjectBase.set(this, 'index', value);

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
        ObjectType.realmObject, CalculatedDistance, 'CalculatedDistance', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('fromLandmark', RealmPropertyType.string, optional: true),
      SchemaProperty('toLandmark', RealmPropertyType.string, optional: true),
      SchemaProperty('fromLandmarkId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('toLandmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('distanceInMetres', RealmPropertyType.int, optional: true),
      SchemaProperty('distanceFromStart', RealmPropertyType.int,
          optional: true),
      SchemaProperty('fromRoutePointIndex', RealmPropertyType.int,
          optional: true),
      SchemaProperty('toRoutePointIndex', RealmPropertyType.int,
          optional: true),
      SchemaProperty('index', RealmPropertyType.int, optional: true),
    ]);
  }
}

class AppError extends _AppError
    with RealmEntity, RealmObjectBase, RealmObject {
  AppError(
    ObjectId id, {
    String? appErrorId,
    String? errorMessage,
    String? manufacturer,
    String? model,
    String? created,
    String? brand,
    String? userId,
    String? associationId,
    String? userName,
    Position? errorPosition,
    String? geoHash,
    String? iosName,
    String? versionCodeName,
    String? baseOS,
    String? deviceType,
    String? iosSystemName,
    String? userUrl,
    String? uploadedDate,
    String? vehicleId,
    String? vehicleReg,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'appErrorId', appErrorId);
    RealmObjectBase.set(this, 'errorMessage', errorMessage);
    RealmObjectBase.set(this, 'manufacturer', manufacturer);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'brand', brand);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'errorPosition', errorPosition);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'iosName', iosName);
    RealmObjectBase.set(this, 'versionCodeName', versionCodeName);
    RealmObjectBase.set(this, 'baseOS', baseOS);
    RealmObjectBase.set(this, 'deviceType', deviceType);
    RealmObjectBase.set(this, 'iosSystemName', iosSystemName);
    RealmObjectBase.set(this, 'userUrl', userUrl);
    RealmObjectBase.set(this, 'uploadedDate', uploadedDate);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
  }

  AppError._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get appErrorId =>
      RealmObjectBase.get<String>(this, 'appErrorId') as String?;
  @override
  set appErrorId(String? value) =>
      RealmObjectBase.set(this, 'appErrorId', value);

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
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('appErrorId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
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
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('iosName', RealmPropertyType.string, optional: true),
      SchemaProperty('versionCodeName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('baseOS', RealmPropertyType.string, optional: true),
      SchemaProperty('deviceType', RealmPropertyType.string, optional: true),
      SchemaProperty('iosSystemName', RealmPropertyType.string, optional: true),
      SchemaProperty('userUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('uploadedDate', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
    ]);
  }
}

class CommuterRequest extends _CommuterRequest
    with RealmEntity, RealmObjectBase, RealmObject {
  CommuterRequest(
    ObjectId id, {
    String? commuterId,
    String? commuterRequestId,
    String? routeId,
    String? routeName,
    String? dateRequested,
    String? routeLandmarkId,
    String? routeLandmarkName,
    String? associationId,
    String? dateNeeded,
    bool? scanned,
    Position? currentPosition,
    int? routePointIndex,
    int? numberOfPassengers,
    double? distanceToRouteLandmarkInMetres,
    double? distanceToRoutePointInMetres,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'commuterId', commuterId);
    RealmObjectBase.set(this, 'commuterRequestId', commuterRequestId);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'dateRequested', dateRequested);
    RealmObjectBase.set(this, 'routeLandmarkId', routeLandmarkId);
    RealmObjectBase.set(this, 'routeLandmarkName', routeLandmarkName);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'dateNeeded', dateNeeded);
    RealmObjectBase.set(this, 'scanned', scanned);
    RealmObjectBase.set(this, 'currentPosition', currentPosition);
    RealmObjectBase.set(this, 'routePointIndex', routePointIndex);
    RealmObjectBase.set(this, 'numberOfPassengers', numberOfPassengers);
    RealmObjectBase.set(this, 'distanceToRouteLandmarkInMetres',
        distanceToRouteLandmarkInMetres);
    RealmObjectBase.set(
        this, 'distanceToRoutePointInMetres', distanceToRoutePointInMetres);
  }

  CommuterRequest._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get commuterId =>
      RealmObjectBase.get<String>(this, 'commuterId') as String?;
  @override
  set commuterId(String? value) =>
      RealmObjectBase.set(this, 'commuterId', value);

  @override
  String? get commuterRequestId =>
      RealmObjectBase.get<String>(this, 'commuterRequestId') as String?;
  @override
  set commuterRequestId(String? value) =>
      RealmObjectBase.set(this, 'commuterRequestId', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get dateRequested =>
      RealmObjectBase.get<String>(this, 'dateRequested') as String?;
  @override
  set dateRequested(String? value) =>
      RealmObjectBase.set(this, 'dateRequested', value);

  @override
  String? get routeLandmarkId =>
      RealmObjectBase.get<String>(this, 'routeLandmarkId') as String?;
  @override
  set routeLandmarkId(String? value) =>
      RealmObjectBase.set(this, 'routeLandmarkId', value);

  @override
  String? get routeLandmarkName =>
      RealmObjectBase.get<String>(this, 'routeLandmarkName') as String?;
  @override
  set routeLandmarkName(String? value) =>
      RealmObjectBase.set(this, 'routeLandmarkName', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get dateNeeded =>
      RealmObjectBase.get<String>(this, 'dateNeeded') as String?;
  @override
  set dateNeeded(String? value) =>
      RealmObjectBase.set(this, 'dateNeeded', value);

  @override
  bool? get scanned => RealmObjectBase.get<bool>(this, 'scanned') as bool?;
  @override
  set scanned(bool? value) => RealmObjectBase.set(this, 'scanned', value);

  @override
  Position? get currentPosition =>
      RealmObjectBase.get<Position>(this, 'currentPosition') as Position?;
  @override
  set currentPosition(covariant Position? value) =>
      RealmObjectBase.set(this, 'currentPosition', value);

  @override
  int? get routePointIndex =>
      RealmObjectBase.get<int>(this, 'routePointIndex') as int?;
  @override
  set routePointIndex(int? value) =>
      RealmObjectBase.set(this, 'routePointIndex', value);

  @override
  int? get numberOfPassengers =>
      RealmObjectBase.get<int>(this, 'numberOfPassengers') as int?;
  @override
  set numberOfPassengers(int? value) =>
      RealmObjectBase.set(this, 'numberOfPassengers', value);

  @override
  double? get distanceToRouteLandmarkInMetres =>
      RealmObjectBase.get<double>(this, 'distanceToRouteLandmarkInMetres')
          as double?;
  @override
  set distanceToRouteLandmarkInMetres(double? value) =>
      RealmObjectBase.set(this, 'distanceToRouteLandmarkInMetres', value);

  @override
  double? get distanceToRoutePointInMetres =>
      RealmObjectBase.get<double>(this, 'distanceToRoutePointInMetres')
          as double?;
  @override
  set distanceToRoutePointInMetres(double? value) =>
      RealmObjectBase.set(this, 'distanceToRoutePointInMetres', value);

  @override
  Stream<RealmObjectChanges<CommuterRequest>> get changes =>
      RealmObjectBase.getChanges<CommuterRequest>(this);

  @override
  CommuterRequest freeze() =>
      RealmObjectBase.freezeObject<CommuterRequest>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CommuterRequest._);
    return const SchemaObject(
        ObjectType.realmObject, CommuterRequest, 'CommuterRequest', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('commuterId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('commuterRequestId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('dateRequested', RealmPropertyType.string, optional: true),
      SchemaProperty('routeLandmarkId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('routeLandmarkName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('dateNeeded', RealmPropertyType.string, optional: true),
      SchemaProperty('scanned', RealmPropertyType.bool, optional: true),
      SchemaProperty('currentPosition', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('routePointIndex', RealmPropertyType.int, optional: true),
      SchemaProperty('numberOfPassengers', RealmPropertyType.int,
          optional: true),
      SchemaProperty(
          'distanceToRouteLandmarkInMetres', RealmPropertyType.double,
          optional: true),
      SchemaProperty('distanceToRoutePointInMetres', RealmPropertyType.double,
          optional: true),
    ]);
  }
}

class Commuter extends _Commuter
    with RealmEntity, RealmObjectBase, RealmObject {
  Commuter(
    ObjectId id, {
    String? commuterId,
    String? name,
    String? gender,
    String? countryId,
    String? dateRegistered,
    String? qrCodeUrl,
    String? profileUrl,
    String? password,
    String? email,
    String? cellphone,
    String? profileThumbnailUrl,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'commuterId', commuterId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'dateRegistered', dateRegistered);
    RealmObjectBase.set(this, 'qrCodeUrl', qrCodeUrl);
    RealmObjectBase.set(this, 'profileUrl', profileUrl);
    RealmObjectBase.set(this, 'password', password);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'cellphone', cellphone);
    RealmObjectBase.set(this, 'profileThumbnailUrl', profileThumbnailUrl);
  }

  Commuter._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get commuterId =>
      RealmObjectBase.get<String>(this, 'commuterId') as String?;
  @override
  set commuterId(String? value) =>
      RealmObjectBase.set(this, 'commuterId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

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
  String? get dateRegistered =>
      RealmObjectBase.get<String>(this, 'dateRegistered') as String?;
  @override
  set dateRegistered(String? value) =>
      RealmObjectBase.set(this, 'dateRegistered', value);

  @override
  String? get qrCodeUrl =>
      RealmObjectBase.get<String>(this, 'qrCodeUrl') as String?;
  @override
  set qrCodeUrl(String? value) => RealmObjectBase.set(this, 'qrCodeUrl', value);

  @override
  String? get profileUrl =>
      RealmObjectBase.get<String>(this, 'profileUrl') as String?;
  @override
  set profileUrl(String? value) =>
      RealmObjectBase.set(this, 'profileUrl', value);

  @override
  String? get password =>
      RealmObjectBase.get<String>(this, 'password') as String?;
  @override
  set password(String? value) => RealmObjectBase.set(this, 'password', value);

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
  String? get profileThumbnailUrl =>
      RealmObjectBase.get<String>(this, 'profileThumbnailUrl') as String?;
  @override
  set profileThumbnailUrl(String? value) =>
      RealmObjectBase.set(this, 'profileThumbnailUrl', value);

  @override
  Stream<RealmObjectChanges<Commuter>> get changes =>
      RealmObjectBase.getChanges<Commuter>(this);

  @override
  Commuter freeze() => RealmObjectBase.freezeObject<Commuter>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Commuter._);
    return const SchemaObject(ObjectType.realmObject, Commuter, 'Commuter', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('commuterId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('gender', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('dateRegistered', RealmPropertyType.string,
          optional: true),
      SchemaProperty('qrCodeUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('profileUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('password', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('cellphone', RealmPropertyType.string, optional: true),
      SchemaProperty('profileThumbnailUrl', RealmPropertyType.string,
          optional: true),
    ]);
  }
}

class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
  User(
    ObjectId id, {
    String? userType,
    String? userId,
    String? firstName,
    String? lastName,
    String? gender,
    String? countryId,
    String? associationId,
    String? associationName,
    String? fcmToken,
    String? password,
    String? email,
    String? cellphone,
    String? thumbnailUrl,
    String? imageUrl,
  }) {
    RealmObjectBase.set(this, 'userType', userType);
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'firstName', firstName);
    RealmObjectBase.set(this, 'lastName', lastName);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'associationName', associationName);
    RealmObjectBase.set(this, 'fcmToken', fcmToken);
    RealmObjectBase.set(this, 'password', password);
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
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  String? get password =>
      RealmObjectBase.get<String>(this, 'password') as String?;
  @override
  set password(String? value) => RealmObjectBase.set(this, 'password', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('userId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('firstName', RealmPropertyType.string, optional: true),
      SchemaProperty('lastName', RealmPropertyType.string, optional: true),
      SchemaProperty('gender', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('associationName', RealmPropertyType.string,
          optional: true),
      SchemaProperty('fcmToken', RealmPropertyType.string, optional: true),
      SchemaProperty('password', RealmPropertyType.string, optional: true),
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
    String? routeName,
    String? routeId,
  }) {
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'routeId', routeId);
  }

  RouteInfo._();

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

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
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
    ]);
  }
}

class AmbassadorPassengerCount extends _AmbassadorPassengerCount
    with RealmEntity, RealmObjectBase, RealmObject {
  AmbassadorPassengerCount(
    ObjectId id, {
    String? vehicleId,
    String? vehicleReg,
    String? userId,
    String? userName,
    String? created,
    String? associationId,
    String? routeId,
    String? routeName,
    String? ownerId,
    String? ownerName,
    int? passengersIn,
    int? passengersOut,
    int? currentPassengers,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'ownerName', ownerName);
    RealmObjectBase.set(this, 'passengersIn', passengersIn);
    RealmObjectBase.set(this, 'passengersOut', passengersOut);
    RealmObjectBase.set(this, 'currentPassengers', currentPassengers);
    RealmObjectBase.set(this, 'position', position);
  }

  AmbassadorPassengerCount._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

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
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get ownerId =>
      RealmObjectBase.get<String>(this, 'ownerId') as String?;
  @override
  set ownerId(String? value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get ownerName =>
      RealmObjectBase.get<String>(this, 'ownerName') as String?;
  @override
  set ownerName(String? value) => RealmObjectBase.set(this, 'ownerName', value);

  @override
  int? get passengersIn =>
      RealmObjectBase.get<int>(this, 'passengersIn') as int?;
  @override
  set passengersIn(int? value) =>
      RealmObjectBase.set(this, 'passengersIn', value);

  @override
  int? get passengersOut =>
      RealmObjectBase.get<int>(this, 'passengersOut') as int?;
  @override
  set passengersOut(int? value) =>
      RealmObjectBase.set(this, 'passengersOut', value);

  @override
  int? get currentPassengers =>
      RealmObjectBase.get<int>(this, 'currentPassengers') as int?;
  @override
  set currentPassengers(int? value) =>
      RealmObjectBase.set(this, 'currentPassengers', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<AmbassadorPassengerCount>> get changes =>
      RealmObjectBase.getChanges<AmbassadorPassengerCount>(this);

  @override
  AmbassadorPassengerCount freeze() =>
      RealmObjectBase.freezeObject<AmbassadorPassengerCount>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AmbassadorPassengerCount._);
    return const SchemaObject(ObjectType.realmObject, AmbassadorPassengerCount,
        'AmbassadorPassengerCount', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('vehicleReg', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('routeId', RealmPropertyType.string, optional: true),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerName', RealmPropertyType.string, optional: true),
      SchemaProperty('passengersIn', RealmPropertyType.int, optional: true),
      SchemaProperty('passengersOut', RealmPropertyType.int, optional: true),
      SchemaProperty('currentPassengers', RealmPropertyType.int,
          optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class AmbassadorCheckIn extends _AmbassadorCheckIn
    with RealmEntity, RealmObjectBase, RealmObject {
  AmbassadorCheckIn(
    ObjectId id, {
    String? vehicleId,
    String? vehicleReg,
    String? userId,
    String? userName,
    String? created,
    String? associationId,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'position', position);
  }

  AmbassadorCheckIn._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

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
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<AmbassadorCheckIn>> get changes =>
      RealmObjectBase.getChanges<AmbassadorCheckIn>(this);

  @override
  AmbassadorCheckIn freeze() =>
      RealmObjectBase.freezeObject<AmbassadorCheckIn>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AmbassadorCheckIn._);
    return const SchemaObject(
        ObjectType.realmObject, AmbassadorCheckIn, 'AmbassadorCheckIn', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('vehicleReg', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class LocationRequest extends _LocationRequest
    with RealmEntity, RealmObjectBase, RealmObject {
  LocationRequest(
    ObjectId id, {
    String? vehicleId,
    String? vehicleReg,
    String? userId,
    String? userName,
    String? created,
    String? associationId,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
  }

  LocationRequest._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

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
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  Stream<RealmObjectChanges<LocationRequest>> get changes =>
      RealmObjectBase.getChanges<LocationRequest>(this);

  @override
  LocationRequest freeze() =>
      RealmObjectBase.freezeObject<LocationRequest>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(LocationRequest._);
    return const SchemaObject(
        ObjectType.realmObject, LocationRequest, 'LocationRequest', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('vehicleId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('vehicleReg', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('userId', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
    ]);
  }
}

class LocationResponse extends _LocationResponse
    with RealmEntity, RealmObjectBase, RealmObject {
  LocationResponse(
    ObjectId id, {
    String? userId,
    String? vehicleId,
    String? vehicleReg,
    String? geoHash,
    String? userName,
    String? created,
    String? associationId,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'vehicleId', vehicleId);
    RealmObjectBase.set(this, 'vehicleReg', vehicleReg);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set(this, 'userName', userName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'position', position);
  }

  LocationResponse._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'userId') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get vehicleId =>
      RealmObjectBase.get<String>(this, 'vehicleId') as String?;
  @override
  set vehicleId(String? value) => RealmObjectBase.set(this, 'vehicleId', value);

  @override
  String? get vehicleReg =>
      RealmObjectBase.get<String>(this, 'vehicleReg') as String?;
  @override
  set vehicleReg(String? value) =>
      RealmObjectBase.set(this, 'vehicleReg', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

  @override
  String? get userName =>
      RealmObjectBase.get<String>(this, 'userName') as String?;
  @override
  set userName(String? value) => RealmObjectBase.set(this, 'userName', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<LocationResponse>> get changes =>
      RealmObjectBase.getChanges<LocationResponse>(this);

  @override
  LocationResponse freeze() =>
      RealmObjectBase.freezeObject<LocationResponse>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(LocationResponse._);
    return const SchemaObject(
        ObjectType.realmObject, LocationResponse, 'LocationResponse', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('userId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('vehicleId', RealmPropertyType.string, optional: true),
      SchemaProperty('vehicleReg', RealmPropertyType.string, optional: true),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
      SchemaProperty('userName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class RouteLandmark extends _RouteLandmark
    with RealmEntity, RealmObjectBase, RealmObject {
  RouteLandmark(
    ObjectId id, {
    String? routeId,
    String? routeName,
    String? landmarkId,
    String? landmarkName,
    String? created,
    String? associationId,
    String? routePointId,
    int? routePointIndex,
    int? index,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'routePointId', routePointId);
    RealmObjectBase.set(this, 'routePointIndex', routePointIndex);
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'position', position);
  }

  RouteLandmark._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

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
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  String? get routePointId =>
      RealmObjectBase.get<String>(this, 'routePointId') as String?;
  @override
  set routePointId(String? value) =>
      RealmObjectBase.set(this, 'routePointId', value);

  @override
  int? get routePointIndex =>
      RealmObjectBase.get<int>(this, 'routePointIndex') as int?;
  @override
  set routePointIndex(int? value) =>
      RealmObjectBase.set(this, 'routePointIndex', value);

  @override
  int? get index => RealmObjectBase.get<int>(this, 'index') as int?;
  @override
  set index(int? value) => RealmObjectBase.set(this, 'index', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<RouteLandmark>> get changes =>
      RealmObjectBase.getChanges<RouteLandmark>(this);

  @override
  RouteLandmark freeze() => RealmObjectBase.freezeObject<RouteLandmark>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteLandmark._);
    return const SchemaObject(
        ObjectType.realmObject, RouteLandmark, 'RouteLandmark', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routeId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkId', RealmPropertyType.string, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('routePointId', RealmPropertyType.string, optional: true),
      SchemaProperty('routePointIndex', RealmPropertyType.int, optional: true),
      SchemaProperty('index', RealmPropertyType.int, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class RouteCity extends _RouteCity
    with RealmEntity, RealmObjectBase, RealmObject {
  RouteCity(
    ObjectId id, {
    String? routeId,
    String? routeName,
    String? cityId,
    String? cityName,
    String? created,
    String? associationId,
    Position? position,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'routeId', routeId);
    RealmObjectBase.set(this, 'routeName', routeName);
    RealmObjectBase.set(this, 'cityId', cityId);
    RealmObjectBase.set(this, 'cityName', cityName);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'position', position);
  }

  RouteCity._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get routeId =>
      RealmObjectBase.get<String>(this, 'routeId') as String?;
  @override
  set routeId(String? value) => RealmObjectBase.set(this, 'routeId', value);

  @override
  String? get routeName =>
      RealmObjectBase.get<String>(this, 'routeName') as String?;
  @override
  set routeName(String? value) => RealmObjectBase.set(this, 'routeName', value);

  @override
  String? get cityId => RealmObjectBase.get<String>(this, 'cityId') as String?;
  @override
  set cityId(String? value) => RealmObjectBase.set(this, 'cityId', value);

  @override
  String? get cityName =>
      RealmObjectBase.get<String>(this, 'cityName') as String?;
  @override
  set cityName(String? value) => RealmObjectBase.set(this, 'cityName', value);

  @override
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

  @override
  String? get associationId =>
      RealmObjectBase.get<String>(this, 'associationId') as String?;
  @override
  set associationId(String? value) =>
      RealmObjectBase.set(this, 'associationId', value);

  @override
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  Stream<RealmObjectChanges<RouteCity>> get changes =>
      RealmObjectBase.getChanges<RouteCity>(this);

  @override
  RouteCity freeze() => RealmObjectBase.freezeObject<RouteCity>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteCity._);
    return const SchemaObject(ObjectType.realmObject, RouteCity, 'RouteCity', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('routeId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('routeName', RealmPropertyType.string, optional: true),
      SchemaProperty('cityId', RealmPropertyType.string, optional: true),
      SchemaProperty('cityName', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('associationId', RealmPropertyType.string, optional: true),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}

class StateProvince extends _StateProvince
    with RealmEntity, RealmObjectBase, RealmObject {
  StateProvince(
    ObjectId id, {
    String? stateId,
    String? name,
    String? countryId,
    String? countryName,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'stateId', stateId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'countryId', countryId);
    RealmObjectBase.set(this, 'countryName', countryName);
  }

  StateProvince._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get stateId =>
      RealmObjectBase.get<String>(this, 'stateId') as String?;
  @override
  set stateId(String? value) => RealmObjectBase.set(this, 'stateId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

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
  Stream<RealmObjectChanges<StateProvince>> get changes =>
      RealmObjectBase.getChanges<StateProvince>(this);

  @override
  StateProvince freeze() => RealmObjectBase.freezeObject<StateProvince>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(StateProvince._);
    return const SchemaObject(
        ObjectType.realmObject, StateProvince, 'StateProvince', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('stateId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('countryId', RealmPropertyType.string, optional: true),
      SchemaProperty('countryName', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Landmark extends _Landmark
    with RealmEntity, RealmObjectBase, RealmObject {
  Landmark(
    ObjectId id, {
    String? landmarkId,
    double? latitude,
    double? longitude,
    double? distance,
    String? landmarkName,
    Position? position,
    String? geoHash,
    Iterable<RouteInfo> routeDetails = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'landmarkId', landmarkId);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'distance', distance);
    RealmObjectBase.set(this, 'landmarkName', landmarkName);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'geoHash', geoHash);
    RealmObjectBase.set<RealmList<RouteInfo>>(
        this, 'routeDetails', RealmList<RouteInfo>(routeDetails));
  }

  Landmark._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get landmarkId =>
      RealmObjectBase.get<String>(this, 'landmarkId') as String?;
  @override
  set landmarkId(String? value) =>
      RealmObjectBase.set(this, 'landmarkId', value);

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
  Position? get position =>
      RealmObjectBase.get<Position>(this, 'position') as Position?;
  @override
  set position(covariant Position? value) =>
      RealmObjectBase.set(this, 'position', value);

  @override
  String? get geoHash =>
      RealmObjectBase.get<String>(this, 'geoHash') as String?;
  @override
  set geoHash(String? value) => RealmObjectBase.set(this, 'geoHash', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('landmarkId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty('distance', RealmPropertyType.double, optional: true),
      SchemaProperty('landmarkName', RealmPropertyType.string, optional: true),
      SchemaProperty('routeDetails', RealmPropertyType.object,
          linkTarget: 'RouteInfo', collectionType: RealmCollectionType.list),
      SchemaProperty('position', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('geoHash', RealmPropertyType.string, optional: true),
    ]);
  }
}

class SettingsModel extends _SettingsModel
    with RealmEntity, RealmObjectBase, RealmObject {
  SettingsModel(
    ObjectId id, {
    String? associationId,
    String? locale,
    String? created,
    int? refreshRateInSeconds,
    int? themeIndex,
    int? geofenceRadius,
    int? commuterGeofenceRadius,
    int? vehicleSearchMinutes,
    int? heartbeatIntervalSeconds,
    int? loiteringDelay,
    int? commuterSearchMinutes,
    int? commuterGeoQueryRadius,
    int? vehicleGeoQueryRadius,
    int? numberOfLandmarksToScan,
    int? distanceFilter,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'associationId', associationId);
    RealmObjectBase.set(this, 'locale', locale);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'refreshRateInSeconds', refreshRateInSeconds);
    RealmObjectBase.set(this, 'themeIndex', themeIndex);
    RealmObjectBase.set(this, 'geofenceRadius', geofenceRadius);
    RealmObjectBase.set(this, 'commuterGeofenceRadius', commuterGeofenceRadius);
    RealmObjectBase.set(this, 'vehicleSearchMinutes', vehicleSearchMinutes);
    RealmObjectBase.set(
        this, 'heartbeatIntervalSeconds', heartbeatIntervalSeconds);
    RealmObjectBase.set(this, 'loiteringDelay', loiteringDelay);
    RealmObjectBase.set(this, 'commuterSearchMinutes', commuterSearchMinutes);
    RealmObjectBase.set(this, 'commuterGeoQueryRadius', commuterGeoQueryRadius);
    RealmObjectBase.set(this, 'vehicleGeoQueryRadius', vehicleGeoQueryRadius);
    RealmObjectBase.set(
        this, 'numberOfLandmarksToScan', numberOfLandmarksToScan);
    RealmObjectBase.set(this, 'distanceFilter', distanceFilter);
  }

  SettingsModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

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
  String? get created =>
      RealmObjectBase.get<String>(this, 'created') as String?;
  @override
  set created(String? value) => RealmObjectBase.set(this, 'created', value);

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
  int? get geofenceRadius =>
      RealmObjectBase.get<int>(this, 'geofenceRadius') as int?;
  @override
  set geofenceRadius(int? value) =>
      RealmObjectBase.set(this, 'geofenceRadius', value);

  @override
  int? get commuterGeofenceRadius =>
      RealmObjectBase.get<int>(this, 'commuterGeofenceRadius') as int?;
  @override
  set commuterGeofenceRadius(int? value) =>
      RealmObjectBase.set(this, 'commuterGeofenceRadius', value);

  @override
  int? get vehicleSearchMinutes =>
      RealmObjectBase.get<int>(this, 'vehicleSearchMinutes') as int?;
  @override
  set vehicleSearchMinutes(int? value) =>
      RealmObjectBase.set(this, 'vehicleSearchMinutes', value);

  @override
  int? get heartbeatIntervalSeconds =>
      RealmObjectBase.get<int>(this, 'heartbeatIntervalSeconds') as int?;
  @override
  set heartbeatIntervalSeconds(int? value) =>
      RealmObjectBase.set(this, 'heartbeatIntervalSeconds', value);

  @override
  int? get loiteringDelay =>
      RealmObjectBase.get<int>(this, 'loiteringDelay') as int?;
  @override
  set loiteringDelay(int? value) =>
      RealmObjectBase.set(this, 'loiteringDelay', value);

  @override
  int? get commuterSearchMinutes =>
      RealmObjectBase.get<int>(this, 'commuterSearchMinutes') as int?;
  @override
  set commuterSearchMinutes(int? value) =>
      RealmObjectBase.set(this, 'commuterSearchMinutes', value);

  @override
  int? get commuterGeoQueryRadius =>
      RealmObjectBase.get<int>(this, 'commuterGeoQueryRadius') as int?;
  @override
  set commuterGeoQueryRadius(int? value) =>
      RealmObjectBase.set(this, 'commuterGeoQueryRadius', value);

  @override
  int? get vehicleGeoQueryRadius =>
      RealmObjectBase.get<int>(this, 'vehicleGeoQueryRadius') as int?;
  @override
  set vehicleGeoQueryRadius(int? value) =>
      RealmObjectBase.set(this, 'vehicleGeoQueryRadius', value);

  @override
  int? get numberOfLandmarksToScan =>
      RealmObjectBase.get<int>(this, 'numberOfLandmarksToScan') as int?;
  @override
  set numberOfLandmarksToScan(int? value) =>
      RealmObjectBase.set(this, 'numberOfLandmarksToScan', value);

  @override
  int? get distanceFilter =>
      RealmObjectBase.get<int>(this, 'distanceFilter') as int?;
  @override
  set distanceFilter(int? value) =>
      RealmObjectBase.set(this, 'distanceFilter', value);

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
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('associationId', RealmPropertyType.string,
          optional: true, indexType: RealmIndexType.regular),
      SchemaProperty('locale', RealmPropertyType.string, optional: true),
      SchemaProperty('created', RealmPropertyType.string, optional: true),
      SchemaProperty('refreshRateInSeconds', RealmPropertyType.int,
          optional: true),
      SchemaProperty('themeIndex', RealmPropertyType.int, optional: true),
      SchemaProperty('geofenceRadius', RealmPropertyType.int, optional: true),
      SchemaProperty('commuterGeofenceRadius', RealmPropertyType.int,
          optional: true),
      SchemaProperty('vehicleSearchMinutes', RealmPropertyType.int,
          optional: true),
      SchemaProperty('heartbeatIntervalSeconds', RealmPropertyType.int,
          optional: true),
      SchemaProperty('loiteringDelay', RealmPropertyType.int, optional: true),
      SchemaProperty('commuterSearchMinutes', RealmPropertyType.int,
          optional: true),
      SchemaProperty('commuterGeoQueryRadius', RealmPropertyType.int,
          optional: true),
      SchemaProperty('vehicleGeoQueryRadius', RealmPropertyType.int,
          optional: true),
      SchemaProperty('numberOfLandmarksToScan', RealmPropertyType.int,
          optional: true),
      SchemaProperty('distanceFilter', RealmPropertyType.int, optional: true),
    ]);
  }
}

class RouteStartEnd extends _RouteStartEnd
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RouteStartEnd({
    String? startCityId,
    String? startCityName,
    String? endCityId,
    String? endCityName,
    Position? startCityPosition,
    Position? endCityPosition,
  }) {
    RealmObjectBase.set(this, 'startCityId', startCityId);
    RealmObjectBase.set(this, 'startCityName', startCityName);
    RealmObjectBase.set(this, 'endCityId', endCityId);
    RealmObjectBase.set(this, 'endCityName', endCityName);
    RealmObjectBase.set(this, 'startCityPosition', startCityPosition);
    RealmObjectBase.set(this, 'endCityPosition', endCityPosition);
  }

  RouteStartEnd._();

  @override
  String? get startCityId =>
      RealmObjectBase.get<String>(this, 'startCityId') as String?;
  @override
  set startCityId(String? value) =>
      RealmObjectBase.set(this, 'startCityId', value);

  @override
  String? get startCityName =>
      RealmObjectBase.get<String>(this, 'startCityName') as String?;
  @override
  set startCityName(String? value) =>
      RealmObjectBase.set(this, 'startCityName', value);

  @override
  String? get endCityId =>
      RealmObjectBase.get<String>(this, 'endCityId') as String?;
  @override
  set endCityId(String? value) => RealmObjectBase.set(this, 'endCityId', value);

  @override
  String? get endCityName =>
      RealmObjectBase.get<String>(this, 'endCityName') as String?;
  @override
  set endCityName(String? value) =>
      RealmObjectBase.set(this, 'endCityName', value);

  @override
  Position? get startCityPosition =>
      RealmObjectBase.get<Position>(this, 'startCityPosition') as Position?;
  @override
  set startCityPosition(covariant Position? value) =>
      RealmObjectBase.set(this, 'startCityPosition', value);

  @override
  Position? get endCityPosition =>
      RealmObjectBase.get<Position>(this, 'endCityPosition') as Position?;
  @override
  set endCityPosition(covariant Position? value) =>
      RealmObjectBase.set(this, 'endCityPosition', value);

  @override
  Stream<RealmObjectChanges<RouteStartEnd>> get changes =>
      RealmObjectBase.getChanges<RouteStartEnd>(this);

  @override
  RouteStartEnd freeze() => RealmObjectBase.freezeObject<RouteStartEnd>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RouteStartEnd._);
    return const SchemaObject(
        ObjectType.embeddedObject, RouteStartEnd, 'RouteStartEnd', [
      SchemaProperty('startCityId', RealmPropertyType.string, optional: true),
      SchemaProperty('startCityName', RealmPropertyType.string, optional: true),
      SchemaProperty('endCityId', RealmPropertyType.string, optional: true),
      SchemaProperty('endCityName', RealmPropertyType.string, optional: true),
      SchemaProperty('startCityPosition', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
      SchemaProperty('endCityPosition', RealmPropertyType.object,
          optional: true, linkTarget: 'Position'),
    ]);
  }
}
