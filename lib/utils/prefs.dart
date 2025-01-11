import 'dart:convert';

import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_schemas.dart';
import 'functions.dart';

class Prefs {
  final SharedPreferences prefs;

  Prefs(this.prefs);

  static const String commuterRoutesKey = 'commuterRoutes';


  Future<void> addCommuterRoute(Route route) async {
    pp('\n\n 🔆 🔆 ... addCommuterRoute prefs:  ${route.name}.');

    try {
      List<Route> routes = await getCommuterRoutes();
      var found = false;
      for (var r in routes) {
        if (route.routeId == r.routeId) {
          found = true;
        }
      }
      if (!found) {
        routes.add(route);
        await _saveCommuterRoutes(routes);
        pp('🔆 🔆addCommuterRoute:  ✅ Route "${route.name}" added to cached list.');
      }

    } catch (e) {
      pp('🔆 🔆addCommuterRoute: ❌ Error adding route: $e');
    }
  }


  Future<void> _saveCommuterRoutes(List<Route> routes) async {
    final routesJson = jsonEncode(routes.map((e) => e.toJson()).toList());
    await prefs.setString(commuterRoutesKey, routesJson);
    pp('🔆 🔆_saveCommuterRoutes: ✅ ${routes.length} routes saved to cache.');
  }


  Future<List<Route>> getCommuterRoutes() async {
    pp('\n\n 🔆 🔆... getCommuterRoutes ...');

    final routesJson = prefs.getString(commuterRoutesKey);
    if (routesJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(routesJson);
        final routes = jsonList.map((json) => Route.fromJson(json)).toList();
        pp('🔆 🔆getCommuterRoutes: ✅ Retrieved ${routes.length} routes from cache.');
        return routes;
      } catch (e) {
        pp('getCommuterRoutes: ❌ Error decoding routes from cache: $e');
        return [];
      }
    } else {
      pp('🔆 🔆getCommuterRoutes:  No routes found in cache.');
      return [];
    }
  }
  void removeUser() {
    prefs.remove('user');
    pp("🌽 🌽 🌽 Prefs: removeUser done. Cached user removed!");

  }
  void saveUser(User user) {
    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('user', jx);
    pp("🌽 🌽 🌽 Prefs: saveUser:  SAVED: 🌽 ${user.toJson()} 🌽 🌽 🌽");
  }

  User? getUser() {
    var string = prefs.getString('user');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = User.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getUser 🧩  ${user.firstName} retrieved");
    return user;
  }

  void saveCountry(Country country) {
    Map mJson = country.toJson();
    var jx = json.encode(mJson);
    prefs.setString('country', jx);
    pp("🌽 🌽 🌽 Prefs: saveCountry:  SAVED: 🌽 ${country.toJson()} 🌽 🌽 🌽");
  }

  Country? getCountry() {
    var string = prefs.getString('country');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var country = Country.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getCountry 🧩  ${country.name} retrieved");
    return country;
  }

  void savePosition(Position position) {
    Map mJson = position.toJson();
    var jx = json.encode(mJson);
    prefs.setString('position', jx);
    pp("🌽 🌽 🌽 Prefs: position:  SAVED: 🌽 ${position.toJson()} 🌽 🌽 🌽");
  }

  Position? getPosition() {
    var string = prefs.getString('position');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var pos = Position.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getPosition 🧩  ${pos.toJson()} retrieved");
    return pos;
  }
  void saveRoute(Route route) {
    Map mJson = route.toJson();
    var jx = json.encode(mJson);
    prefs.setString('route', jx);
    pp("🌽 🌽 🌽 Prefs: saveRoute  SAVED: 🌽 ${route.name} 🌽 🌽 🌽");
  }

  Route? getRoute() {
    var string = prefs.getString('route');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var route = Route.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getRoute 🧩  ${route.name} retrieved");
    return route;
  }

  void saveColorAndLocale(ColorAndLocale colorAndLocale) {
    Map mJson = colorAndLocale.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ColorAndLocale', jx);
    pp("🌽 🌽 🌽 Prefs: saveColorAndLocale  SAVED: 🌽 ${colorAndLocale.toJson()} 🌽 🌽 🌽");
  }

  ColorAndLocale getColorAndLocale() {
    var string = prefs.getString('ColorAndLocale');
    if (string == null) {
      return ColorAndLocale(themeIndex: 0, locale: 'en');
    }
    var jx = json.decode(string);
    var cl = ColorAndLocale.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getColorAndLocale 🧩  ${cl.toJson()} retrieved");
    return cl;
  }

  void saveAmbassador(User user) {
    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('conductor', jx);
    pp("🌽 🌽 🌽 Prefs: saveAmbassador:  SAVED: 🌽 ${user.toJson()}");
  }

  User? getAmbassador() {
    var string = prefs.getString('conductor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = User.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getAmbassador: 🧩  ${user.toJson()} retrieved");
    return user;
  }

  void saveCommuter(Commuter commuter) {
    Map mJson = commuter.toJson();
    var jx = json.encode(mJson);
    prefs.setString('commuter', jx);
    pp("🌽 🌽 🌽 Prefs: saveCommuter:  SAVED: 🌽 ${commuter.toJson()}");
  }

  Commuter? getCommuter() {
    var string = prefs.getString('commuter');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = Commuter.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getCommuter: 🧩  ${user.commuterId} retrieved");
    return user;
  }

  //
  void saveSettings(SettingsModel settings) {
    Map mJson = settings.toJson();
    var jx = json.encode(mJson);
    prefs.setString('SettingsModel', jx);
    pp("🌽 🌽 🌽 Prefs: saveSettings:  SAVED: 🌽 "
        "themeIndex: ${settings.themeIndex} 🌽 locale: ${settings.locale} 🌽 🌽");
  }

  SettingsModel? getSettings() {
    var string = prefs.getString('SettingsModel');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var sett = SettingsModel.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getSettings 🧩  themeIndex: ${sett.themeIndex} 🌽 locale: ${sett.locale} retrieved");
    return sett;
  }

  void saveCar(Vehicle car) {
    Map mJson = car.toJson();
    var jx = json.encode(mJson);
    prefs.setString('car', jx);
    pp("🌽 🌽 🌽 Prefs: saveCar:  SAVED: 🌽 ${car.toJson()} 🌽 🌽 🌽");
  }

  Vehicle? getCar() {
    var string = prefs.getString('car');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var car = Vehicle.fromJson(jx);
    // pp("🌽 🌽 🌽 Prefs: getCar 🧩  ${car.vehicleReg} retrieved");
    return car;
  }

  void saveAssociation(Association association) {
    Map mJson = association.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ass', jx);
    pp("🌽 🌽 🌽 Prefs: saveAssociation:  SAVED: 🌽 ${association.toJson()} 🌽 🌽 🌽");
  }

  Association? getAssociation() {
    var string = prefs.getString('ass');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var car = Association.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getAssociation 🧩  ${car.associationName} retrieved");
    return car;
  }

  void saveEmail(String email) {
    prefs.setString('email', email);
    pp("🌽 🌽 🌽 Prefs: Email:  SAVED: 🌽 $email 🌽 🌽 🌽");
    return;
  }

  String? getEmail() {
    final s = prefs.getString('email');
    pp("🌽 🌽 🌽 Prefs: Email:  RETRIEVED: 🌽 $s 🌽 🌽 🌽");
    return s;
  }

  void saveDemoFlag(bool demo) {
    prefs.setBool('demo', demo);
    pp("🌽 🌽 🌽 Prefs: DemoFlag:  SAVED: 🌽 $demo 🌽 🌽 🌽");
    return;
  }

  bool getDemoFlag() {
    final s = prefs.getBool('demo');
    pp("🌽 🌽 🌽 Prefs: getDemoFlag:  RETRIEVED: 🌽 $s 🌽 🌽 🌽");
    return s == null ? false : true;
  }
}
