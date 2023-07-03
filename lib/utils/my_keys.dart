import 'dart:collection';

class MyKeys {
  static var hashMap = HashMap<String, String>();
  static HashMap getKeys() {
    if (hashMap.isEmpty) {
      _buildMap();
    }
    return hashMap;
  }

  static _buildMap() {
    hashMap['routeEnd'] = 'routeEnd';
    hashMap['dispatch'] = 'dispatch';
    hashMap['taxiMarshal'] = 'taxiMarshal';
    hashMap['addNewRoute'] = 'addNewRoute';
    hashMap['selectStartEnd'] = 'selectStartEnd';
    hashMap['pleaseSelectRoute'] = 'pleaseSelectRoute';
    hashMap['saveRoute'] = 'saveRoute';
    hashMap['routeName'] = 'routeName';
    hashMap['duplicateAss'] = 'duplicateAss';
    hashMap['thanks'] = 'thanks';
    hashMap['phoneSignIn'] = 'phoneSignIn';
    hashMap['routes'] = 'routes';
    hashMap['emailAddress'] = 'emailAddress';
    hashMap['password'] = 'password';
    hashMap['dispatches'] = 'dispatches';
    hashMap['selectVehicle'] = 'selectVehicle';
    hashMap['problem'] = 'problem';
    hashMap['phoneAuth'] = 'phoneAuth';
    hashMap['hereWeCome'] = 'hereWeCome';
    hashMap['manualDispatch'] = 'manualDispatch';
    hashMap['signInWithEmail'] = 'signInWithEmail';
    hashMap['sendRouteMessage'] = 'sendRouteMessage';
    hashMap['marshal'] = 'marshal';
    hashMap['scannerWaiting'] = 'scannerWaiting';
    hashMap['dashboard'] = 'dashboard';
    hashMap['passengers'] = 'passengers';
    hashMap['createOrUpdate'] = 'createOrUpdate';
    hashMap['dispatchWithScan'] = 'dispatchWithScan';
    hashMap['vehicleQRCode'] = 'vehicleQRCode';
    hashMap['routesMenu'] = 'routesMenu';
    hashMap['routeStart'] = 'routeStart';
    hashMap['pleaseEnterRouteName'] = 'pleaseEnterRouteName';
    hashMap['enterPhone'] = 'enterPhone';
    hashMap['routePointsMapped'] = 'routePointsMapped';
    hashMap['done'] = 'done';
    hashMap['calculateRouteDistance'] = 'calculateRouteDistance';
    hashMap['addCity'] = 'addCity';
    hashMap['sendCreds'] = 'sendCreds';
    hashMap['registerAssoc'] = 'registerAssoc';
    hashMap['selectRoute'] = 'selectRoute';
    hashMap['phoneNumber'] = 'phoneNumber';
    hashMap['routeLandmarks'] = 'routeLandmarks';
    hashMap['emailAuthFailed'] = 'emailAuthFailed';
    hashMap['errorGettingData'] = 'errorGettingData';
    hashMap['driver'] = 'driver';
    hashMap['enterCode'] = 'enterCode';
    hashMap['refreshRouteData'] = 'refreshRouteData';
    hashMap['viewRouteMap'] = 'viewRouteMap';
    hashMap['emailAuth'] = 'emailAuth';
    hashMap['associations'] = 'associations';
    hashMap['route`color'] = 'route`color';
    hashMap['no'] = 'no';
    hashMap['heartbeats'] = 'heartbeats';
    hashMap['initializingResources'] = 'initializingResources';
    hashMap['arrivals'] = 'arrivals';
    hashMap['Cancel'] = 'Cancel';
    hashMap['sendCode'] = 'sendCode';
    hashMap['thisMayTake'] = 'thisMayTake';
    hashMap['vehicles'] = 'vehicles';
    hashMap['selectSignInKind'] = 'selectSignInKind';
    hashMap['landmarks'] = 'landmarks';
    hashMap['selectAss'] = 'selectAss';
    hashMap['routeEditor'] = 'routeEditor';
    hashMap['taxiDriver'] = 'taxiDriver';
    hashMap['enterRouteName'] = 'enterRouteName';
    hashMap['verify'] = 'verify';
    hashMap['working'] = 'working';
    hashMap['createNewPlace'] = 'createNewPlace';
    hashMap['owner'] = 'owner';
    hashMap['enterEmail'] = 'enterEmail';
    hashMap['unableToSignIn'] = 'unableToSignIn';
    hashMap['calculateDistancesBetween'] = 'calculateDistancesBetween';
    hashMap['yes'] = 'yes';
    hashMap['startOfRoute'] = 'startOfRoute';
    hashMap['serverUnreachable'] = 'serverUnreachable';
    hashMap['enterPassword'] = 'enterPassword';
    hashMap['departures'] = 'departures';
    hashMap['signedIn'] = 'signedIn';
    hashMap['fetch'] = 'fetch';
    hashMap['associationVehicles'] = 'associationVehicles';
    hashMap['taxiRoutes'] = 'taxiRoutes';
    hashMap['createNewRoute'] = 'createNewRoute';
    hashMap['routeDetails'] = 'routeDetails';
    hashMap['emailSignIn'] = 'emailSignIn';
    hashMap['routeMaps'] = 'routeMaps';
    hashMap['signInWithPhone'] = 'signInWithPhone';
    hashMap['endOfRoute'] = 'endOfRoute';
    hashMap['register'] = 'register';
    hashMap['ownerUnknown'] = 'ownerUnknown';
    hashMap['st'] = 'st';
    hashMap['de'] = 'de';
    hashMap['pt'] = 'pt';
    hashMap['sw'] = 'sw';
    hashMap['af'] = 'af';
    hashMap['en'] = 'en';
    hashMap['fr'] = 'fr';
    hashMap['es'] = 'es';
    hashMap['zh'] = 'zh';
    hashMap['xh'] = 'xh';
    hashMap['yo'] = 'yo';
    hashMap['zu'] = 'zu';
    hashMap['sn'] = 'sn';
    hashMap['ig'] = 'ig';
    hashMap['ts'] = 'ts';

  }
}