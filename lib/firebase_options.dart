// STUB FILE - Replace this file after running: flutterfire configure
//
// To generate the real firebase_options.dart:
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Enable Email/Password Authentication
// 3. Create a Firestore Database
// 4. Install Firebase CLI: npm install -g firebase-tools
// 5. Install FlutterFire CLI: dart pub global activate flutterfire_cli
// 6. Run: firebase login
// 7. Run: flutterfire configure
//
// This will generate the correct DefaultFirebaseOptions for your project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace these placeholder values after running flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'com.example.pgManagement',
  );
}
