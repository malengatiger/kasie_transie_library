import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/messaging/local_notif.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/list_api_dog.dart';
import '../data/constants.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';
import '../utils/prefs.dart';

final FCMBloc fcmBloc = FCMBloc(fb.FirebaseMessaging.instance);
String? appName;

class FCMBloc {
  final fb.FirebaseMessaging firebaseMessaging;
  final mm = '🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 FCMBloc: 🔵🔵 ';

  FCMBloc(this.firebaseMessaging) {
    initialize();
  }

  lib.User? user;
  lib.Vehicle? car;
  lib.Association? ass;
  bool demoFlag = false;

  Future initialize() async {
    pp('\n$mm ... FirebaseMessaging initialize starting ... ');
    user = await prefs.getUser();
    car = await prefs.getCar();
    fb.NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    pp('$mm FCM : User granted permission?, authorizationStatus: ${notificationSettings.authorizationStatus}');

    firebaseMessaging.setAutoInitEnabled(true);
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      pp("$mm listener onTokenRefresh: 🍎🍎🍎 update user: token: $newToken ... 🍎🍎");
    });
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    fb.FirebaseMessaging.onMessage.listen((fb.RemoteMessage message) {
      processFCMMessage(message, getMessageType(message));
    });

    fb.FirebaseMessaging.onBackgroundMessage(
        kasieFirebaseMessagingBackgroundHandler);

    fb.FirebaseMessaging.onMessageOpenedApp.listen((fb.RemoteMessage message) {
      pp('$mm onMessageOpenedApp:  $red A new onMessageOpenedApp event was published! ${message.data}');
    });

    LocalNotificationService.initialize();
    pp("\n\n$mm FCM : FIREBASE MESSAGING initialization done! "
        "- ${E.nice} ${E.nice} ${E.nice} "
        " apps will subscribeToTopics() ...........................");
  }

  String getMessageType(fb.RemoteMessage message) {
    var type = '';
    if (message.data[Constants.routeChanges] != null) {
      pp("$mm onMessage: $red routeChanges message has arrived!  ... $red ");
      type = Constants.routeChanges;
    } else if (message.data[Constants.vehicleChanges] != null) {
      pp("$mm onMessage: $red vehicleChanges message has arrived!  ... $red ");
      type = Constants.vehicleChanges;
    } else if (message.data[Constants.locationRequest] != null) {
      pp("$mm onMessage: $red locationRequest message has arrived!  ... $red ");
      type = Constants.locationRequest;
    } else if (message.data[Constants.locationResponse] != null) {
      pp("$mm onMessage: $red locationResponse message has arrived!  ... $red ");
      type = Constants.locationResponse;
    } else if (message.data[Constants.vehicleArrival] != null) {
      pp("$mm onMessage: $red vehicleArrival message has arrived!  ... $red\n ");
      type = Constants.vehicleArrival;
    } else if (message.data[Constants.vehicleDeparture] != null) {
      pp("$mm onMessage: $red vehicleDeparture message has arrived!  ... $red ");
      type = Constants.vehicleDeparture;
    } else if (message.data[Constants.dispatchRecord] != null) {
      pp("$mm onMessage: $red dispatchRecord message has arrived!  ... $red ");
      type = Constants.dispatchRecord;
    } else if (message.data[Constants.userGeofenceEvent] != null) {
      pp("$mm onMessage: $red userGeofenceEvent message has arrived!  ... $red ");
      type = Constants.userGeofenceEvent;
    } else if (message.data[Constants.vehicleMediaRequest] != null) {
      pp("$mm onMessage: $red vehicleMediaRequest message has arrived!  ... $red ");
      type = Constants.vehicleMediaRequest;
    } else if (message.data[Constants.passengerCount] != null) {
      pp("$mm onMessage: $red passengerCount message has arrived!  ... $red ");
      type = Constants.passengerCount;
    } else if (message.data[Constants.heartbeat] != null) {
      pp("$mm onMessage: $red heartbeat message has arrived!  ... $red ");
      type = Constants.heartbeat;
    } else if (message.data[Constants.commuterRequest] != null) {
      pp("$mm onMessage: $red commuterRequest message has arrived!  ... $red ");
      type = Constants.commuterRequest;
    } else if (message.data[Constants.routeUpdateRequest] != null){
      pp("$mm onMessage: $red routeUpdateRequest message has arrived!  ... $red ");
      type = Constants.routeUpdateRequest;
    } else{
      pp("$mm onMessage: $red unknown message has arrived!  ... $red ");
      return 'unknown';
    }
    return type;
  }

  static const red = '🍎🍎';

  var newMM = '🍎🍎🍎🍎🍎🍎🍎🍎 FCMBloc: ';

  Future<void> subscribeForDemoDriver() async {
    String? associationId;
    ass = await prefs.getAssociation();
    demoFlag = await prefs.getDemoFlag();
    if (ass != null) {
      associationId = ass!.associationId!;
    } else {
      return;
    }
    //
    await firebaseMessaging.subscribeToTopic('commuterRequest_$associationId');
    pp('$newMM ..... FCM: subscribed to commuterRequest_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('heartbeat_$associationId');
    pp('$newMM ..... FCM: subscribed to heartbeat_$associationId');
//
    await firebaseMessaging.subscribeToTopic('dispatchRecord_$associationId');
    pp('$newMM ..... FCM: subscribed to dispatchRecord_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('passengerCount_$associationId');
    pp('$newMM ..... FCM: subscribed to passengerCount_$associationId');

    pp('$newMM ..... FCM: subscribed to all ${E.pear} 4 (four) DemoDriver FCM topics\n\n');
  }

  Future<void> subscribeToTopics(String app) async {
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    user = await prefs.getUser();
    car = await prefs.getCar();
    demoFlag = await prefs.getDemoFlag();

    String? associationId;
    if (user != null) {
      associationId = user!.associationId!;
    }
    if (car != null) {
      associationId = car!.associationId!;
    }
    if (ass != null) {
      associationId = ass!.associationId!;
    }

    if (associationId == null) {
      return;
    }

    //todo - cut up subscriptions for each user type (or app)

    pp("\n\n$newMM subscribeToTopics: $red start to subscribe to all KasieTransie FCM topics ... ");

    await firebaseMessaging.subscribeToTopic('vehicle_changes_$associationId');
    pp('$newMM ..... FCM: subscribed to vehicle_changes_$associationId');

    await firebaseMessaging.subscribeToTopic('route_changes_$associationId');
    pp('$newMM ..... FCM: subscribed to route_changes_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('vehicleArrival_$associationId');
    pp('$newMM ..... FCM: subscribed to vehicle_arrival_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('vehicleDeparture_$associationId');
    pp('$newMM ..... FCM: subscribed to vehicle_departure_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('dispatchRecord_$associationId');
    pp('$newMM ..... FCM: subscribed to dispatchRecord_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('passengerCount_$associationId');
    pp('$newMM ..... FCM: subscribed to passengerCount_$associationId');

    //
    await firebaseMessaging.subscribeToTopic('locationResponse_$associationId');
    pp('$newMM ..... FCM: subscribed to locationResponse_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('locationRequest_$associationId');
    pp('$newMM ..... FCM: subscribed to locationRequest_$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('userGeofenceEvent_$associationId');
    pp('$newMM ..... FCM: subscribed to userGeofenceEvent_$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('vehicle_media_request_$associationId');
    pp('$newMM ..... FCM: subscribed to vehicle_media_request_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('commuterRequest_$associationId');
    pp('$newMM ..... FCM: subscribed to commuterRequest_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('heartbeat_$associationId');
    pp('$newMM ..... FCM: subscribed to heartbeat_$associationId');

    pp('$newMM ..... FCM: subscribed to all ${E.pear} 12 (twelve) KasieTransie FCM topics\n\n');
    //
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    pp("$newMM onDidReceiveLocalNotification: $red processing message title: $title body: $body ");
  }

  Future<void> processFCMMessage(fb.RemoteMessage message, String type) async {
    pp("$newMM processFCMMessage: $red processing message received: see below: $type ...");
    final map = message.data;
    myPrettyJsonPrint(map);
    pp('$newMM .... what the fuck is the type?? ${E.redDot} $type demoFlag: $demoFlag}');

    switch (type) {
      case Constants.routeChanges:
        _routeChangesStreamController.sink.add(map[Constants.routeChanges] as String);
        refreshRoute(map[Constants.routeChanges] as String);
        break;
      case Constants.vehicleChanges:
        _vehicleChangesStreamController.sink
            .add(map[Constants.vehicleChanges] as String);
        break;
      case Constants.vehicleArrival:
        final va = map[Constants.vehicleArrival];
        final x = jsonDecode(va);
        _vehicleArrivalStreamController.sink.add(buildVehicleArrival(x));
        break;
      case Constants.vehicleDeparture:
        final va = map[Constants.vehicleDeparture];
        final x = jsonDecode(va);
        _vehicleDepartureStreamController.sink.add(buildVehicleDeparture(x));
        break;
      case Constants.dispatchRecord:
        pp('$newMM .... dispatchRecord in the switch?  ${E.redDot} $type');

        final va = map[Constants.dispatchRecord];
        final x = jsonDecode(va);
        final kk = buildDispatchRecord(x);
        _processDispatchRecord(kk);
        break;
      case Constants.passengerCount:
        pp('$newMM .... passengerCount in the switch?  ${E.redDot} $type');

        final va = map[Constants.passengerCount];
        final x = jsonDecode(va);
        final kk = buildAmbassadorPassengerCount(x);
        _processPassengerCount(kk);
        break;
      case Constants.heartbeat:
        pp('$newMM .... heartbeat in the switch?  ${E.redDot} $type');

        final va = map[Constants.heartbeat];
        final x = jsonDecode(va);
        final kk = buildVehicleHeartbeat(x);
        _processHeartbeat(kk);
        break;
      case Constants.commuterRequest:
        pp('$newMM .... commuterRequest in the switch?  ${E.redDot} $type');

        final va = map[Constants.commuterRequest];
        final x = jsonDecode(va);
        final kk = buildCommuterRequest(x);
        _processCommuterRequest(kk);
        break;
      case Constants.locationRequest:
        final va = map[Constants.locationRequest];
        final x = jsonDecode(va);
        //todo - respond if it the request is for you
        final locReq = buildLocationRequest(x);
        _processLocationRequest(locReq);
        break;
      case Constants.locationResponse:
        final va = map[Constants.locationResponse];
        final x = jsonDecode(va);
        final resp = buildLocationResponse(x);
        _processLocationResponse(resp);
        break;
      case Constants.userGeofenceEvent:
        final va = map[Constants.userGeofenceEvent];
        final x = jsonDecode(va);
        _userGeofenceStreamController.sink.add(buildUserGeofenceEvent(x));
        break;
      case Constants.vehicleMediaRequest:
        final va = map[Constants.vehicleMediaRequest];
        final x = jsonDecode(va);
        final req = buildVehicleMediaRequest(x);
        _processMediaRequest(req);
        break;

      case Constants.routeUpdateRequest:
        final va = map[Constants.routeUpdateRequest];
        final x = jsonDecode(va);
        final req = buildRouteUpdateRequest(x);
        _processRouteUpdate(req);
        break;

      default:
        pp('$newMM ... SWITCH statement fell all the way through: type: $type ... ');
        break;

    }
  }

  void _processDispatchRecord(lib.DispatchRecord dispatchRecord) {
    if (demoFlag) {
      _dispatchStreamController.sink.add(dispatchRecord);
      return;
    }
    if (user != null) {
      if (user!.userId == dispatchRecord.marshalId ||
          user!.userId == dispatchRecord.ownerId ||
          user!.userType == 'ASSOCIATION_OFFICIAL') {
        _dispatchStreamController.sink.add(dispatchRecord);
      }
    }
  }

  void _processRouteUpdate(lib.RouteUpdateRequest req) async {
    pp('$newMM ... _processRouteUpdate ');
    await routesIsolate.getRoute(req.associationId!, req.routeId!);
    _routeUpdateRequestStreamController.sink.add(req);
  }

  void _processLocationResponse(lib.LocationResponse resp) async {
    pp('$newMM ... _processLocationResponse ... ');
    myPrettyJsonPrint(resp.toJson());
    if (user == null) {
      return;
    }
    if (user!.userId == resp.userId) {
      _locationResponseStreamController.sink.add(resp);
    }
  }

  void _processMediaRequest(lib.VehicleMediaRequest req) async {
    pp('$newMM ... _processMediaRequest ... ');

    if (user != null) {
      if (user!.userId == req.userId) {
        pp('\n$newMM ... IGNORE ... this is my own request ....');
      } else {
        pp('\n\n$newMM ... ACCEPT ... refreshing assoc requests ${E.blueDot} ...');
        final startDate = DateTime.now()
            .toUtc()
            .subtract(const Duration(hours: 4))
            .toIso8601String();
        await listApiDog.getAssociationVehicleMediaRequests(
            req.associationId!, startDate, true);
        _vehicleMediaRequestStreamController.sink.add(req);
      }
    }
    if (car != null) {
      if (car!.vehicleId == req.vehicleId) {
        pp('\n\n$newMM ... ACCEPT ... this request is for me! ${E.blueDot} '
            'what now, Boss? ...');
        _vehicleMediaRequestStreamController.sink.add(req);
      }
    }
  }

  void _processPassengerCount(lib.AmbassadorPassengerCount passengerCount) {
    pp('$newMM ... _processPassengerCount ... ');

    if (demoFlag) {
      _passengerCountStreamController.sink.add(passengerCount);
      return;
    }
    pp('$mm _processPassengerCount ... ${E.redDot} check ownerId : ${passengerCount.userId} - userId: ${user!.userId}');
    if (user!.userId == passengerCount.ownerId) {
      _passengerCountStreamController.sink.add(passengerCount);
      pp('$mm _processPassengerCount: _passengerCountStreamController '
          'has a new AmbassadorPassengerCount: ');
      myPrettyJsonPrint(passengerCount.toJson());
      return;
    }
    if (user!.userType == 'ASSOCIATION_OFFICIAL' || demoFlag) {
      _passengerCountStreamController.sink.add(passengerCount);
      return;
    }
  }

  void _processCommuterRequest(lib.CommuterRequest commuterRequest) {
    pp('$mm _processCommuterRequest ... ');

    if (demoFlag) {
      _commuterRequestStreamController.sink.add(commuterRequest);
      return;
    }
    if (user!.userType == Constants.ASSOCIATION_OFFICIAL ||
        user!.userType == Constants.AMBASSADOR ||
        user!.userType == Constants.MARSHAL) {
      _commuterRequestStreamController.sink.add(commuterRequest);
      return;
    }
  }

  void _processHeartbeat(lib.VehicleHeartbeat heartbeat) {
    pp('$mm _processHeartbeat ... ');
    if (demoFlag) {
      _heartbeatStreamController.sink.add(heartbeat);
      return;
    }
    if (user!.userType == Constants.ASSOCIATION_OFFICIAL ||
        user!.userType == Constants.AMBASSADOR ||
        user!.userType == Constants.MARSHAL ||
        demoFlag) {
      _heartbeatStreamController.sink.add(heartbeat);
      return;
    }
  }

  void _processLocationRequest(lib.LocationRequest request) async {
    pp('$newMM checking if vehicle location request is for me ...');
    final car = await prefs.getCar();
    if (car == null) {
      pp('$newMM location request is NOT for me. ${E.redDot}${E.redDot}${E.redDot} ');
      return;
    }
    if (request.vehicleId == car.vehicleId) {
      pp('$newMM location request is for me! ... must respond!!');
      final loc = await locationBloc.getLocation();
      final resp = lib.LocationResponse(
        ObjectId(),
        associationId: car.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        userId: request.userId,
        userName: request.userName,
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        position: lib.Position(
          type: point,
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
      try {
        pp('$newMM sending location response! ${E.blueDot}');
        final result = await dataApiDog.addLocationResponse(resp);
        pp('$newMM location response successfully sent! ${E.leaf} ');
        myPrettyJsonPrint(result.toJson());
      } catch (e) {
        pp(e);
      }
    } else {
      pp('$newMM ... nice try, but this location request is definitely not for me. ${E.blueDot}');
    }
  }

  void refreshRoute(String routeId) async {
    pp('$newMM .. refresh route: $routeId');
    final bag = await listApiDog.refreshRoute(routeId);
    pp('\n\n$newMM bag has arrived in fcmBloc. Seems like everything is OK, Boss! '
        'route refreshed: ${E.nice}${E.nice} ${bag.route!.name} ${E.nice}\n');
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    pp("$newMM onDidReceiveNotificationResponse: $red details: ${details.payload} ");
  }

  final StreamController<String> _routeChangesStreamController =
      StreamController.broadcast();

  Stream<String> get routeChangesStream => _routeChangesStreamController.stream;

  final StreamController<String> _vehicleChangesStreamController =
      StreamController.broadcast();

  Stream<String> get vehicleChangesStream =>
      _vehicleChangesStreamController.stream;

  final StreamController<lib.VehicleDeparture>
      _vehicleDepartureStreamController = StreamController.broadcast();

  Stream<lib.VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureStreamController.stream;

  final StreamController<lib.VehicleArrival> _vehicleArrivalStreamController =
      StreamController.broadcast();

  Stream<lib.VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalStreamController.stream;

  final StreamController<lib.DispatchRecord> _dispatchStreamController =
      StreamController.broadcast();

  Stream<lib.DispatchRecord> get dispatchStream =>
      _dispatchStreamController.stream;

  final StreamController<lib.UserGeofenceEvent> _userGeofenceStreamController =
      StreamController.broadcast();

  Stream<lib.UserGeofenceEvent> get userGeofenceStream =>
      _userGeofenceStreamController.stream;

  final StreamController<lib.VehicleMediaRequest>
      _vehicleMediaRequestStreamController = StreamController.broadcast();
  final StreamController<lib.RouteUpdateRequest>
      _routeUpdateRequestStreamController = StreamController.broadcast();

  final StreamController<lib.CommuterRequest> _commuterRequestStreamController =
      StreamController.broadcast();
  Stream<lib.CommuterRequest> get commuterRequestStreamStream =>
      _commuterRequestStreamController.stream;

  final StreamController<lib.VehicleHeartbeat> _heartbeatStreamController =
      StreamController.broadcast();
  Stream<lib.VehicleHeartbeat> get heartbeatStreamStream =>
      _heartbeatStreamController.stream;

  Stream<lib.RouteUpdateRequest> get routeUpdateRequestStream =>
      _routeUpdateRequestStreamController.stream;

  Stream<lib.VehicleMediaRequest> get vehicleMediaRequestStream =>
      _vehicleMediaRequestStreamController.stream;

  final StreamController<lib.LocationRequest> _locationRequestStreamController =
      StreamController.broadcast();

  Stream<lib.LocationRequest> get locationRequestStream =>
      _locationRequestStreamController.stream;

  final StreamController<lib.LocationResponse>
      _locationResponseStreamController = StreamController.broadcast();

  Stream<lib.LocationResponse> get locationResponseStream =>
      _locationResponseStreamController.stream;

  final StreamController<lib.AmbassadorPassengerCount>
      _passengerCountStreamController = StreamController.broadcast();

  Stream<lib.AmbassadorPassengerCount> get passengerCountStream =>
      _passengerCountStreamController.stream;
}

///Handling FCM messages in the background
///
String? myName;
var mxx = '💙💙💙💙💙💙 Background Processing:  💙💙💙💙💙💙';

Future<void> kasieFirebaseMessagingBackgroundHandler(
    fb.RemoteMessage message) async {
  pp("\n\n\n$mxx kasieFirebaseMessagingBackgroundHandler: "
      "🍎🍎🍎🍎 data: ${message.data}, will handle it happily! 🍎🍎🍎🍎");
  myPrettyJsonPrint(message.data);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  myName = packageInfo.appName;
  pp('$mxx .... App Name: $myName');

  final map = message.data;

  if (map['locationRequest'] != null) {
    handleLocationRequest(map);
  }

  if (map['dispatchRecord'] != null) {
    handleDispatch(map);
  }

  if (map['passengerCount'] != null) {
    handlePassengerCount(map);
  }
}

void handlePassengerCount(Map<String, dynamic> map) async {
  final user = await _getUser(map);

  if (user != null) {
    final passengerCount = buildAmbassadorPassengerCount(map);

    if (user.userType == Constants.OWNER) {
      if (user.userId == passengerCount.ownerId) {
        cachePassengerCount(passengerCount);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      cachePassengerCount(passengerCount);
    }
  }
}

void handleDispatch(Map<String, dynamic> map) async {
  final user = await _getUser(map);

  if (user != null) {
    final dispatchRecord = buildDispatchRecord(map);

    if (user.userType == Constants.OWNER) {
      if (user.userId == dispatchRecord.ownerId) {
        cacheDispatchRecord(dispatchRecord);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      cacheDispatchRecord(dispatchRecord);
    }
  }
}

void cachePassengerCount(lib.AmbassadorPassengerCount object) {
  listApiDog.realm.write(() {
    listApiDog.realm.add<lib.AmbassadorPassengerCount>(object);
  });
}

void cacheDispatchRecord(lib.DispatchRecord object) {
  listApiDog.realm.write(() {
    listApiDog.realm.add<lib.DispatchRecord>(object);
  });
}

Future<lib.User?> _getUser(Map map) async {
  lib.User? user;
  final prefs1 = await SharedPreferences.getInstance();
  prefs1.reload(); // The magic line
  var string = prefs1.getString('user');
  if (string == null) {
    pp('\n\n$mxx ... ${E.redDot}${E.redDot}${E.redDot} user is null in background ... \n\n');
    return null;
  }
  var jx = json.decode(string);
  user = buildUser(jx);
  pp('$mxx ... this user is responding while in background');
  myPrettyJsonPrint(user.toJson());

  return user;
}

void handleLocationRequest(Map map) async {
  lib.Vehicle? car;
  final prefs1 = await SharedPreferences.getInstance();
  prefs1.reload(); // The magic line
  var string = prefs1.getString('car');
  if (string == null) {
    pp('\n\n$mxx ... ${E.redDot}${E.redDot}${E.redDot} car is null in background ... \n\n');
    return;
  }
  var jx = json.decode(string);
  car = buildVehicle(jx);
  pp('$mxx ... this car is responding while in background');
  myPrettyJsonPrint(car.toJson());

  final va = map['locationRequest'];
  final x = jsonDecode(va);
  final locReq = buildLocationRequest(x);
  if (car.vehicleId == locReq.vehicleId) {
    pp('\n\n$mxx ... this request is for me .... ${E.blueDot} gotta respond!');
    respondToLocationRequest(request: locReq, token: 'myToken', car: car);
  }
}

void respondToLocationRequest(
    {required lib.LocationRequest request,
    required String token,
    required lib.Vehicle car}) async {
  final loc = await locationBloc.getLocation();
  pp('$mxx .. location in background: $loc');
  final resp = lib.LocationResponse(
    ObjectId(),
    associationId: car.associationId,
    created: DateTime.now().toUtc().toIso8601String(),
    userId: request.userId,
    userName: request.userName,
    vehicleId: car.vehicleId,
    vehicleReg: car.vehicleReg,
    position: lib.Position(
      type: point,
      coordinates: [loc.longitude, loc.latitude],
      latitude: loc.latitude,
      longitude: loc.longitude,
    ),
  );
  try {
    pp('$mxx sending background location response! ${E.blueDot}');
    final result = await _sendLocationResponse(resp, token);
    pp('$mxx background location response successfully sent! ${E.leaf} ');
    myPrettyJsonPrint(result);
  } catch (e) {
    pp(e);
  }
}

Future _sendLocationResponse(lib.LocationResponse resp, String fcmToken) async {
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final urlPrefix = KasieEnvironment.getUrl();
  final mUrl = '${urlPrefix}addLocationResponse';
  pp('$mxx _sendLocationResponse: 🔆🔆🔆 ...... calling : 💙 $mUrl  💙');

  String? mBag;
  mBag = json.encode(resp.toJson());

  var start = DateTime.now();
  headers['Authorization'] = 'Bearer $fcmToken';
  final client = http.Client();
  try {
    var resp = await client
        .post(
          Uri.parse(mUrl),
          body: mBag,
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      pp('$mxx  _sendLocationResponse RESPONSE: 💙💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
    } else {
      pp('$mxx  👿👿👿_sendLocationResponse: 🔆 statusCode: 👿👿👿 ${resp.statusCode} 🔆🔆🔆 for $mUrl');
      pp(resp.body);
      throw KasieException(
          message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
    }
    var end = DateTime.now();
    pp('$mxx  _sendLocationResponse: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
    try {
      var mJson = json.decode(resp.body);
      return mJson;
    } catch (e) {
      pp("$mxx 👿👿👿👿👿👿👿 json.decode failed, returning response body");
      return resp.body;
    }
  } on SocketException {
    pp('$mxx  SocketException: really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);
    errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$mxx  HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$mxx  Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$mxx  No Internet connection. Request has timed out in 30 seconds 👎");
    final gex = KasieException(
        message: 'Request timed out. No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    errorHandler.handleError(exception: gex);
    throw gex;
  }
}
