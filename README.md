##📍 Live Location Tracker (Flutter) ##
📌 Overview

Live Location Tracker is a Flutter-based mobile application that tracks a user’s real-time location, runs reliably in the background, and stores location updates securely in Firebase.
The project is designed with scalability, modular architecture, and Android background execution compliance in mind.

This application can serve as a foundation for use cases such as:

Personal safety tracking

Fleet & logistics monitoring

Fitness & activity tracking

Real-time movement monitoring systems

🏗️ Project Architecture

The application follows a clean, feature-based architecture with clear separation of concerns.

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

⚙️ How the App Works
1️⃣ App Initialization

Firebase is initialized at startup.

Foreground task configuration is set.

App launches into the tracking screen.

2️⃣ Authentication

Anonymous authentication using Firebase.

Ensures every device has a unique identifier.

3️⃣ Permission Handling

Requests foreground and background location permissions.

Validates runtime permissions before tracking starts.

4️⃣ Location Tracking

Uses Geolocator for high-accuracy GPS updates.

Location updates are streamed continuously.

Battery usage is optimized using distance filters.

5️⃣ Background Execution

Implemented using flutter_foreground_task.

Tracking continues even when the app is minimized or screen is locked.

Android foreground notification ensures system compliance.

6️⃣ Firebase Firestore Integration

Each location update is uploaded with:

Latitude

Longitude

Timestamp

User ID

Enables live tracking and historical data storage.

🗺️ Google Maps Integration (Current Status)
Intended Functionality

Display Google Map UI

Show user’s live position

Animate camera with movement

Place and update a live marker

Current Status

❌ Map UI is not rendering on the screen

Reason

Google Maps native API key configuration is incomplete.

Map widget exists in UI but native rendering fails.

All location logic works correctly; only the map visualization layer needs fixing.

✅ Features Implemented

✅ Flutter project setup with clean architecture

✅ Firebase initialization & configuration

✅ Anonymous Firebase authentication

✅ Real-time GPS tracking

✅ Background location tracking (Android)

✅ Foreground service with persistent notification

✅ Firestore location storage

✅ App icon generation (Android, iOS, Web, Desktop)

✅ Release APK build

✅ GitHub repository setup & version control

❌ Features Not Working / Pending
Feature	Status	Notes
Google Maps display	❌ Not working	API key configuration issue
Live marker movement	❌ Blocked	Depends on map rendering
Route polyline tracking	❌ Not implemented	Future enhancement
Location history UI	❌ Not implemented	Backend ready
Multi-user live tracking	❌ Not implemented	Future scope
iOS background tracking	⚠️ Partial	Requires extra permissions
📦 APK Build Details

Build Type: Release

APK Location:

build/app/outputs/flutter-apk/app-release.apk


APK Size: ~46 MB

Ready for installation and distribution.

🧪 Known Issues

Google Map shows blank screen

Native Google Maps SDK not rendering

Requires Google Cloud Console verification

🚀 Future Enhancements

Fix Google Maps rendering

Add route polyline tracking

Implement multi-user live tracking

Add location history dashboard

Improve battery optimization

Add role-based authentication

🧑‍💻 Tech Stack

Flutter (Dart)

Firebase

Authentication

Firestore

Google Maps SDK

Geolocator

Android Foreground Services

Git & GitHub

📜 Conclusion

This project demonstrates a production-ready backend and tracking architecture for live location tracking.
Core tracking, background execution, and data persistence are fully functional.
The remaining work is limited to Google Maps UI configuration, which can be resolved without changing the core architecture.
