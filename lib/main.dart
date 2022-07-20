import 'dart:convert';

import 'package:chat_app/utility/color_constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'route/app_pages.dart';
import 'utility/app_constant.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  var initialzationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initialzationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var transactionId = '';

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (message) async {
    debugPrint("=======================" + message!);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('notificationDataMessage-' + message.data.toString());

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    try {
      final result = json.decode(message.data['data']);

      debugPrint('transactionId-' +
          result['transaction_id'].toString() +
          ' ' +
          transactionId);
    } catch (e) {
      debugPrint("exe_notification " + e.toString());
    }

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            color: ColorConstants.appColor,
            icon: "@mipmap/ic_launcher",
            playSound: true,
          ),
        ),
        payload: transactionId,
      );
    }
  });

  //var token = await FirebaseMessaging.instance.getToken();
  //debugPrint('token-' + token.toString());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: ColorConstants.appColor,
      ),
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      title: AppConstants.appName,
    );
  }
}
