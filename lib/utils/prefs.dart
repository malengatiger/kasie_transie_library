import 'dart:convert';

import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/schemas.dart';
import 'functions.dart';

final Prefs prefs = Prefs();

class Prefs {
  Future saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('user', jx);
    pp("🌽 🌽 🌽 Prefs: saveUser:  SAVED: 🌽 ${user.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<User?> getUser() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('user');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = buildUser(jx);
    pp("🌽 🌽 🌽 Prefs: getUser 🧩  ${user.firstName} retrieved");
    return user;
  }

  Future saveCountry(Country country) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = country.toJson();
    var jx = json.encode(mJson);
    prefs.setString('country', jx);
    pp("🌽 🌽 🌽 Prefs: saveCountry:  SAVED: 🌽 ${country.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<Country?> getCountry() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('country');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var country = buildCountry(jx);
    pp("🌽 🌽 🌽 Prefs: getCountry 🧩  ${country.name} retrieved");
    return country;
  }

  Future saveRoute(Route route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = route.toJson();
    var jx = json.encode(mJson);
    prefs.setString('route', jx);
    pp("🌽 🌽 🌽 Prefs: saveRoute  SAVED: 🌽 ${route.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<Route?> getRoute() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('route');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var route = buildRoute(jx);
    pp("🌽 🌽 🌽 Prefs: getRoute 🧩  ${route.name} retrieved");
    return route;
  }

  //

  Future saveColorAndLocale(ColorAndLocale colorAndLocale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = colorAndLocale.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ColorAndLocale', jx);
    pp("🌽 🌽 🌽 Prefs: saveColorAndLocale  SAVED: 🌽 ${colorAndLocale.toJson()} 🌽 🌽 🌽");
  }

  Future<ColorAndLocale> getColorAndLocale() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('ColorAndLocale');
    if (string == null) {
      return ColorAndLocale(themeIndex: 0, locale: 'en');
    }
    var jx = json.decode(string);
    var cl = ColorAndLocale.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getColorAndLocale 🧩  ${cl.toJson()} retrieved");
    return cl;
  }

  //

  Future saveAmbassador(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('conductor', jx);
    pp("🌽 🌽 🌽 Prefs: saveAmbassador:  SAVED: 🌽 ${user.toJson()}");
    return null;
  }

  Future<User?> getAmbassador() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('conductor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = buildUser(jx);
    pp("🌽 🌽 🌽 Prefs: getAmbassador: 🧩  ${user.toJson()} retrieved");
    return user;
  }
  //
  Future saveCommuter(Commuter commuter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = commuter.toJson();
    var jx = json.encode(mJson);
    prefs.setString('commuter', jx);
    pp("🌽 🌽 🌽 Prefs: saveCommuter:  SAVED: 🌽 ${commuter.toJson()}");
    return null;
  }

  Future<Commuter?> getCommuter() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('commuter');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = buildCommuter(jx);
    pp("🌽 🌽 🌽 Prefs: getCommuter: 🧩  ${user.toJson()} retrieved");
    return user;
  }
  //
  Future saveSettings(SettingsModel settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map mJson = settings.toJson();
    var jx = json.encode(mJson);
    prefs.setString('SettingsModel', jx);
    pp("🌽 🌽 🌽 Prefs: saveSettings:  SAVED: 🌽 themeIndex: ${settings.themeIndex} 🌽 locale: ${settings.locale} 🌽 🌽");
  }

  Future<SettingsModel?> getSettings() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('SettingsModel');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var sett = buildSettingsModel(jx);
    pp("🌽 🌽 🌽 Prefs: getSettings 🧩  themeIndex: ${sett.themeIndex} 🌽 locale: ${sett.locale} retrieved");
    return sett;
  }

  Future saveCar(Vehicle car) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = car.toJson();
    var jx = json.encode(mJson);
    prefs.setString('car', jx);
    pp("🌽 🌽 🌽 Prefs: saveCar:  SAVED: 🌽 ${car.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<Vehicle?> getCar() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('car');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var car = buildVehicle(jx);
    pp("🌽 🌽 🌽 Prefs: getCar 🧩  ${car.vehicleReg} retrieved");
    return car;
  }

  Future saveAssociation(Association association) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = association.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ass', jx);
    pp("🌽 🌽 🌽 Prefs: saveAssociation:  SAVED: 🌽 ${association.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<Association?> getAssociation() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('ass');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var car = buildAssociation(jx);
    pp("🌽 🌽 🌽 Prefs: getAssociation 🧩  ${car.associationName} retrieved");
    return car;
  }

  Future saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    pp("🌽 🌽 🌽 Prefs: Email:  SAVED: 🌽 $email 🌽 🌽 🌽");
    return;
  }
  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('email');
    pp("🌽 🌽 🌽 Prefs: Email:  RETRIEVED: 🌽 $s 🌽 🌽 🌽");
    return s;
  }
}
