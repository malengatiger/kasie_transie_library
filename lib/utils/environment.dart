import 'package:flutter/foundation.dart';

class KasieEnvironment {

  static const useNodeJSBackend = true;
  static const _devUrlNode = 'http://127.0.0.1:8080/api/v1/';
  static const _prodUrlNode = 'https://kasie-backend-3-167113439249.europe-west1.run.app/api/v1/';
  static const aubs = 'aubreym';
  static const aubs2 = 'kkTiger23';
  static const aubs3 = 'mon';
  static const aubs4 = 'godb';



  static String getUrl() {
    if (kDebugMode) {
        return _devUrlNode;
      // return _prodUrlNode;

    } else {
        return _prodUrlNode;

    }
  }
  static String getDatabaseString() {
    if (kDebugMode) {
      return '$aubs3$aubs4://localhost:27017/kasie_transie_db';
    } else {
      return '$aubs3$aubs4+srv://$aubs:$aubs2@cluster0.njz1rn4.$aubs3$aubs4.net/?retryWrites=true&w=majority&appName=Cluster0';
    }
  }

}
