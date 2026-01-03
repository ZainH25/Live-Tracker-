📍 Live Location Tracker (Flutter)
📌 Project Overview

Live Location Tracker is a Flutter-based mobile application designed to track a user’s real-time geographical location and persist location updates to Firebase. The app is architected with scalability, background execution, and modularity in mind, following industry-standard Flutter and Android best practices.

The project integrates:

Real-time GPS tracking

Background location updates

Firebase authentication & Firestore storage

Google Maps UI (partially implemented)

This application serves as a technical prototype for live tracking use cases such as logistics tracking, personal safety, fleet monitoring, or fitness tracking.

🏗️ Architecture Overview

The project follows a layered & feature-based architecture:

lib/
├── core/
│   ├── permissions/
│   │   └── location_permission_service.dart
│   └── services/
│       ├── auth_service.dart
│       ├── foreground_service.dart
│       ├── location_service.dart
│       ├── location_firestore_service.dart
│       ├── location_task_handler.dart
│       ├── fcm_service.dart
│       └── fcm_background.dart
├── features/
│   └── tracking/
│       └── home_screen.dart
├── firebase_options.dart
└── main.dart

⚙️ Core Functional Flow
1️⃣ App Startup

main.dart initializes:

Firebase

Foreground task configuration

Entry point to UI

2️⃣ Authentication

Anonymous authentication using Firebase (AuthService)

Ensures every device has a unique user ID for location storage

3️⃣ Permission Handling

LocationPermissionService handles:

Foreground location permission

Background location permission

Runtime permission validation

4️⃣ Location Tracking

LocationService uses Geolocator

Tracks user location via stream:

High accuracy

Distance filter optimization

Emits real-time latitude & longitude updates

5️⃣ Background Execution

Implemented using flutter_foreground_task

Location updates continue even when app is minimized

Android foreground notification is shown during tracking

6️⃣ Firestore Integration

LocationFirestoreService uploads:

Latitude

Longitude

Timestamp

User ID

Enables historical and live tracking in backend

🗺️ Map Integration (Current Status)
Intended Behavior

Display Google Map

Show user’s current position

Animate camera as location updates

Display marker for live position

Current Status

❌ Map UI is NOT rendering correctly

Root Cause

Google Maps API key configuration is incomplete / incorrect

Although the map widget is implemented in home_screen.dart, the Android native setup still requires validation

Code Location
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(37.4219983, -122.084),
    zoom: 16,
  ),
  myLocationEnabled: true,
)

✅ Features Implemented Successfully

✅ Flutter project structure with clean separation

✅ Firebase initialization & configuration

✅ Anonymous Firebase Authentication

✅ Real-time GPS location tracking

✅ Background location tracking (Android)

✅ Foreground service with notification

✅ Firestore location persistence

✅ App icon generation (Android, iOS, Web, Desktop)

✅ APK build generation

✅ GitHub repository setup & version control
