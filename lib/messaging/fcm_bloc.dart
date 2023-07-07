import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:realm/realm.dart';

import '../bloc/list_api_dog.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';
import '../utils/prefs.dart';

final FCMBloc fcmBloc = FCMBloc(fb.FirebaseMessaging.instance);

class FCMBloc {
  final fb.FirebaseMessaging firebaseMessaging;
  final mm = '🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 FCMBloc: 🔵🔵 ';

  FCMBloc(this.firebaseMessaging) {
    initialize();
  }

  Future initialize() async {
    pp('$mm ... FirebaseMessaging initialize starting ...');
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
      // user!.fcmRegistration = newToken;
      // dataApiDog.updateUser(user!);
    });

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
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
      // RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      //
      processFCMMessage(message, getMessageType(message));
    });

    fb.FirebaseMessaging.onBackgroundMessage(
        kasieFirebaseMessagingBackgroundHandler);

    fb.FirebaseMessaging.onMessageOpenedApp.listen((fb.RemoteMessage message) {
      pp('$mm onMessageOpenedApp:  $red A new onMessageOpenedApp event was published! ${message.data}');
    });

    pp("\n\n$mm FCM : FIREBASE MESSAGING initialization done! - ${E.nice} "
        "will subscribeToTopics() ...........................");
  }

  String getMessageType(fb.RemoteMessage message) {
    var type = '';
    if (message.data['routeChanges'] != null) {
      pp("$mm onMessage: $red routeChanges message has arrived!  ... $red ");
      type = 'routeChanges';
    } else if (message.data['vehicleChanges'] != null) {
      pp("$mm onMessage: $red vehicleChanges message has arrived!  ... $red ");
      type = 'vehicleChanges';
    } else if (message.data['locationRequest'] != null) {
      pp("$mm onMessage: $red locationRequest message has arrived!  ... $red ");
      type = 'locationRequest';
    } else if (message.data['locationResponse'] != null) {
      pp("$mm onMessage: $red locationResponse message has arrived!  ... $red ");
      type = 'locationResponse';
    } else if (message.data['vehicleArrival'] != null) {
      pp("$mm onMessage: $red vehicleArrival message has arrived!  ... $red\n ");
      type = 'vehicleArrival';
    } else if (message.data['vehicleDeparture'] != null) {
      pp("$mm onMessage: $red vehicleDeparture message has arrived!  ... $red ");
      type = 'vehicleDeparture';
    } else if (message.data['dispatchRecord'] != null) {
      pp("$mm onMessage: $red dispatchRecord message has arrived!  ... $red ");
      type = 'dispatchRecord';
    } else if (message.data['userGeofenceEvent'] != null) {
      pp("$mm onMessage: $red userGeofenceEvent message has arrived!  ... $red ");
      type = 'userGeofenceEvent';
    } else {
      pp("$mm onMessage: $red unknown message has arrived!  ... $red ");
      return 'unknown';
    }
    return type;
  }

  static const red = '🍎 🍎';

  Future<void> subscribeToTopics() async {
    var user = await prefs.getUser();
    var car = await prefs.getCar();
    String? associationId;
    if (user != null) {
      associationId = user.associationId!;
    }
    if (car != null) {
      associationId = car.associationId!;
    }
    if (associationId == null) {
      return;
    }
    pp("$mm subscribeToTopics: $red subscribe to all KasieTransie FCM topics ... ");

    await firebaseMessaging.subscribeToTopic('vehicle_changes_$associationId');
    pp('$mm ..... FCM: subscribed to vehicle_changes_$associationId');

    await firebaseMessaging.subscribeToTopic('route_changes_$associationId');
    pp('$mm ..... FCM: subscribed to route_changes_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('vehicleArrival_$associationId');
    pp('$mm ..... FCM: subscribed to vehicle_arrival_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('vehicleDeparture_$associationId');
    pp('$mm ..... FCM: subscribed to vehicle_departure_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('dispatchRecord_$associationId');
    pp('$mm ..... FCM: subscribed to dispatchRecord_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('locationResponse_$associationId');
    pp('$mm ..... FCM: subscribed to locationResponse_$associationId');
    //
    await firebaseMessaging.subscribeToTopic('locationRequest_$associationId');
    pp('$mm ..... FCM: subscribed to locationRequest_$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('userGeofenceEvent_$associationId');
    pp('$mm ..... FCM: subscribed to userGeofenceEvent_$associationId');
    //

    pp('$mm ..... FCM: subscribed to all KasieTransie FCM topics\n\n');
    //
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    pp("$mm onDidReceiveLocalNotification: $red processing message title: $title body: $body ");
  }

  void processFCMMessage(fb.RemoteMessage message, String type) {
    pp("$mm processFCMMessage: $red processing message received: see below ...");
    final map = message.data;
    myPrettyJsonPrint(map);
    switch (type) {
      case 'routeChanges':
        _routeChangesStreamController.sink.add(map['routeChanges'] as String);
        refreshRoute(map['routeChanges'] as String);
        break;
      case 'vehicleChanges':
        _vehicleChangesStreamController.sink
            .add(map['vehicleChanges'] as String);
        break;
      case 'vehicleArrival':
        final va = map['vehicleArrival'];
        final x = jsonDecode(va);
        _vehicleArrivalStreamController.sink.add(buildVehicleArrival(x));
        break;
      case 'vehicleDeparture':
        final va = map['vehicleDeparture'];
        final x = jsonDecode(va);
        _vehicleDepartureStreamController.sink.add(buildVehicleDeparture(x));
        break;
      case 'dispatchRecord':
        final va = map['dispatchRecord'];
        final x = jsonDecode(va);
        _dispatchStreamController.sink.add(buildDispatchRecord(x));
        break;
      case 'locationRequest':
        final va = map['locationRequest'];
        final x = jsonDecode(va);
        //todo - respond if it the request is for you
        final locReq = buildLocationRequest(x);
        _locationRequestStreamController.sink.add(locReq);
        _respondToLocationRequest(locReq);
        break;
      case 'locationResponse':
        final va = map['locationResponse'];
        final x = jsonDecode(va);
        pp('$mm ${E.redDot} location response raw: check registration ... ${E.redDot}\n$x');
        final resp = buildLocationResponse(x);
        pp('$mm ... to be put into _locationResponseStreamController ... check for null');
        myPrettyJsonPrint(resp.toJson());
        _locationResponseStreamController.sink.add(resp);
        break;
      case 'userGeofenceEvent':
        final va = map['userGeofenceEvent'];
        final x = jsonDecode(va);
        _userGeofenceStreamController.sink.add(buildUserGeofenceEvent(x));
        break;
    }
  }

  void _respondToLocationRequest(LocationRequest request) async {
    pp('$mm checking if location request is for me');
    final car = await prefs.getCar();
    if (car == null) {
      pp('$mm location request is NOT for me. ${E.redDot}${E.redDot}${E.redDot} '
          'CAR is NULL. What the fuck!');
      return;
    }
    if (request.vehicleId == car.vehicleId) {
      pp('$mm location request is for me! ... must respond!!');
      final loc = await locationBloc.getLocation();
      final resp = LocationResponse(
        ObjectId(),
        associationId: car.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        userId: request.userId,
        userName: request.userName,
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        position: Position(
          type: point,
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
      try {
        pp('$mm sending location response! ${E.blueDot}');
        final result = await dataApiDog.addLocationResponse(resp);
        pp('$mm location response successfully sent! ${E.leaf} ');
        myPrettyJsonPrint(result.toJson());
      } catch (e) {
        pp(e);
      }
    } else {
      pp('$mm ... nice try, but this location request is definitely not for me. ${E.blueDot}');
    }
  }

  void refreshRoute(String routeId) async {
    pp('$mm .. refresh route: $routeId');
    final bag = await listApiDog.refreshRoute(routeId);
    pp('\n\n$mm bag has arrived in fcmBloc. Seems like everything is OK, Boss! '
        'route refreshed: ${E.nice}${E.nice} ${bag.route!.name} ${E.nice}\n');
  }

  final StreamController<String> _routeChangesStreamController =
      StreamController.broadcast();

  Stream<String> get routeChangesStream => _routeChangesStreamController.stream;

  final StreamController<String> _vehicleChangesStreamController =
      StreamController.broadcast();

  Stream<String> get vehicleChangesStream =>
      _vehicleChangesStreamController.stream;

  final StreamController<VehicleDeparture> _vehicleDepartureStreamController =
      StreamController.broadcast();

  Stream<VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureStreamController.stream;

  final StreamController<VehicleArrival> _vehicleArrivalStreamController =
      StreamController.broadcast();

  Stream<VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalStreamController.stream;

  final StreamController<DispatchRecord> _dispatchStreamController =
      StreamController.broadcast();

  Stream<DispatchRecord> get dispatchStream => _dispatchStreamController.stream;

  final StreamController<UserGeofenceEvent> _userGeofenceStreamController =
      StreamController.broadcast();

  Stream<UserGeofenceEvent> get userGeofenceStream =>
      _userGeofenceStreamController.stream;

  //todo - add location request and response
  final StreamController<LocationRequest> _locationRequestStreamController =
      StreamController.broadcast();

  Stream<LocationRequest> get locationRequestStream =>
      _locationRequestStreamController.stream;

  final StreamController<LocationResponse> _locationResponseStreamController =
      StreamController.broadcast();

  Stream<LocationResponse> get locationResponseStream =>
      _locationResponseStreamController.stream;

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    pp("$mm onDidReceiveNotificationResponse: $red details: ${details.payload} ");
  }
}

const mxx = ' 💙💙Background Processing  💙💙';

///Handling FCM messages in the background
///
Future<void> kasieFirebaseMessagingBackgroundHandler(
    fb.RemoteMessage message) async {
  pp("\n\n\n🍎🍎🍎🍎🍎🍎🍎🍎 kasieFirebaseMessagingBackgroundHandler: "
      "data: ${message.data}, will handle it happily! 🍎🍎🍎🍎");

  await Firebase.initializeApp();
  pp('$mxx ... Firebase.initializeApp done and dusted!');
  var myToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (myToken == null) {
    pp('\n$mxx unable to get auth token ${E.redDot}${E.redDot}${E.redDot}');
    return;
  }
  final car = await prefs.getCar();
  if (car == null) {
    pp('... car is null in background ...');
    return;
  }
  final map = message.data;

  if (map['locationRequest'] != null) {
    final va = map['locationRequest'];
    final x = jsonDecode(va);
    final locReq = buildLocationRequest(x);
    if (car.vehicleId == locReq.vehicleId) {
      pp('\n\n$mxx ... this request is for me .... ${E.blueDot} gotta respond!');
      _respondToLocationRequest(request: locReq, token: myToken, car: car);
    }
  } else {
    pp('$mxx ... this is a non location request message, ignored for now!');
  }
}

void _respondToLocationRequest(
    {required LocationRequest request,
    required String token,
    required Vehicle car}) async {
  final loc = await locationBloc.getLocation();
  pp('$mxx .. location in background: $loc');
  final resp = LocationResponse(
    ObjectId(),
    associationId: car.associationId,
    created: DateTime.now().toUtc().toIso8601String(),
    userId: request.userId,
    userName: request.userName,
    vehicleId: car.vehicleId,
    vehicleReg: car.vehicleReg,
    position: Position(
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

Future _sendLocationResponse(LocationResponse resp, String fcmToken) async {
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
