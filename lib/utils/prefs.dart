import 'dart:convert';

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
   Future saveSettings(SettingsModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('settings', jx);
    pp("🌽 🌽 🌽 Prefs: saveSettings:  SAVED: 🌽 ${user.toJson()} 🌽 🌽 🌽");
    return null;
   }

   Future<SettingsModel> getSettings() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('settings');
    if (string == null) {
     return SettingsModel(locale: 'en', themeIndex: 0, associationId: null, refreshRateInSeconds: 360);
    }
    var jx = json.decode(string);
    var sett = SettingsModel(
     locale: jx['locale'],
     themeIndex: jx['themeIndex'],
     associationId: jx['associationId'],
     refreshRateInSeconds: jx['refreshRateInSeconds'],
    );
    pp("🌽 🌽 🌽 Prefs: getSettings 🧩  ${sett.toJson()} retrieved");
    return sett;
   }

}