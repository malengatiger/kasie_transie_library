import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart' as fb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../bloc/list_api_dog.dart';
import '../utils/functions.dart';
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
      String type = '';
      if (message.data['routeChanges'] != null) {
        pp("$mm onMessage: $red routeChanges message has arrived!  ... $red ");
        type = 'routeChanges';
      } else if (message.data['vehicleChanges'] != null) {
        pp("$mm onMessage: $red vehicleChanges message has arrived!  ... $red ");
        type = 'vehicleChanges' ;
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
      } else if (message.data['userGeofenceEvent'] != null){
        pp("$mm onMessage: $red userGeofenceEvent message has arrived!  ... $red ");
        type = 'userGeofenceEvent';
      } else {
        pp("$mm onMessage: $red unknown message has arrived!  ... $red ");
        return;
      }
      //
      processFCMMessage(message, type);

    });

    fb.FirebaseMessaging.onBackgroundMessage(
        kasieFirebaseMessagingBackgroundHandler);

    fb.FirebaseMessaging.onMessageOpenedApp.listen((fb.RemoteMessage message) {
      pp('$mm onMessageOpenedApp:  $red A new onMessageOpenedApp event was published! ${message.data}');
    });

    pp("\n\n$mm FCM : FIREBASE MESSAGING initialization done! - ${E.nice} "
        "will subscribeToTopics() ...........................");

    // var msg = await fb.FirebaseMessaging.instance.getInitialMessage();
    // if (msg != null) {
    //   processFCMMessage(msg);
    // }
    // fb.FirebaseMessaging.onMessageOpenedApp.listen((event) {
    //   processFCMMessage(event);
    // });
    //
    // // subscribeToTopics();
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
    pp("$mm processFCMMessage: $red processing message received: ");
    myPrettyJsonPrint(message.data);
    switch (type) {
      case 'routeChanges':
        _routeChangesStreamController.sink.add(message.data['routeChanges'] as String);
        refreshRoute(message.data['routeChanges'] as String);
        break;
      case 'vehicleChanges':
        _vehicleChangesStreamController.sink.add(message.data['vehicleChanges'] as String);
        break;
      case 'vehicleArrival':
        _vehicleArrivalStreamController.sink.add(buildVehicleArrival(message.data));
        break;
      case 'vehicleDeparture':
        _vehicleDepartureStreamController.sink.add(buildVehicleDeparture(message.data));
        break;
      case 'dispatchRecord':
        _dispatchStreamController.sink.add(buildDispatchRecord(message.data));
        break;
      case 'locationRequest':
        _locationRequestStreamController.sink.add(buildLocationRequest(message.data));
        break;
      case 'locationResponse':
        _locationResponseStreamController.sink.add(buildLocationResponse(message.data));
        break;
      case 'userGeofenceEvent':
        _userGeofenceStreamController.sink.add(buildUserGeofenceEvent(message.data));
        break;
    }
  }
  void refreshRoute(String routeId) async {
    pp('$mm .. refresh route: $routeId');
    final bag = await listApiDog.refreshRoute(routeId);
    pp('\n\n$mm bag has arrived in fcmBloc. Seems like everything is OK, Boss! '
        'route refreshed: ${E.nice}${E.nice} ${bag.route!.name} ${E.nice}\n');
  }
  final StreamController<String> _routeChangesStreamController = StreamController.broadcast();
  Stream<String> get routeChangesStream => _routeChangesStreamController.stream;

  final StreamController<String> _vehicleChangesStreamController = StreamController.broadcast();
  Stream<String> get vehicleChangesStream => _vehicleChangesStreamController.stream;

  final StreamController<VehicleDeparture> _vehicleDepartureStreamController = StreamController.broadcast();
  Stream<VehicleDeparture> get vehicleDepartureStream => _vehicleDepartureStreamController.stream;

  final StreamController<VehicleArrival> _vehicleArrivalStreamController = StreamController.broadcast();
  Stream<VehicleArrival> get vehicleArrivalStream => _vehicleArrivalStreamController.stream;

  final StreamController<DispatchRecord> _dispatchStreamController = StreamController.broadcast();
  Stream<DispatchRecord> get dispatchStream => _dispatchStreamController.stream;

  final StreamController<UserGeofenceEvent> _userGeofenceStreamController = StreamController.broadcast();
  Stream<UserGeofenceEvent> get userGeofenceStream => _userGeofenceStreamController.stream;

  //todo - add location request and response
  final StreamController<LocationRequest> _locationRequestStreamController = StreamController.broadcast();
  Stream<LocationRequest> get locationRequestStream => _locationRequestStreamController.stream;

  final StreamController<LocationResponse> _locationResponseStreamController = StreamController.broadcast();
  Stream<LocationResponse> get locationResponseStream => _locationResponseStreamController.stream;




  void onDidReceiveNotificationResponse(NotificationResponse details) {
    pp("$mm onDidReceiveNotificationResponse: $red details: ${details.payload} ");
  }
}

Future<void> kasieFirebaseMessagingBackgroundHandler(
    fb.RemoteMessage message) async {
  pp("🍎🍎 kasieFirebaseMessagingBackgroundHandler: data: ${message.data} ");
}
