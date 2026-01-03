import 'dart:async';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'location_firestore_service.dart';

class LocationTaskHandler extends TaskHandler {
  Timer? _timer;
  bool _firebaseReady = false;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print('🚀 LocationTaskHandler started');

    // 🔥 CRITICAL — INIT FIREBASE IN THIS ISOLATE
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseReady = true;
      print('✅ Firebase initialized in background isolate');
    } catch (e) {
      print('⚠️ Firebase already initialized: $e');
      _firebaseReady = true;
    }

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!_firebaseReady) return;

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        print('📍 LAT: ${position.latitude}, LNG: ${position.longitude}');
        await LocationFirestoreService.uploadLocation(position);
      } catch (e) {
        print('❌ Location error: $e');
      }
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // Not used
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _timer?.cancel();
    print('🛑 LocationTaskHandler stopped');
  }

  @override
  void onNotificationPressed() {
    // Android 14 rule: do nothing
  }
}
