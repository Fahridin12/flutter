import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Реальная конфигурация Firebase проекта flutter-14dd5.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDqhW4SkshR4d-0RXZmjtvpH1emmX53bNs',
    appId: '1:9490476714:web:3b71ecaa900d5177f02ad3',
    messagingSenderId: '9490476714',
    projectId: 'flutter-14dd5',
    authDomain: 'flutter-14dd5.firebaseapp.com',
    storageBucket: 'flutter-14dd5.firebasestorage.app',
    measurementId: 'G-4FZ2QRK5M4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqhW4SkshR4d-0RXZmjtvpH1emmX53bNs',
    appId: '1:9490476714:web:3b71ecaa900d5177f02ad3',
    messagingSenderId: '9490476714',
    projectId: 'flutter-14dd5',
    storageBucket: 'flutter-14dd5.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDqhW4SkshR4d-0RXZmjtvpH1emmX53bNs',
    appId: '1:9490476714:web:3b71ecaa900d5177f02ad3',
    messagingSenderId: '9490476714',
    projectId: 'flutter-14dd5',
    authDomain: 'flutter-14dd5.firebaseapp.com',
    storageBucket: 'flutter-14dd5.firebasestorage.app',
    measurementId: 'G-4FZ2QRK5M4',
  );
}
