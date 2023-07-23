import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const mm = '🌸🌸🌸🌸🌸🌸 🔵🔵️ LocalNotificationService: 🌸🌸🌸: ';

  static void initialize() {
    pp('$mm Initialization setting for android ........');
    // const InitializationSettings initializationSettingsAndroid =
    //     InitializationSettings(
    //         android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    // _notificationsPlugin.initialize(
    //   initializationSettingsAndroid,
    //   // to handle event when we receive notification
    //   onDidReceiveNotificationResponse: (details) {
    //     if (details.input != null) {}
    //   },
    // );
  }

  static Future<void> display(RemoteMessage message) async {
    // To display the notification in device
    try {
      pp('$mm ${message.notification!.android!.sound}');
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            message.notification!.android!.sound ?? "Channel Id",
            message.notification!.android!.sound ?? "Main Channel",
            groupKey: "gfg",
            color: Colors.green,
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound(
                message.notification!.android!.sound ?? "gfg"),

            // different sound for
            // different notification
            playSound: true,
            priority: Priority.high),
      );
      await _notificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, notificationDetails,
          payload: message.data['route']);
    } catch (e) {
      pp(e.toString());
    }
  }
}
