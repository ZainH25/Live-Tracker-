import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;
  static const _trackingKey = 'tracking_enabled';

  // 🔹 PERSIST STATE
  static Future<void> setTrackingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingKey, value);
  }

  static Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingKey) ?? false;
  }

  // 🔹 START TRACKING
  static Future<void> startTracking({
    required Function(Position position) onLocation,
  }) async {
    await setTrackingEnabled(true);

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream?.cancel(); // safety
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(onLocation);
  }

  // 🔹 STOP TRACKING
  static Future<void> stopTracking() async {
    await setTrackingEnabled(false);
    await _positionStream?.cancel();
    _positionStream = null;
  }
}
