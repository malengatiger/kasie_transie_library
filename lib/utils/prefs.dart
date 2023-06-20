import 'dart:convert';

import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart' as rm;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/list_api_dog.dart';
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
  Future saveSettings(SettingsModel settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map mJson = settings.toJson();
    var jx = json.encode(mJson);
    prefs.setString('SettingsModel', jx);
    pp("🌽 🌽 🌽 Prefs: saveSettings:  SAVED: 🌽 ${settings.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<SettingsModel?> getSettings() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('SettingsModel');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var sett = buildSettingsModel(jx);
    pp("🌽 🌽 🌽 Prefs: getSettings 🧩  ${sett.toJson()} retrieved");
    return sett;
  }
}
