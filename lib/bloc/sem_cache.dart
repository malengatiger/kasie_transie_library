import 'package:flutter/foundation.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:sembast/sembast_io.dart' as sp;
import 'package:sembast_web/sembast_web.dart' as sw;
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../data/route_data.dart';
import '../utils/functions.dart'; // Import the path package

class SemCache {
  late sp.Database dbPhone;
  late sw.Database dbWeb;
  static String dbPath = 'kasie.db';

  SemCache() {
    initializeDatabase();
  }

  static const mm = '👽👽👽 SemCache 👽👽👽';

  void initializeDatabase() async {
    pp('\n\n$mm initialize 🔵️ Local Database 🔵️: set up for platform ...');
    if (kIsWeb) {
      sw.DatabaseFactory dbFactoryWeb = sw.databaseFactoryWeb;
      dbWeb = await dbFactoryWeb.openDatabase(dbPath);
      // pp('$mm cache database set up for web. (1)');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dPath = p.join(dir.path, dbPath);
      dbPhone = await sp.databaseFactoryIo.openDatabase(dPath);
      // pp('$mm cache database set up for phone');
    }
  }

  //
  Future getDb() async {
    if (kIsWeb) {
      sw.DatabaseFactory dbFactoryWeb = sw.databaseFactoryWeb;
      dbWeb = await dbFactoryWeb.openDatabase(dbPath);
      return dbWeb;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dPath = p.join(dir.path, dbPath);
      dbPhone = await sp.databaseFactoryIo.openDatabase(dPath);

      return dbPhone;
    }
  }

  int dateToInt(String date) {
    final DateTime dt = DateTime.parse(date);
    return dt.microsecondsSinceEpoch;
  }

  int stringToInt(String str) {
    int hash = 5381;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) + hash) + str.codeUnitAt(i);
    }
    return hash;
  }

  Future saveRegistrationBag(RegistrationBag bag) async {
    pp('$mm ... saveRegistrationBag ...');

    var store = intMapStoreFactory.store('bag');
    var records = await store.record(1).put(await getDb(), bag.toJson());
  }

  Future<RegistrationBag?> getRegistrationBag() async {
    pp('$mm ... getRegistrationBag ....');

    var store = intMapStoreFactory.store('bag');
    var records = await store.find(await getDb());
    if (records.isNotEmpty) {
      var bag = RegistrationBag.fromJson(records.first.value);
      return bag;
    }
    return null;
  }

  Future<City?> getCity(String cityId) async {
    pp('$mm .... getCity: $cityId');

    var store = intMapStoreFactory.store('cities');
    var finder = Finder(filter: Filter.equals('cityId', cityId));
    var records = await store.find(await getDb(), finder: finder);

    List<City> cities = [];
    for (var rec in records) {
      var city = City.fromJson(rec.value);
      cities.add(city);
    }
    pp('$mm cities retrieved from cache: ${cities.length}');
    if (cities.isNotEmpty) {
      return cities[0];
    }
    return null;
  }

  Future<int> countRouteCities(String associationId) async {
    var store = intMapStoreFactory.store('routeCities');
    int count = 0;

    var r = await getAssociationRouteData(associationId);
    for (var value in r!.routeDataList) {
      count += value.cities.length;
    }
    pp('$mm countRouteCities: 🥦 $count route cities');
    return count;
  }

  Future<int> countRoutePoints(String associationId) async {
    pp('\n$mm countRoutePoints: associationId: 🥦 $associationId 🥦');
    int count = 0;
    var routeData = await getAssociationRouteData(associationId);
    if (routeData != null) {
      for (var d in routeData.routeDataList) {
        count += d.routePoints.length;
      }
    }
    pp('\n$mm countRoutePoints: TOTAL: 🥦 $count 🥦 route points\n');
    return count;
  }

  Future<int> countRouteLandmarks(String associationId) async {
    int count = 0;
    var routeData = await getAssociationRouteData(associationId);
    if (routeData != null) {
      for (var rd in routeData.routeDataList) {
        count += rd.landmarks.length;
      }
    }
    pp('\n$mm countRouteLandmarks: TOTAL: 🌸🌸 $count route landmarks');

    return count;
  }

  Future saveUsers(List<User> users) async {
    var store = intMapStoreFactory.store('users');

    for (var user in users) {
      store
          .record(dateToInt(user.created ?? DateTime.now().toIso8601String()))
          .put(await getDb(), user.toJson());
      // sleep(const Duration(milliseconds: 5));
    }

    pp('$mm users added to cache: 🥦 ${users.length} 🥦');
  }

  Future saveCommuterRoute(Route route) async {
    var store = intMapStoreFactory.store('commuterRoutes');

      store
          .record(dateToInt(route.created ?? DateTime.now().toIso8601String()))
          .put(await getDb(), route.toJson());


    pp('$mm commuterRoute added to cache: 🥦 ${route.name} 🥦');
  }
  Future<List<Route>> getCommuterRoutes() async {
    var store = intMapStoreFactory.store('commuterRoutes');
    var records = await store.find(await getDb());

    List<Route> routes = [];
    for (var rec in records) {
      var route = Route.fromJson(rec.value);
      routes.add(route);
    }
    pp('$mm commuter routes retrieved from cache: ${routes.length}');
    return routes;

  }

  //
  Future saveRouteCities(List<RouteCity> routeCities) async {
    var store = intMapStoreFactory.store('routeCities');
    for (var routeCity in routeCities) {
      store
          .record(dateToInt(routeCity.created!))
          .put(await getDb(), routeCity.toJson());
    }
    pp('$mm routeCities added to cache: 🖐🏾 ${routeCities.length} 🖐🏾');
  }

  Future<List<RouteCity>> getRouteCities(String routeId) async {
    var store = intMapStoreFactory.store('routeCities');
    var finder = Finder(filter: Filter.equals('routeId', routeId));
    var records = await store.find(await getDb(), finder: finder);

    List<RouteCity> routeCities = [];
    for (var rec in records) {
      var routePoint = RouteCity.fromJson(rec.value);
      routeCities.add(routePoint);
    }
    pp('$mm routeCities retrieved from cache: ${routeCities.length}');
    return routeCities;
  }

  //
  Future saveVehicles(List<Vehicle> vehicles) async {
    var db = await getDb();
    var store = intMapStoreFactory.store('vehicles');
    for (var car in vehicles) {
      store.record(dateToInt(car.created!)).put(db, car.toJson());
    }
    pp('\n\n$mm cars added to cache: 🚘 🚖 ${vehicles.length} 🚘 🚖');
  }

  Future<List<Vehicle>> getVehicles(String associationId) async {
    sp.Finder finder;
    if (kIsWeb) {
      finder =
          sw.Finder(filter: sw.Filter.equals('associationId', associationId));
    } else {
      finder =
          sp.Finder(filter: sp.Filter.equals('associationId', associationId));
    }
    var store = intMapStoreFactory.store('vehicles');
    var records = await store.find(await getDb(), finder: finder);
    pp('$mm ... getVehicles: looking for cars cars found: $associationId');

    List<Vehicle> vehicles = [];
    for (var rec in records) {
      var vehicle = Vehicle.fromJson(rec.value);
      vehicles.add(vehicle);
    }
    pp('$mm vehicles retrieved from cache: ${vehicles.length}');
    return vehicles;
  }

  //
  Future saveFuelBrands(List<FuelBrand> fuelBrands) async {
    var db = await getDb();
    var store = intMapStoreFactory.store('fuelBrands');
    for (var brand in fuelBrands) {
      store.record(DateTime.now().microsecondsSinceEpoch).put(db, brand.toJson());
    }
    pp('\n\n$mm fuelBrands added to cache: 🚘 🚖 ${fuelBrands.length} 🚘 🚖');
  }

  Future<List<FuelBrand>> getFuelBrands() async {
    sp.Finder finder;

    var store = intMapStoreFactory.store('fuelBrands');
    var records = await store.find(await getDb(),);
    pp('$mm ... getFuelBrands: found: ${records.length}');

    List<FuelBrand> brands = [];
    for (var rec in records) {
      var brand = FuelBrand.fromJson(rec.value);
      brands.add(brand);
    }
    pp('$mm brands retrieved from cache: ${brands.length}');
    return brands;
  }

  Future<Vehicle?> getVehicle(String associationId, String vehicleId) async {

    List<Vehicle> vehicles = await getVehicles(associationId);
    for (var veh in vehicles) {
      if (veh.vehicleId == vehicleId) {
        return veh;
      }
    }
    return null;
  }

  //
  Future saveCities(List<City> cities) async {
    var store = intMapStoreFactory.store('cities');
    for (var city in cities) {
      store
          .record(dateToInt(city.created ?? DateTime.now().toIso8601String()))
          .put(await getDb(), city.toJson());
    }
    pp('$mm cities added to cache: ☎️ ${cities.length} ☎️ ');
  }

  Future<List<City>> getCities() async {
    var store = intMapStoreFactory.store('cities');
    var records = await store.find(await getDb());

    List<City> cities = [];
    for (var rec in records) {
      var city = City.fromJson(rec.value);
      cities.add(city);
    }
    pp('$mm cities retrieved from cache: ${cities.length}');
    return cities;
  }

  Future saveAssociations(List<Association> associations) async {
    var store = intMapStoreFactory.store('associations');
    store.delete(await getDb());
    for (var ass in associations) {
      var key = dateToInt(ass.dateRegistered!);
      store.record(key).put(await getDb(), ass.toJson());
      pp('$mm 🖐🏾🖐🏾$key 🖐🏾 ${ass.associationName}');
    }
    pp('$mm associations added to cache: 🎽 ${associations.length} 🎽');
  }

  Future<List<Association>> getAssociations() async {
    var store = intMapStoreFactory.store('associations');
    var records = await store.find(await getDb());

    List<Association> asses = [];
    for (var rec in records) {
      var ass = Association.fromJson(rec.value);
      asses.add(ass);
    }
    pp('$mm asses retrieved from cache: ${asses.length}');
    return asses;
  }

//
  Future saveAssociationRouteData(AssociationRouteData data) async {
    var store = intMapStoreFactory.store('routeData');
    store
        .record(stringToInt(data.associationId!))
        .put(await getDb(), data.toJson());

    pp('$mm RouteData assoc added to cache: ☎️ ${data.associationId} ☎️ ');
    pp('$mm routes added to cache: ☎️ ${data.routeDataList.length} ☎️ ');
  }
  Future saveSingleRouteData(AssociationRouteData data) async {

    var assRouteData = await getAssociationRouteData(data.associationId!);
   if (assRouteData != null) {
     List<RouteData> list = [];
     for (var rd in assRouteData.routeDataList) {
       if (rd.routeId == data.routeDataList.first.routeId) {
          list.add(data.routeDataList.first);
       } else {
         list.add(rd);
       }
     }
     assRouteData.routeDataList = list;
   }
    var store = intMapStoreFactory.store('routeData');
    store
        .record(stringToInt(data.associationId!))
        .put(await getDb(), assRouteData!.toJson());

    pp('$mm Association RouteData updatted with single route on cache: ☎️ ${data.associationId} ☎️ ');
    pp('$mm routes in cache: ☎️ ${assRouteData.routeDataList.length} ☎️ ');
  }

  Future<AssociationRouteData?> getAssociationRouteData(
      String associationId) async {
    var store = intMapStoreFactory.store('routeData');
    sw.Finder finder = sw.Finder(
        filter: sw.Filter.equals('associationId', associationId), limit: 1);
    var records = await store.find(await getDb());

    if (records.isNotEmpty) {
      var mData = records[0].value;
      var assocRouteData = AssociationRouteData.fromJson(mData);
      pp('$mm association routes found in cache: ${assocRouteData.routeDataList.length}');
      return assocRouteData;
    }
    pp('$mm association route data not found in cache 😈😈😈😈');
    return null;
  }
  Future<RouteData?> getRouteDataByRoute(
      String associationId, String routeId) async {
    var store = intMapStoreFactory.store('routeData');
    sw.Finder finder = sw.Finder(
        filter: sw.Filter.equals('associationId', associationId), limit: 1);
    var records = await store.find(await getDb());

    if (records.isNotEmpty) {
      for (var rec in records) {
        var mData = rec.value;
        var assocRouteData = AssociationRouteData.fromJson(mData);
        for (var rd in assocRouteData.routeDataList) {
          if (rd.routeId == routeId) {
            return rd;
          }
        }
      }
    }
    pp('$mm association route data not found in cache 😈😈😈😈');
    return null;
  }

  Future<RouteData?> getRouteData(
      {required String associationId, required String routeId}) async {
    var assocRouteData = await getAssociationRouteData(associationId);
    RouteData? routeData;
    if (assocRouteData != null) {
      for (var rd in assocRouteData.routeDataList) {
        if (rd.routeId == routeId) {
          routeData = rd;
          pp('\n\n$mm route  found in cache, ${rd.route?.name}');
          pp('$mm route landmarks found in cache, ${rd.landmarks.length}');
          pp('$mm route points found in cache, ${rd.routePoints.length}');
          pp('$mm route cities found in cache, ${rd.cities.length}\n\n');
        }
      }
    }
    pp('$mm route data not found in cache 😈😈😈😈');
    return routeData;
  }

  Future saveRoutePoints(
      {required String associationId,
      required List<RoutePoint> routePoints,
      required String routeId}) async {
    var ard = await getAssociationRouteData(associationId);
    if (ard != null) {
      pp('$mm route data has been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        if (rd.routeId == routeId) {
          rd.routePoints.addAll(routePoints);
          await saveAssociationRouteData(ard);
          pp('$mm route points added to cache ');
          return;
        }
      }
    }
  }

  Future saveRouteLandmarks(
      {required List<RouteLandmark> landmarks,
      required String associationId,
      required String routeId}) async {
    var ard = await getAssociationRouteData(associationId);
    if (ard != null) {
      pp('$mm route data has been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        if (rd.routeId == routeId) {
          rd.landmarks.addAll(landmarks);
          await saveAssociationRouteData(ard);
          pp('$mm route landmarks added to cache ');
          return;
        }
      }
    }
  }

  Future saveRoute({required Route route}) async {
    var ard = await getAssociationRouteData(route.associationId!);
    RouteData? routeData;
    if (ard != null) {
      pp('$mm route data has been found in cache, Yebo!!');
      RouteData rd = RouteData(
          routeId: route.routeId!,
          route: route,
          routePoints: [],
          landmarks: [],
          cities: []);
      ard.routeDataList.add(rd);
      await saveAssociationRouteData(ard);
    }
    pp('$mm route added to cache');
  }

  Future<List<Route>> getRoutes({required String associationId}) async {
    List<Route> list = [];
    var ard = await getAssociationRouteData(associationId);
    RouteData? routeData;
    if (ard != null) {
      pp('$mm routes have been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        list.add(rd.route!);
      }
    }
    list.sort((a, b) => a.name!.compareTo(b.name!));
    return list;
  }

  Future<List<RouteLandmark>> getRouteLandmarks(
      {required String associationId, required routeId}) async {
    List<RouteLandmark> list = [];
    var ard = await getAssociationRouteData(associationId);
    if (ard != null) {
      pp('$mm routes have been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        if (rd.routeId == routeId) {
          list = rd.landmarks;
        }
      }
    }
    list.sort((a, b) => a.index!.compareTo(b.index!));
    return list;
  }

  Future<List<RoutePoint>> getRoutePoints(
      String routeId, String associationId) async {
    List<RoutePoint> list = [];
    var ard = await getAssociationRouteData(associationId);
    if (ard != null) {
      pp('$mm routes have been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        if (rd.routeId == routeId) {
          list = rd.routePoints;
        }
      }
    }

    return list;
  }

  Future<Route?> getRoute(String routeId, String associationId) async {
    Route? route;
    var ard = await getAssociationRouteData(associationId);
    if (ard != null) {
      pp('$mm routes have been found in cache, Yebo!!');
      for (var rd in ard.routeDataList) {
        if (rd.routeId == routeId) {
          route = rd.route;
        }
      }
    }

    return route;
  }

  Future saveSingleRoute(Route route) async {
    pp('$mm ... saveSingleRoute ...');
    var store = intMapStoreFactory.store('singleRoutes');
    var records = await store.record(1).put(await getDb(), route.toJson());
    pp('$mm ... saveSingleRoute: route: ${route.name}  added to cache...');
  }

  Future<List<Route>> getSingleRoutes() async {
    var store = intMapStoreFactory.store('singleRoutes');
    var records = await store.find(await getDb());
    List<Route> routes = [];
    for (var rec in records) {
      var route = Route.fromJson(rec.value);
      routes.add(route);
    }
    pp('$mm single routes retrieved from cache: ${routes.length}');
    return routes;
  }
  Future<Route?> getSingleRouteById(String routeId) async {
    var store = intMapStoreFactory.store('singleRoutes');
    var records = await store.find(await getDb());
    for (var rec in records) {
      var route = Route.fromJson(rec.value);
     if (routeId == route.routeId) {
       return route;
     }
    }
    return null;
  }
}
