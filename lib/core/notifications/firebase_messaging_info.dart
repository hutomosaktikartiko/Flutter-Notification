import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_info.dart';

abstract class FirebaseMessagingInfo {
  Future<void> init();
  Future<String> getFcmToken();
}

class FirebaseMessagingInfoImpl implements FirebaseMessagingInfo {
  final FirebaseMessaging firebaseMessaging;
  final LocalNotificationInfo localNotificationInfo;

  const FirebaseMessagingInfoImpl({
    required this.firebaseMessaging,
    required this.localNotificationInfo,
  });

  @override
  Future<void> init() async {
    try {
      log("---- Initializing Firebase Messaging ----");

      // request permission
      await requestPermission();

      // set foreground notification presentation options
      await setForegroundNotificationPresentationOptions();

      // set background message handler
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      // set foreground message handler
      FirebaseMessaging.onMessage.listen(_foregroundMessageHandler);

      // set terminated app handler
      FirebaseMessaging.onMessageOpenedApp.listen(_clickMessageHandler);

      // set message opened app handler
      FirebaseMessaging.onMessageOpenedApp.listen(_clickMessageHandler);

      log("---- Initialized Firebase Messaging ----");
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> getFcmToken() async {
    try {
      log("---- Getting Firebase Messaging Token ----");

      final String? token = await firebaseMessaging.getToken();

      if (token == null) {
        throw Exception('Token is null');
      }

      log("---- Got Firebase Messaging Token ----");
      log(token);

      return token;
    } catch (_) {
      throw Exception('Failed to get token');
    }
  }

  Future<void> requestPermission() async {
    try {
      log("---- Requesting notification permission ----");
      final NotificationSettings result =
          await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log("---- Requested Notification Permission Result ----");
      log(result.authorizationStatus.toString());

      if (result.authorizationStatus == AuthorizationStatus.denied) {
        throw Exception('User denied notification permission');
      } else if (result.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        throw Exception('User not determined notification permission');
      }
    } catch (_) {
      throw Exception('Failed to request notification permission');
    }
  }

  Future<void> setForegroundNotificationPresentationOptions() async {
    try {
      log("---- Setting foreground notification presentation options ----");
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {
      throw Exception('Failed to set foreground notification presentation options');
    }
  }

  Future<void> _foregroundMessageHandler(RemoteMessage message) async {
    try {
      log('Handling a foreground message ${message.messageId}');

      // show local notification
      await localNotificationInfo.show(message: message);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _clickMessageHandler(RemoteMessage message) async {
    log('Handling a click message ${message.messageId}');
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  log('Handling a background message ${message.messageId}');
}
