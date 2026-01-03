import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final action = message.data['action'];

  if (action == 'START_TRACKING') {
    // Android 13+ requires user-visible notification
    await FlutterForegroundTask.startService(
      notificationTitle: 'Location tracking paused',
      notificationText: 'Tap to resume tracking',
      callback: startCallback,
    );
  }
}
