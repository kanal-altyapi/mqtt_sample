import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase/utils/firebase_utils.dart';

FirebaseMessagingUtils firebaseMessagingUtils = FirebaseMessagingUtils();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  firebaseUtil.initialize();
  print('Handling a background message ${message.messageId}');
}

class FirebaseMessagingUtils {
  String? _token = '';
  static late Function onBackground;
  String? get token => _token;

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initialize(Function onBackgroundMessage, Function onMessage) async {
    onBackground = onBackgroundMessage;
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      print(e);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message);
      return;
    });

    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _token = await FirebaseMessaging.instance.getToken();
    debugPrint('Token:$_token');
  }
}
