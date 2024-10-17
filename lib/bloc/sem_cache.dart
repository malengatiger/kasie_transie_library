import 'package:flutter/foundation.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:sembast/sembast_io.dart' as sp;
import 'package:sembast_web/sembast_web.dart' as sw;
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import '../data/route_bag.dart';
import 'package:path/path.dart' as p;

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
      pp('$mm cache database set up for web');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dPath = p.join(dir.path, dbPath);
      dbPhone = await sp.databaseFactoryIo.openDatabase(dPath);
      pp('$mm cache database set up for phone');
    }
  }
  //
  Future getDb() async {
    if (kIsWeb) {
      return dbWeb;
    } else {
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
    var records
    = await store.record(1).put(await getDb(), bag.toJson());
  }
  Future<RegistrationBag?> getRegistrationBag() async {
    pp('$mm ... getRegistrationBag ....');

    var store = intMapStoreFactory.store('bag');
    var records
    = await store.find(await getDb());
    if (records.isNotEmpty) {
      var bag = RegistrationBag.fromJson( records.first.value);
      return bag;
    }
    return null;
  }

  Future<List<Route>> saveRoutes(List<Route> routes, String associationId) async {
    pp('$mm ... saveRoutes: 🥬🥬 ${routes.length} associationId: $associationId');

    var data = await getRouteData(associationId);
    if (data != null) {
      pp('$mm routes added to cache: 🥬🥬 ${routes.length}');
      data.routes.addAll(routes);
      return data.routes;
    }
    return routes;
  }

  Future<List<Route>> getRoutes(String associationId) async {

    var data = await getRouteData(associationId);
    List<Route> routes = [];

    if (data != null) {
      routes = data.routes;
    }

    routes.sort((a,b) => a.name!.compareTo(b.name!));
    pp('$mm routes retrieved from cache: 😡 ${routes.length} ');
    return routes;
  }

  Future<Route?> getRoute(String routeId, String associationId) async {
    pp('$mm .... getRoute: $routeId');

    var data = await getRouteData(associationId);
    if (data != null) {
      List<Route> routes = data.routes;
      for (var route in routes) {
        if (route.routeId! == routeId) {
          pp('$mm routes retrieved from cache: ${route.name}');
          return route;
        }
      }
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

    var r = await getRoutes(associationId);
    for (var value in r) {
      var finder = Finder(filter: Filter.equals('routeId', value.routeId));
      var list = await store.find(await getDb(), finder: finder);
      count += list.length;
    }
    pp('$mm countRouteCities: 🥦 $count route cities');
    return count;
  }

  Future saveRoutePoints(
      List<RoutePoint> routePoints, String associationId) async {
    var store = intMapStoreFactory.store('routePoints');
    for (var routePoint in routePoints) {
      store.record(dateToInt(routePoint.created!)).put(await getDb(), routePoint.toJson());
    }
    var data = await getRouteData(associationId);
    if (data != null) {
      data.routePoints.addAll(routePoints);
    }
    pp('$mm routePoints added to cache: 🌀🌀${routePoints.length} 🌀🌀');
  }

  Future deleteRoutePoints(String routeId) async {
    var store = intMapStoreFactory.store('routePoints');
    var finder = Finder(filter: Filter.equals('routeId', routeId));

    var deleted = await store.delete(await getDb(), finder: finder);
    pp('$mm routePoints deleted from cache: 🦠$deleted 🦠 routeId: $routeId');
  }

  Future<int> countRoutePoints(String associationId) async {
    pp('\n$mm countRoutePoints: associationId: 🥦 $associationId 🥦');
    int count = 0;
    var routeData = await getRouteData(associationId);
    if (routeData != null) {
      count = routeData.routePoints.length;
    }
    pp('\n$mm countRoutePoints: TOTAL: 🥦 $count 🥦 route points\n');
    return count;
  }

  Future<int> countRouteLandmarks(String associationId) async {
    int count = 0;
    var routeData = await getRouteData(associationId);
    if (routeData != null) {
      count = routeData.landmarks.length;
    }
    pp('\n$mm countRouteLandmarks: TOTAL: 🌸🌸 $count route landmarks');

    return count;
  }

  Future<List<RoutePoint>> getRoutePoints(
      String routeId, String associationId) async {
    var data = await getRouteData(associationId);

    List<RoutePoint> routePoints = [];
    if (data != null) {
      for (var rec in data.routePoints) {
        if (rec.routeId == routeId) {
          routePoints.add(rec);
        }
      }
    }
    routePoints.sort((a,b) => a.index!.compareTo(b.index!));
    pp('$mm routePoints retrieved from cache: 🥦 ${routePoints.length} route: $routeId');
    return routePoints;
  }

  Future saveRouteLandmarks(
      List<RouteLandmark> routeLandmarks, String associationId) async {
    var store = intMapStoreFactory.store('routeLandmarks');

    for (var routeLandmark in routeLandmarks) {
      store
          .record(dateToInt(routeLandmark.created!))
          .put(await getDb(), routeLandmark.toJson());
    }
    var data = await getRouteData(associationId);
    if (data != null) {
      data.landmarks.addAll(routeLandmarks);
    }
    pp('$mm routeLandmarks added to cache: 🥦 ${routeLandmarks.length} 🥦');
  }

  Future saveUsers(
      List<User> users) async {
    var store = intMapStoreFactory.store('users');

    for (var user in users) {
      store
          .record(dateToInt(user.created?? DateTime.now().toIso8601String()))
          .put(await getDb(), user.toJson());
      // sleep(const Duration(milliseconds: 5));
    }

    pp('$mm users added to cache: 🥦 ${users.length} 🥦');
  }

  Future<List<RouteLandmark>> getRouteLandmarks(String routeId, String associationId) async {
    var data = await getRouteData(associationId);

    List<RouteLandmark> routeLandmarks = [];
    if (data != null) {
      for (var rec in data.landmarks) {
        if (rec.routeId == routeId) {
          routeLandmarks.add(rec);
        }
      }
    }
    routeLandmarks.sort((a,b) => a.index!.compareTo(b.index!));
    pp('$mm routeLandmarks retrieved from cache: 😡 ${routeLandmarks.length} route: $routeId');
    return routeLandmarks;
  }

  //
  Future saveRouteCities(List<RouteCity> routeCities) async {
    var store = intMapStoreFactory.store('routeCities');
    for (var routeCity in routeCities) {
      store.record(dateToInt(routeCity.created!)).put(await getDb(), routeCity.toJson());
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
      finder = sw.Finder(filter: sw.Filter.equals('associationId', associationId));
    } else {
      finder = sp.Finder(filter: sp.Filter.equals('associationId', associationId));

    }
    var store = intMapStoreFactory.store('vehicles');
    var records
    = await store.find(await getDb(), finder: finder);
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
  Future saveCities(List<City> cities) async {
    var store = intMapStoreFactory.store('cities');
    for (var city in cities) {
      store.record(dateToInt(city.created?? DateTime.now().toIso8601String())).put(await getDb(), city.toJson());
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
  Future saveRouteData(RouteData data) async {
    var store = intMapStoreFactory.store('routeData');
    store.record(stringToInt(data.associationId!)).put(await getDb(), data.toJson());

    pp('$mm RouteData added to cache: ☎️ ${data.associationId} ☎️ ');
  }

  Future<RouteData?> getRouteData(String associationId) async {
    var store = intMapStoreFactory.store('routeData');
    var records = await store.find(await getDb());

    for (var rec in records) {
      var d = RouteData.fromJson(rec.value);
      if (d.associationId! == associationId) {
        return d;
      }
    }

    return null;
  }

}