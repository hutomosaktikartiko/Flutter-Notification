import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/notifications/firebase_messaging_info.dart';
import 'core/notifications/local_notification_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  late LocalNotificationInfo localNotificationInfo;
  late FirebaseMessagingInfo firebaseMessagingInfo;

  String? fcmToken;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    // init local notification
    _initLocalNotification();

    // init firebase messaging
    _initFirebaseMessaging();
  }

  void _initLocalNotification() {
    localNotificationInfo = LocalNotificationInfoImpl(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }

  void _initFirebaseMessaging() async {
    firebaseMessagingInfo = FirebaseMessagingInfoImpl(
      firebaseMessaging: firebaseMessaging,
      localNotificationInfo: localNotificationInfo,
    );

    try {
      await firebaseMessagingInfo.init();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(),
          const SizedBox(
            height: 15,
          ),
          Text(
            fcmToken ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (fcmToken == null) {
      return ElevatedButton(
        onPressed: _getFcmToken,
        child: const Text("Get FCM Token"),
      );
    }

    return ElevatedButton(
      onPressed: _copyTokenToClipboard,
      child: const Text("Copy Token to Clipboard"),
    );
  }

  void _copyTokenToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: fcmToken));
    } catch (e) {
      log(e.toString());
    }
  }

  void _getFcmToken() async {
    try {
      fcmToken = await firebaseMessagingInfo.getFcmToken();

      setState(() {
        fcmToken = fcmToken;
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
