📍 Live Location Tracking & Remote Activation Flutter Application
Project Title

Live Location Tracking & Remote Activation Mobile Application (Flutter)

Objective

The objective of this project is to design and develop a Flutter-based mobile application that continuously tracks a user’s real-time location and securely stores it in Firebase Firestore.
The application is capable of running in the foreground, background, when the screen is locked, and can recover tracking even after the app is force-closed using a remote activation mechanism.

1️⃣ Architecture Overview

The project follows a feature-based modular architecture with clear separation of concerns.

Architecture Pattern

Feature-based structure

Service-driven logic

UI kept independent of background execution logic

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

Design Principles

UI does not directly control background logic

Background services operate independently using isolates

All critical operations are handled via services

Firebase access is centralized

2️⃣ Libraries & Packages Used (with Justification)
Package	Purpose
geolocator	High-accuracy GPS location tracking
flutter_foreground_task	Persistent foreground service for Android background execution
firebase_core	Firebase initialization
cloud_firestore	Storing location data reliably
firebase_auth	Anonymous authentication for secure data ownership
firebase_messaging	Remote reactivation using FCM
google_maps_flutter	Real-time map visualization
flutter_riverpod	Scalable state management
connectivity_plus	Network state awareness
share_plus	Sharing live location
flutter_launcher_icons	App icon generation
3️⃣ Location Tracking (Foreground + Background)
Foreground Tracking

Uses Geolocator.getPositionStream

Updates UI in real time

Displays current location on Google Map

Shows distance traveled and tracking status

Background Tracking

Implemented using Android Foreground Service

Runs continuously even when:

App is minimized

Screen is locked

App is removed from recent apps

Location collection handled in a background isolate

Battery Optimization

Adjustable location interval

Distance filter applied

High-accuracy mode optional via settings

4️⃣ App Survival After Being Killed
Problem

Android restricts background execution after force-stop.

Solution Implemented

Foreground Service keeps the process alive

FCM Data Message remotely restarts tracking

Mechanism

App is force-killed

FCM data-only message is sent

Background FCM handler runs

Foreground service restarts location tracking

This approach complies with Android background execution policies.

5️⃣ Firebase Firestore Integration
Stored Data Structure

Each location entry contains:

timestamp

latitude

longitude

userId

Reliability

Offline persistence enabled

Automatic sync when network is restored

Firestore handles queuing transparently

Authentication

Anonymous Firebase authentication

Ensures user/session isolation

No personally identifiable information required

6️⃣ Remote Reactivation Mechanism
Technology Used

Firebase Cloud Messaging (FCM)

Message Type

Data-only FCM message (no notification payload)

{
  "data": {
    "action": "START_TRACKING"
  }
}

Why This Approach

Notification messages may not wake the app

Data-only messages allow background execution

Works even when app is killed (except full OS force-stop)

7️⃣ App UI Features
Home Screen

Google Map with live user marker

Path (polyline) showing movement

Distance counter

Start / Stop tracking button

Tracking status indicator

Navigation Drawer (☰ Menu)

Share live location

Add custom markers

Toggle path visibility

Clear path history

Clear markers

Distance statistics

Settings Screen

Profile editing (name/email – optional)

Background tracking toggle

High accuracy mode

Update interval slider

Manual sync option

Privacy & app info section

8️⃣ Tested Devices & OS Versions
Device	OS
Android Emulator	Android 13, 14
Physical Android Device	Android 14
iOS	UI tested (background limits acknowledged)

Note: Full background execution is restricted on iOS due to OS policies.

9️⃣ Limitations & Known Issues

iOS does not allow full background execution after force-kill

Emulator Google Maps may not render reliably

Remote reactivation depends on OEM restrictions

Background execution reliability varies by device manufacturer
