import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'custom_notification_channel_id',
  'Notification',
  description: 'notifications from Your App Name.',
  importance: Importance.high,
);

abstract class LocalNotificationInfo {
  Future<void> init();
  Future<void> show({
    required RemoteMessage message,
  });
}

class LocalNotificationInfoImpl implements LocalNotificationInfo {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const LocalNotificationInfoImpl({
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  Future<void> init() async {
    try {
      log("---- Initializing Local Notification ----");
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOs = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOs,
      );

      // when the app is in the foreground and notification clicked
      final result = await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      log("---- Result: $result ----");

      log("---- Initialized Local Notification ----");
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> show({
    required RemoteMessage message,
  }) async {
    try {
      log("---- Showing Local Notification ----");
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? androidNotification =
          message.notification?.android;
      log("---- Notification: $notification ----");
      log("---- Android Notification: $androidNotification ----");

      if (notification != null && androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          payload: json.encode(message.data),
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              priority: Priority.high,
              importance: Importance.max,
            ),
          ),
        );
      }
    } catch (_) {
      rethrow;
    }
  }
}
