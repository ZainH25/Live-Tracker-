import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class LocationFirestoreService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> uploadLocation(Position position) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    await _firestore
        .collection('locations')
        .doc(userId)
        .collection('records')
        .add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'platform': kIsWeb ? 'web' : 'android',
    });
  }
}
