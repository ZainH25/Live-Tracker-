import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    debugPrint('🔥 FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 FCM foreground message: ${message.data}');
    });
  }
}
