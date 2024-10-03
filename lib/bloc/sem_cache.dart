import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:sembast_web/sembast_web.dart';

import '../utils/functions.dart';

class SemCache {
  // File path to a file in the current directory

  static const mm = '👽👽👽 SemCache 👽👽👽';
  final Database db;

  SemCache(this.db);

  Future saveRoutes(List<Route> routes) async {
    var store = intMapStoreFactory.store('routes');
    for (var route in routes) {
      store.record(dateToInt(route.created!)).put(db, route.toJson());
      pp('$mm route added to cache: 🥬🥬 ${route.name}');
    }
  }

  Future<List<Route>> getRoutes(String associationId) async {
    var store = intMapStoreFactory.store('routes');

    var finder = Finder(
        filter: Filter.equals('associationId', associationId),
        sortOrders: [SortOrder('associationName')]);
    var records = await store.find(db, finder: finder);

    List<Route> routes = [];
    for (var rec in records) {
      var route = Route.fromJson(rec.value);
      routes.add(route);
    }
    pp('$mm routes retrieved from cache: ${routes.length}');
    return routes;
  }

  Future<Route?> getRoute(String routeId) async {
    pp('$mm .... getRoute: $routeId');

    var store = intMapStoreFactory.store('routes');
    var finder = Finder(filter: Filter.equals('routeId', routeId));
    var records = await store.find(db, finder: finder);

    List<Route> routes = [];
    for (var rec in records) {
      var route = Route.fromJson(rec.value);
      routes.add(route);
    }
    pp('$mm routes retrieved from cache: ${routes.length}');
    if (routes.isNotEmpty) {
      return routes[0];
    }
    return null;
  }

  Future saveRoutePoints(List<RoutePoint> routePoints) async {
    var store = intMapStoreFactory.store('routePoints');
    for (var routePoint in routePoints) {
      store.record(dateToInt(routePoint.created!)).put(db, routePoint.toJson());
    }
    pp('$mm routePoints added to cache: 🌀🌀${routePoints.length} 🌀🌀');
  }

  Future<int> countRoutePoints(String associationId) async {
    int count = 0;
    var asses = await getRoutes(associationId);
    for (var value in asses) {
      var points = await getRoutePoints(value.routeId!);
      count += points.length;
    }
    return count;
  }
  Future<int> countRouteLandmarks(String associationId) async {
    int count = 0;
    var asses = await getRoutes(associationId);
    for (var value in asses) {
      var landmarks = await getRouteLandmarks(value.routeId!);
      count += landmarks.length;
    }
    return count;
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    var store = intMapStoreFactory.store('routePoints');
    var finder = Finder(filter: Filter.equals('routeId', routeId));
    var records = await store.find(db, finder: finder);

    List<RoutePoint> routePoints = [];
    for (var rec in records) {
      var routePoint = RoutePoint.fromJson(rec.value);
      routePoints.add(routePoint);
    }
    pp('$mm routePoints retrieved from cache: ${routePoints.length}');
    return routePoints;
  }

  Future saveRouteLandmarks(List<RouteLandmark> routeLandmarks) async {
    var store = intMapStoreFactory.store('routeLandmarks');
    for (var routeLandmark in routeLandmarks) {
      store
          .record(dateToInt(routeLandmark.created!))
          .put(db, routeLandmark.toJson());
    }
    pp('$mm routeLandmarks added to cache: 🥦 ${routeLandmarks.length} 🥦');
  }

  Future<List<RouteLandmark>> getRouteLandmarks(String routeId) async {
    var store = intMapStoreFactory.store('routeLandmarks');
    var finder = Finder(filter: Filter.equals('routeId', routeId));
    var records = await store.find(db, finder: finder);

    List<RouteLandmark> routeLandmarks = [];
    for (var rec in records) {
      var routePoint = RouteLandmark.fromJson(rec.value);
      routeLandmarks.add(routePoint);
    }
    pp('$mm routeLandmarks retrieved from cache: ${routeLandmarks.length}');
    return routeLandmarks;
  }

  //
  Future saveRouteCities(List<RouteCity> routeCities) async {
    var store = intMapStoreFactory.store('routeCities');
    for (var routeCity in routeCities) {
      store.record(dateToInt(routeCity.created!)).put(db, routeCity.toJson());
    }
    pp('$mm routeCities added to cache: 🖐🏾 ${routeCities.length} 🖐🏾');
  }

  Future<List<RouteCity>> getRouteCities(String routeId) async {
    var store = intMapStoreFactory.store('routeCities');
    var finder = Finder(filter: Filter.equals('routeId', routeId));
    var records = await store.find(db, finder: finder);

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
    var store = intMapStoreFactory.store('vehicles');
    for (var car in vehicles) {
      store.record(dateToInt(car.created!)).put(db, car.toJson());
    }
    pp('$mm cars added to cache: 🚘 🚖 ${vehicles.length} 🚘 🚖');
  }

  Future<List<Vehicle>> getVehicles() async {
    var store = intMapStoreFactory.store('vehicles');
    var records = await store.find(db);

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
      store.record(dateToInt(city.created!)).put(db, city.toJson());
    }
    pp('$mm cities added to cache: ☎️ ${cities.length} ☎️ ');
  }

  Future<List<City>> getCities() async {
    var store = intMapStoreFactory.store('cities');
    var records = await store.find(db);

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
    for (var ass in associations) {
      store.record(dateToInt(ass.dateRegistered!)).put(db, ass.toJson());
      pp('$mm 🖐🏾🖐🏾🖐🏾 ${ass.associationName}');
    }
    pp('$mm associations added to cache: 🎽 ${associations.length} 🎽');
  }

  Future<List<Association>> getAssociations() async {
    var store = intMapStoreFactory.store('associations');
    var records = await store.find(db);

    List<Association> asses = [];
    for (var rec in records) {
      var ass = Association.fromJson(rec.value);
      asses.add(ass);
    }
    pp('$mm asses retrieved from cache: ${asses.length}');
    return asses;
  }

  //
  int dateToInt(String date) {
    final DateTime dt = DateTime.parse(date);
    return dt.microsecondsSinceEpoch;
  }
}
