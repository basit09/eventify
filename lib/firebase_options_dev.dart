// DEV Firebase configuration.
//
// ──────────────────────────────────────────────────────────────────────────────
// HOW TO FILL THIS FILE
// ──────────────────────────────────────────────────────────────────────────────
// 1. Go to https://console.firebase.google.com and create a new project:
//    Name: "event-management-dev"  (or any name you like)
//
// 2. Inside the dev project, add two apps:
//    • Android  — package name : com.example.eventmanage.event_management.dev
//    • iOS      — bundle ID    : com.example.eventmanage.eventManagement.dev
//
// 3. Enable the same services as prod:
//    Authentication → Email/Password
//    Firestore Database
//    Storage
//
// 4. Run FlutterFire CLI to auto-fill this file:
//    flutterfire configure \
//      --project=<your-dev-project-id> \
//      --out=lib/firebase_options_dev.dart \
//      --platforms=android,ios
//
//    Then rename the generated class from DevFirebaseOptions → DevFirebaseOptions.
//
// 5. Replace the placeholder values below with real ones from the CLI output.
// ──────────────────────────────────────────────────────────────────────────────
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DevFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DevFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── TODO: Replace all placeholder values with real DEV project values ──────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALL79l6hFk5H7htttQfMTjDxBRSn7FQKY',
    appId: '1:673571377665:android:01be724a76f04e78466600',
    messagingSenderId: '673571377665',
    projectId: 'event-management-dev-a6863',
    storageBucket: 'event-management-dev-a6863.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3l_478A5xvZ7ll322ZnZUXwmgMeeOQCY',
    appId: '1:673571377665:ios:983f443204c459f0466600',
    messagingSenderId: '673571377665',
    projectId: 'event-management-dev-a6863',
    storageBucket: 'event-management-dev-a6863.firebasestorage.app',
    iosBundleId: 'com.example.eventmanage.eventManagement.dev',
  );

}