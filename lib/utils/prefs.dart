import 'dart:convert';

import 'package:realm/realm.dart' as rm;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/list_api_dog.dart';
import '../data/schemas.dart';
import 'functions.dart';

late Prefs prefs;

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
    List<int> bytes = utf8.encode(jx['id']);

    var user = Country(rm.ObjectId.fromBytes(bytes),
      countryId: jx['countryId'],
      name: jx['name'],
      iso2: jx['iso2'],
    );
    pp("🌽 🌽 🌽 Prefs: getCountry 🧩  ${user.name} retrieved");
    return user;
  }

  Future saveConductor(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('conductor', jx);
    pp("🌽 🌽 🌽 Prefs: saveConductor:  SAVED: 🌽 ${user.toJson()}");
    return null;
  }

  Future<User?> getConductor() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('conductor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = buildUser(jx);
    pp("🌽 🌽 🌽 Prefs: getConductor: 🧩  ${user.toJson()} retrieved");
    return user;
  }

  //
  Future saveSettings(SettingsModel settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = settings.toJson();
    var jx = json.encode(mJson);
    prefs.setString('settings', jx);
    pp("🌽 🌽 🌽 Prefs: saveSettings:  SAVED: 🌽 ${settings.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<SettingsModel> getSettings() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('settings');
    if (string == null) {
      return SettingsModel(rm.ObjectId(),
          locale: 'en',
          themeIndex: 0,
          associationId: null,
          refreshRateInSeconds: 360);
    }
    var jx = json.decode(string);
    var sett = buildSettingsModel(jx);
    pp("🌽 🌽 🌽 Prefs: getSettings 🧩  ${sett.toJson()} retrieved");
    return sett;
  }
}
