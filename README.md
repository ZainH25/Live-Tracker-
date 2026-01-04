📍 Live Location Tracking & Remote Activation Flutter Application

Project Title

Live Location Tracking & Remote Activation Mobile Application (Flutter)

Objective

The objective of this project is to design and develop a Flutter-based mobile application that continuously tracks a user’s real-time location and securely stores it in Firebase Firestore.
The application supports foreground, background, and screen-locked tracking, and includes a remote reactivation mechanism to resume tracking even after the app is removed from the recent apps list.

1️⃣ Architecture Overview

The project follows a feature-based modular architecture with strict separation between UI, background execution, and data services.

Architecture Pattern

Feature-based folder structure

Service-oriented logic

Background execution isolated from UI

Firebase access centralized via services

lib/
│
├── core/
│   ├── services/
│   │   ├── location_service.dart
│   │   ├── foreground_service.dart
│   │   ├── location_firestore_service.dart
│   │   ├── fcm_service.dart
│   │   └── auth_service.dart
│   │
│   └── permissions/
│       └── location_permission_service.dart
│
├── features/
│   └── tracking/
│       ├── home_screen.dart
│       └── settings_screen.dart
│
├── background/
│   ├── location_task_handler.dart
│   └── fcm_background.dart
│
├── firebase_options.dart
└── main.dart

2️⃣ Libraries & Packages Used (with Justification)
Package	Purpose
geolocator	High-accuracy GPS location tracking
flutter_foreground_task	Persistent foreground service for Android background execution
firebase_core	Firebase initialization
cloud_firestore	Secure and reliable location storage
firebase_auth	Anonymous authentication for user/session isolation
firebase_messaging	Remote reactivation via FCM
flutter_map	Map UI using OpenStreetMap
latlong2	Latitude/longitude utilities
flutter_riverpod	Scalable state management
connectivity_plus	Network awareness and offline sync
share_plus	Sharing live location
flutter_launcher_icons	App icon generation
3️⃣ Map UI – OpenStreetMap (OSM)
Why OpenStreetMap?

This project uses OpenStreetMap (OSM) instead of Google Maps for the following reasons:

No API key requirement

Open-source and cost-free

Lightweight and fast rendering

Ideal for demo, assignment, and scalable usage

Avoids Google Maps billing and quota limits

Implementation

Map rendering via flutter_map

Tile source: OpenStreetMap

Live user location marker

Path (polyline) showing movement history

Custom markers added by user

4️⃣ Location Tracking (Foreground + Background)
Foreground Tracking

Uses Geolocator.getPositionStream

Updates UI in real time

Displays:

Live marker on OSM map

Distance traveled

Tracking status

Background Tracking

Implemented using Android Foreground Service

Continues tracking when:

App is minimized

Screen is locked

App is removed from recent apps

Location collection runs in a background isolate

Battery Optimization

Adjustable tracking interval

Distance filter applied

High-accuracy mode configurable via settings

5️⃣ App Survival After Being Killed
Problem

Mobile OS (especially Android) restricts background execution after force-stop.

Solution Implemented

Persistent foreground service

Firebase Cloud Messaging (FCM) data-only trigger

Flow

App is force-closed

FCM data message is received

Background isolate is launched

Foreground service restarts

Location tracking resumes automatically

This approach complies with Android background execution policies.

6️⃣ Firebase Firestore Integration
Stored Location Data

Each record includes:

timestamp

latitude

longitude

userId

Reliability

Firestore offline persistence enabled

Automatic sync when connectivity is restored

No data loss during network interruptions

Authentication

Anonymous Firebase authentication

Ensures secure user/session isolation

No personal data required

7️⃣ Remote Reactivation Mechanism
Technology Used

Firebase Cloud Messaging (FCM)

Message Type

Data-only message (no notification payload)

{
  "data": {
    "action": "START_TRACKING"
  }
}

Justification

Notification messages may not wake killed apps

Data-only messages allow background execution

Best available solution under OS restrictions

8️⃣ App UI Features
Home Screen

OpenStreetMap-based live map

Live user location marker

Movement path (polyline)

Distance traveled counter

Start / Stop tracking button

Tracking status indicator

Navigation Drawer (☰ Menu)

Share live location

Add custom markers

Toggle path visibility

Clear path history

Clear all markers

Distance statistics

Settings Screen

Editable user profile (name/email)

Background tracking toggle

High-accuracy mode

Update frequency control

Manual sync option

App and privacy information

9️⃣ Tested Devices & OS Versions
Device	OS
Android Emulator	Android 13, 14
Physical Android Device	Android 14
iOS	UI tested (background limitations acknowledged)

Note: iOS restricts full background execution after force-kill due to OS policies.

🔟 Limitations & Known Issues

iOS background execution is limited by OS policies

Background reactivation depends on device manufacturer restrictions

Emulator performance may vary

Full force-stop cannot be bypassed due to OS security

🔮 Future Improvements

iOS-compliant background tracking enhancements

Web dashboard for live tracking

Geo-fencing alerts

Encrypted location storage

Battery-aware adaptive tracking

Multi-user tracking support
