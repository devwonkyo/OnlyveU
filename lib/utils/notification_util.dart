import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationUtil {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final GoRouter _router = router;

  // Singleton pattern to ensure a single instance
  static final NotificationUtil _instance = NotificationUtil._internal();

  factory NotificationUtil() => _instance;

  NotificationUtil._internal();

  Future<void> initialize() async {
    AndroidInitializationSettings android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings = InitializationSettings(android: android, iOS: ios);


    await _local.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },);
  }

  Future<void> requestNotificationPermission() async {

    if(await Permission.notification.isDenied) {
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }
    }

    if(Platform.isIOS){
      _local.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.
      requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

  }


  Future<void> showNotification(RemoteMessage message) async {
    const NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,

      ),
      android: AndroidNotificationDetails(
        "Nomal", //채널 아이디 별로 알림 특성 설정 가능(방 같은 개념)
        "Nomal", //채널의 용도를 설명하는 이름
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    //앞의 int값이 알림 고유 번호 -> 상수값 넣으면 한개만 덮어씀
    await _local.show(0, message.notification?.title ?? "알림",
        message.notification?.body ?? "",
        details,
        payload: message.data['screen'] );
  }

  void _handleNotificationTap(String? payload) {
    print('payload = $payload');
    if (payload != null) {
      _router.go(payload);
    }
  }
}
