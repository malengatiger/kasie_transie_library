import 'dart:convert';

import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/schemas.dart';
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
    final m =DispatchRecordList(list);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('dispatchRecords', saveMe);

    pp("$mm saveDispatchRecord: SAVED: 🌽 ${list.length} DispatchRecords in cache $mm");

  }
  Future deleteDispatchRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final m = DispatchRecordList([]);
    final mJson = m.toJson();
    final saveMe = jsonEncode(mJson);
    await prefs.setString('dispatchRecords', saveMe);
    pp('$mm deleteDispatchRecords happened ....');
  }

  Future<String> getDispatchRecordString() async {
    final list = await _getDispatchRecordList();
    return jsonEncode(list);
  }
  Future<List<DispatchRecord>> getDispatchRecords() async {
    final list = await _getDispatchRecordList();
    return list.dispatchRecords;
  }
  Future<DispatchRecordList> _getDispatchRecordList() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('dispatchRecords');
    if (string == null) {
      return DispatchRecordList([]);
    }
    var jx = json.decode(string);
    var list = DispatchRecordList.fromJson(jx);
    pp("$mm  ${list.dispatchRecords.length} DispatchRecords retrieved");
    return list;
  }
}


class AppErrorList {
  List<AppError> appErrors = [];

  AppErrorList(this.appErrors);

  AppErrorList.fromJson(Map data) {
    List list = data['appErrors'];
    for (var value in list) {
      final m = AppError(ObjectId.fromHexString(value['_id'] as String),
        created: value['created'],
        userId: value['userId'],
        associationId: value['associationId'],
        userUrl: value['userUrl'],
        manufacturer: value['manufacturer'],
        errorMessage: value['errorMessage'],
        userName: value['userName'],
        brand: value['brand'],
        model: value['model'],
        deviceType: value['created'],
        baseOS: value['baseOS'],
        uploadedDate: value['uploadedDate'],
      );
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
      final m = buildLocalDispatchRecord(value);
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
DispatchRecord buildLocalDispatchRecord(Map j) {
  var m = DispatchRecord(
    ObjectId(),
    vehicleId: j['vehicleId'],
    vehicleReg: j['vehicleReg'],
    associationId: j['associationId'],
    associationName: j['associationName'],
    created: j['created'],
    dispatchRecordId: j['dispatchRecordId'],
    passengers: j['passengers'],
    ownerId: j['ownerId'],
    marshalId: j['marshalId'],
    marshalName: j['marshalName'],
    vehicleArrivalId: j['vehicleArrivalId'],
    dispatched: j['dispatched'],
    geoHash: j['geoHash'],
    routeName: j['routeName'],
    landmarkId: j['landmarkId'],
    position: buildPosition(j['position']),
  );
  return m;
}