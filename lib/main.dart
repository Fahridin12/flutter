import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'data/datasources/search_cache_storage.dart';
import 'data/services/push_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseAvailable = false;
  try {
    if (DefaultFirebaseOptions.currentPlatform.apiKey != 'REPLACE_ME') {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
      firebaseAvailable = true;
    } else {
      debugPrint('Firebase: keys not set yet. Running in offline/demo mode.');
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox<String>(SearchCacheStorage.boxName);

  final prefs = await SharedPreferences.getInstance();
  await configureDependencies(prefs, firebaseAvailable: firebaseAvailable);

  runApp(const ReadingTrackerApp());
}

