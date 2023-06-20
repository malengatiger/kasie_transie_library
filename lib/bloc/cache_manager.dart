import 'dart:convert';

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
}


class AppErrorList {
  List<AppError> appErrors = [];

  AppErrorList(this.appErrors);

  AppErrorList.fromJson(Map data) {
    List list = data['appErrors'];
    for (var value in list) {
      List<int> bytes = utf8.encode(value['id']);

      final m = AppError(ObjectId.fromBytes(bytes),
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
