import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/permissions/location_permission_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/location_firestore_service.dart';
import '../../core/services/auth_service.dart';
import 'package:live_location_tracker/core/services/foreground_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _tracking = false;
  bool _showPath = true;
  double _totalDistance = 0.0;
  
  final MapController _mapController = MapController();
  LatLng? _currentLatLng;
  final List<LatLng> _pathPoints = [];
  final List<Marker> _customMarkers = [];

  @override
  void initState() {
    super.initState();
    AuthService.signInAnonymously();
  }

  void _calculateDistance(LatLng newPoint) {
    if (_pathPoints.isNotEmpty) {
      final lastPoint = _pathPoints.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
      _totalDistance += distance;
    }
  }

  Future<void> _startTracking() async {
    final hasPermission = await LocationPermissionService.ensurePermission();

    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission denied'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await LocationService.setTrackingEnabled(true);

    await FlutterForegroundTask.startService(
      notificationTitle: 'Live Location Tracking',
      notificationText: 'Tracking your location in background',
      callback: startCallback,
    );

    LocationService.startTracking(onLocation: (position) async {
      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _currentLatLng = latLng;
        _tracking = true;
        
        if (_showPath) {
          _calculateDistance(latLng);
          _pathPoints.add(latLng);
        }
      });

      _mapController.move(latLng, 17);

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

  void _centerOnCurrentLocation() {
    if (_currentLatLng != null) {
      _mapController.move(_currentLatLng!, 17);
    }
  }

  void _shareLocation() {
    if (_currentPosition != null) {
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;
      final message = 'My current location:\nhttps://maps.google.com/?q=$lat,$lng';
      Share.share(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No location available to share'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _addCustomMarker() {
    if (_currentLatLng != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2E3447),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Marker', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Add a marker at your current location?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customMarkers.add(
                    Marker(
                      point: _currentLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.place,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Marker added'),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }
  }

  void _clearPath() {
    setState(() {
      _pathPoints.clear();
      _totalDistance = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Path cleared successfully'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _clearMarkers() {
    setState(() {
      _customMarkers.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All markers removed'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showClearPathDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E3447),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Clear Path?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This will delete your entire route history and reset the distance counter to 0 km. This action cannot be undone.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearPath();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear Path'),
          ),
        ],
      ),
    );
  }

  void _showClearMarkersDialog() {
    if (_customMarkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No markers to clear'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E3447),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Clear Markers?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This will remove all ${_customMarkers.length} marker(s) from the map. This action cannot be undone.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearMarkers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Clear Markers'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // 🗺️ MAP VIEW
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng ?? const LatLng(20.5937, 78.9629),
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.live_location_tracker',
              ),
              // Path line
              if (_showPath && _pathPoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathPoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              // Custom markers
              if (_customMarkers.isNotEmpty)
                MarkerLayer(markers: _customMarkers),
              // Current location marker
              if (_currentLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLatLng!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 🎯 TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Button
                  Builder(
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E3447),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                  ),

                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3447),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Location Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Settings Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3447),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📍 CENTER LOCATION BUTTON
          if (_currentLatLng != null)
            Positioned(
              right: 16,
              bottom: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3447),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _centerOnCurrentLocation,
                ),
              ),
            ),

          // 📊 BOTTOM CONTROL PANEL
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E3447),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Row
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _tracking ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _tracking ? 'Tracking Active' : 'Tracking Inactive',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_tracking) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.gps_fixed,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      if (_tracking)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Coordinates Display
                      if (_currentPosition != null)
                        Row(
                          children: [
                            Expanded(
                              child: _buildCoordinateCard(
                                'LATITUDE',
                                _currentPosition!.latitude.toStringAsFixed(4),
                                Icons.arrow_upward,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCoordinateCard(
                                'LONGITUDE',
                                _currentPosition!.longitude.toStringAsFixed(4),
                                Icons.arrow_back,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _tracking ? _stopTracking : _startTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _tracking ? Colors.red.shade600 : Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_tracking ? Icons.pause : Icons.play_arrow),
                              const SizedBox(width: 8),
                              Text(
                                _tracking ? 'Pause Tracking' : 'Start Tracking',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_tracking)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Location data is encrypted & stored securely',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1D2E),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Location Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track and share your journey',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Distance Display in Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.straighten, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            
            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Share Location
                  _buildDrawerItem(
                    icon: Icons.share_location,
                    title: 'Share Location',
                    subtitle: 'Share your current GPS coordinates',
                    iconBgColor: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _shareLocation();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Add Marker
                  _buildDrawerItem(
                    icon: Icons.add_location_alt,
                    title: 'Add Marker',
                    subtitle: 'Place custom markers on the map',
                    iconBgColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _addCustomMarker();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Path Tracking Toggle
                  _buildDrawerItem(
                    icon: _showPath ? Icons.timeline : Icons.timeline_outlined,
                    title: 'Path Tracking',
                    subtitle: _showPath ? 'Blue line showing your route' : 'Path hidden',
                    iconBgColor: Colors.blue,
                    trailing: Switch(
                      value: _showPath,
                      onChanged: (value) {
                        setState(() {
                          _showPath = value;
                        });
                      },
                      activeTrackColor: Colors.blue,
                    ),
                    onTap: () {
                      setState(() {
                        _showPath = !_showPath;
                      });
                    },
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
                    child: Text(
                      'MANAGE DATA',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  // Clear Path
                  _buildDrawerItem(
                    icon: Icons.clear_all,
                    title: 'Clear Path',
                    subtitle: 'Reset tracking history and distance',
                    iconBgColor: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      _showClearPathDialog();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Clear Markers
                  _buildDrawerItem(
                    icon: Icons.delete_outline,
                    title: 'Clear Markers',
                    subtitle: 'Remove all custom markers',
                    iconBgColor: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      _showClearMarkersDialog();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Distance Stats
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3447),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Distance',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_totalDistance / 1000).toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_pathPoints.isNotEmpty)
                                Text(
                                  '${_pathPoints.length} points tracked',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // App Version Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.2',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconBgColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 12,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildCoordinateCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}