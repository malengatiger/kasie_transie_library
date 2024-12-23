import 'package:flutter/foundation.dart';

class KasieEnvironment {
  //Service URL: https://kasie-backend-3-167113439249.europe-west1.run.app

  static const useNodeJSBackend = true;
  //192.168.88.253
  // static const _devUrlNode = 'http://192.168.88.253:8080/api/v1/';
  // static const _devUrlNode = 'http://169.254.190.11:8080/api/v1/';
  static const _devUrlNode = 'http://192.168.64.1:8080/api/v1/';


  static const _prodUrlNode = 'https://kasie-transie-3-backend-854189510560.europe-west1.run.app/api/v1/';
  static const aubs = 'aubreym';
  static const aubs2 = 'kkTiger23';
  static const aubs3 = 'mon';
  static const aubs4 = 'godb';



  static String getUrl() {
    if (kDebugMode) {
        // return _devUrlNode;
      return _prodUrlNode;

    } else {
        return _prodUrlNode;
    }
    throw Exception('wtf?');
  }
  static String getDatabaseString() {
    if (kDebugMode) {
      return '$aubs3$aubs4://localhost:27017/kasie_transie_db';
    } else {
      return '$aubs3$aubs4+srv://$aubs:$aubs2@cluster0.njz1rn4.$aubs3$aubs4.net/?retryWrites=true&w=majority&appName=Cluster0';
    }
  }

}
