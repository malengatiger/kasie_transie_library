import 'package:flutter/foundation.dart';

class KasieEnvironment {
  // static const _currentStatus = 'prod';
  static const _currentStatus = 'dev';
  //
  static const _devUrl = 'http://192.168.86.242:8080/';
  // static const _devUrl = 'http://172.20.10.10:8080/';

  //
  static const _prodUrl1 = 'kasietransie';
  static const _prodUrl2 = '-umrjnxdnuq-ew.a.run';
  static const _prodUrl3 = '.app/';

  static String getUrl() {
    if (kReleaseMode) {
      return 'https://kasietransie-umrjnxdnuq-ew.a.run.app/';
    } else {
      return _devUrl;
    }
  }
}
