import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase/utils/firebase_utils.dart';
import 'package:http/http.dart' as http;

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

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: _constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  int _messageCount = 0;
  String _constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }
}
