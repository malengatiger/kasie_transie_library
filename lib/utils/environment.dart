import 'package:flutter/foundation.dart';

class KasieEnvironment {
  // static const _currentStatus = 'prod';
  static const _currentStatus = 'dev';

  static const useNodeJSBackend = true;
  // static const useNodeJSBackend = false;

  //
  static const _devUrlNode = 'http://192.168.86.242:5050/api/v1/';
  // static const _devUrl = 'http://172.20.10.10:8080/';
  static const _devUrlSB = 'http://192.168.86.242:8080/';

  //
  static const _prodUrlSB = 'https://kasietransie-umrjnxdnuq-ew.a.run.app/';
  static const _prodUrlNode = 'https://kasie-nest-3-umrjnxdnuq-ew.a.run.app/api/v1/';
  static const _prodUrl3 = '.app/';

  static String getUrl() {
    if (kReleaseMode) {
      if (useNodeJSBackend) {
        return _prodUrlNode;
      } else {
        return _prodUrlSB;
      }
    } else {
      if (useNodeJSBackend) {
        return _devUrlNode;
      } else {
        return _devUrlSB;
      }
    }
  }
}
