import 'package:firebase_messaging/firebase_messaging.dart' as fb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/schemas.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

late FCMBloc fcmBloc;
class FCMBloc {
  final fb.FirebaseMessaging firebaseMessaging;
  final mm = '🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 FCMBloc: 🔵🔵 ';

  FCMBloc(this.firebaseMessaging);

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
      if (message.data['activity'] != null) {
        pp("$mm onMessage: $red activity message has arrived!  ... $red ");
      } else if (message.data['geofenceEvent'] != null) {
        pp("$mm onMessage: $red geofenceEvent message has arrived!  ... $red ");
      } else if (message.data['locationRequest'] != null) {
        pp("$mm onMessage: $red locationRequest message has arrived!  ... $red ");
      } else if (message.data['locationResponse'] != null) {
        pp("$mm onMessage: $red locationResponse message has arrived!  ... $red ");
      } else if (message.data['user'] != null) {
        pp("$mm onMessage: $red user message has arrived!  ... $red\n ");
      } else {
        pp("$mm onMessage: $red some other geo message has arrived!  ... $red ");
      }
      processFCMMessage(message);
    });

    fb.FirebaseMessaging.onBackgroundMessage(
        kasieFirebaseMessagingBackgroundHandler);

    fb.FirebaseMessaging.onMessageOpenedApp.listen((fb.RemoteMessage message) {
      pp('$mm onMessageOpenedApp:  $red A new onMessageOpenedApp event was published! ${message.data}');
    });

    pp("\n\n$mm FCM : FIREBASE MESSAGING initialization done! - "
        "will subscribeToTopics() ...........................");

    var msg = await fb.FirebaseMessaging.instance.getInitialMessage();
    if (msg != null) {
      processFCMMessage(msg);
    }
    fb.FirebaseMessaging.onMessageOpenedApp.listen((event) {
      processFCMMessage(event);
    });

    subscribeToTopics();
  }
  static const red = '🍎 🍎';
  Future<void> subscribeToTopics() async {
    var user = await prefs.getUser();
    if (user == null) {
      return;
    }
    pp("$mm subscribeToTopics: $red subscribe to all KasieTransie FCM topics ... ");

    await firebaseMessaging
        .subscribeToTopic('vehicleArrival_${user!.associationId}');
    pp('$mm ..... FCM: subscribed to vehicle_arrival_${user.associationId}');
    //
    await firebaseMessaging
        .subscribeToTopic('vehicleDeparture_${user.associationId}');
    pp('$mm ..... FCM: subscribed to vehicle_departure_${user.associationId}');
    //
    await firebaseMessaging
        .subscribeToTopic('dispatchRecord_${user.associationId}');
    pp('$mm ..... FCM: subscribed to dispatchRecord_${user.associationId}');
    //
    await firebaseMessaging
        .subscribeToTopic('locationResponse_${user.associationId}');
    pp('$mm ..... FCM: subscribed to locationResponse_${user.associationId}');
    //
    await firebaseMessaging
        .subscribeToTopic('locationRequest_${user.associationId}');
    pp('$mm ..... FCM: subscribed to locationRequest_${user.associationId}');
    //
    await firebaseMessaging
        .subscribeToTopic('userGeofenceEvent_${user.associationId}');
    pp('$mm ..... FCM: subscribed to userGeofenceEvent_${user.associationId}');
    //

    pp('$mm ..... FCM: subscribed to all KasieTransie FCM topics\n\n');
    //

  }
  
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    pp("$mm onDidReceiveLocalNotification: $red processing message title: $title body: $body ");

  }

  void processFCMMessage(fb.RemoteMessage message) {
    pp("$mm processFCMMessage: $red processing message received: ${message.data} ");

  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    pp("$mm onDidReceiveNotificationResponse: $red details: ${details.payload} ");

  }
}

Future<void> kasieFirebaseMessagingBackgroundHandler(
    fb.RemoteMessage message) async {
  pp("🍎🍎 kasieFirebaseMessagingBackgroundHandler: data: ${message.data} ");

}
