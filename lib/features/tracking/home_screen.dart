import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/permissions/location_permission_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/location_firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'package:live_location_tracker/core/services/foreground_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _tracking = false;

  // 🗺️ MAP STATE
  GoogleMapController? _mapController;
  Marker? _userMarker;

  @override
  void initState() {
    super.initState();
    AuthService.signInAnonymously();
  }

  Future<void> _startTracking() async {
    final hasPermission =
        await LocationPermissionService.ensurePermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    // 🔐 USER CONSENT
    await LocationService.setTrackingEnabled(true);

    // 🚀 START FOREGROUND SERVICE
    await FlutterForegroundTask.startService(
      notificationTitle: 'Live Location Tracking',
      notificationText: 'Tracking your location in background',
      callback: startCallback,
    );

    LocationService.startTracking(onLocation: (position) async {
      setState(() {
        _currentPosition = position;
        _tracking = true;
      });

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      // 📍 UPDATE MARKER
      setState(() {
        _userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: latLng,
        );
      });

      // 🎥 MOVE CAMERA
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(latLng),
      );

      debugPrint(
        'LAT: ${position.latitude}, LNG: ${position.longitude}',
      );

      await LocationFirestoreService.uploadLocation(position);
    });
  }

  Future<void> _stopTracking() async {
    await LocationService.setTrackingEnabled(false);
    LocationService.stopTracking();
    await FlutterForegroundTask.stopService();

    setState(() {
      _tracking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
      ),
      body: Column(
        children: [
          // 🗺️ GOOGLE MAP
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.4219983, -122.084),
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _userMarker != null ? {_userMarker!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // 📍 LAT / LNG + BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_currentPosition != null) ...[
                  Text(
                    'Latitude : ${_currentPosition!.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _tracking ? _stopTracking : _startTracking,
                  child: Text(
                    _tracking ? 'Stop Tracking' : 'Start Tracking',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
