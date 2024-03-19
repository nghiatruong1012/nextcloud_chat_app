import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:nextcloud_chat_app/my_app.dart';
import 'package:nextcloud_chat_app/repositories/authentication_repository.dart';
import 'package:nextcloud_chat_app/repositories/user_repository.dart';
import 'package:nextcloud_chat_app/screen/login/view/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nextcloud_chat_app/service/noti_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  List<dynamic> currentNoti = [];

  // Initialization settings
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings(
  //   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  // );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: initializationSettingsIOS,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // onSelectNotification: onSelectNotification,
  );

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
      ));
  service.startService();
  // Timer.periodic(Duration(seconds: 5), (timer) async {
  //   final listNoti = await NotiService().getNoti();
  //   print("noti" + listNoti.toString());
  //   if (listNoti.isNotEmpty && listNoti != currentNoti) {
  //     currentNoti = listNoti;
  //     listNoti.forEach((element) {
  //       if (element["object_type"] == 'chat') {
  //         _showNotification(element["notification_id"], element["subject"],
  //             element["message"]);
  //       }
  //     });
  //   }
  //   // _showNotification();
  // });
  runApp(
    // MaterialApp(),
    MyApp(
      authenticationRepository: AuthenticationRepository(),
      userRepository: UserRepository(),
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer.periodic(Duration(seconds: 5), (timer) async {
    final listNoti = await NotiService().getNoti();

    listNoti.forEach((element) {
      if (element["object_type"] == 'chat') {
        _showNotification(
            element["notification_id"], element["subject"], element["message"]);
      }
    });
  });
}

final Set<int> shownNotificationIds = Set<int>();

Future<void> _showNotification(int id, String title, String content) async {
  // Check if the notification ID has already been shown
  if (shownNotificationIds.contains(id)) {
    return;
  }
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    // 'your channel description',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id, // notification id
    title,
    content,
    platformChannelSpecifics,
  );

  // Add the notification ID to the set of shown IDs
  shownNotificationIds.add(id);
}

Future<void> onSelectNotification(String? payload) async {
  // Handle notification tap
}

Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // Handle notification received while app is in the foreground
}
