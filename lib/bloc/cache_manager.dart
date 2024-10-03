import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_schemas.dart';
import '../utils/functions.dart';

final CacheManager cacheManager = CacheManager();

class CacheManager {
  static const mm = '☕️☕️☕️☕️☕️ CacheManager: ☕️☕️';

  Future saveAppError(AppError appError) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final list = await getAppErrors();
    list.add(appError);
    final m = AppErrorList(list);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('appErrors', saveMe);

    pp("$mm saveAppError: SAVED: 🌽 ${list.length} errors in cache $mm");
  }

  Future deleteAppErrors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final m = AppErrorList([]);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('appErrors', saveMe);
    pp('$mm deleteAppErrors happened ....');
  }

  Future<List<AppError>> getAppErrors() async {
    final list = await _getAppErrorList();
    return list.appErrors;
  }

  Future<AppErrorList> _getAppErrorList() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('appErrors');
    if (string == null) {
      return AppErrorList([]);
    }
    var jx = json.decode(string);
    var list = AppErrorList.fromJson(jx);
    pp("$mm  ${list.appErrors.length} appErrors retrieved");
    return list;
  }

  //
  Future saveDispatchRecord(DispatchRecord dispatchRecord) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final list = await getDispatchRecords();
    list.add(dispatchRecord);
    final m = DispatchRecordList(list);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('dispatchRecords', saveMe);

    pp("$mm saveDispatchRecord: SAVED: 🌽 ${list.length} DispatchRecords in cache $mm");
  }
  Future saveRoute(Route route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final list = await getRoutes();
    //replace route if already exists ...
    final fl = <Route>[];
    for (var r in list) {
      if (r.routeId != route.routeId) {
        fl.add(r);
      }
    }
    fl.add(route);
    final m = RouteList(fl);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('routes', saveMe);

    pp("$mm saveRoute: SAVED: 🌽 ${list.length} Routes in cache $mm");
  }
  Future saveAmbassadorPassengerCount(AmbassadorPassengerCount count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final list = await getAmbassadorCounts();
    list.add(count);
    final m = AmbassadorPassengerCountList(list);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('counts', saveMe);

    pp("$mm saveAmbassadorPassengerCount: SAVED: 🌽 ${list.length} saveAmbassadorPassengerCount in cache $mm");
  }

  Future deleteDispatchRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dispatchRecords');
    pp('$mm deleteDispatchRecords happened ....');
  }

  Future<List<DispatchRecord>> getDispatchRecords() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('dispatchRecords');
    if (string == null) {
      return [];
    }
    var jx = json.decode(string);
    var list = DispatchRecordList.fromJson(jx);
    pp("$mm  ${list.dispatchRecords.length} DispatchRecords retrieved");
    return list.dispatchRecords;
  }

  Future<List<Route>> getRoutes() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('routes');
    if (string == null) {
      return [];
    }
    var jx = json.decode(string);
    var list = RouteList.fromJson(jx);
    pp("$mm  ${list.routes.length} Routes retrieved");
    return list.routes;
  }

  Future deleteAmbassadorCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('counts');
    pp(' 🔷🔷 deleteAmbassadorCounts happened ....');
  }

  Future<List<AmbassadorPassengerCount>> getAmbassadorCounts() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('counts');
    if (string == null) {
      return [];
    }
    var jx = json.decode(string);
    var list = AmbassadorPassengerCountList.fromJson(jx);
    pp(" 🔷🔷  ${list.counts.length} AmbassadorPassengerCounts retrieved");
    return list.counts;
  }
}

class AppErrorList {
  List<AppError> appErrors = [];
  AppErrorList(this.appErrors);

  AppErrorList.fromJson(Map data) {
    List list = data['appErrors'];
    for (var value in list) {
      final m = AppError.fromJson(value);
      appErrors.add(m);
    }
  }
  Map<String, dynamic> toJson() {
    final list = [];
    for (var err in appErrors) {
      list.add(err.toJson());
    }
    Map<String, dynamic> map = {
      'appErrors': list,
    };
    return map;
  }
}

//
class DispatchRecordList {
  List<DispatchRecord> dispatchRecords = [];

  DispatchRecordList(this.dispatchRecords);

  DispatchRecordList.fromJson(Map data) {
    List list = data['dispatchRecords'];
    for (var value in list) {
      final m = DispatchRecord.fromJson(value);
      dispatchRecords.add(m);
    }
  }
  Map<String, dynamic> toJson() {
    final list = [];
    for (var err in dispatchRecords) {
      list.add(err.toJson());
    }
    Map<String, dynamic> map = {
      'dispatchRecords': list,
    };
    return map;
  }
}

class AmbassadorPassengerCountList {
  List<AmbassadorPassengerCount> counts = [];

  AmbassadorPassengerCountList(this.counts);

  AmbassadorPassengerCountList.fromJson(Map data) {
    List list = data['counts'];
    for (var value in list) {
      final m = AmbassadorPassengerCount.fromJson(value);
      counts.add(m);
    }
  }
  Map<String, dynamic> toJson() {
    final list = [];
    for (var err in counts) {
      list.add(err.toJson());
    }
    Map<String, dynamic> map = {
      'counts': list,
    };
    return map;
  }
}
class RouteList {
  List<Route> routes = [];

  RouteList(this.routes);

  RouteList.fromJson(Map data) {
    List list = data['routes'];
    for (var value in list) {
      final m = Route.fromJson(value);
      routes.add(m);
    }
  }
  Map<String, dynamic> toJson() {
    final list = [];
    for (var r in routes) {
      list.add(r.toJson());
    }
    Map<String, dynamic> map = {
      'routes': list,
    };
    return map;
  }
}
