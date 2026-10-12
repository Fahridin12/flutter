import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';

/// Обработчик фоновых/закрытых сообщений FCM. Должен быть top-level функцией.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Системное уведомление показывается самой платформой; здесь можно обработать data-часть.
  debugPrint('FCM (background): ${message.messageId}');
}

class PushService {
  PushService([this._messaging, this._db, this._auth]);

  final FirebaseMessaging? _messaging;
  final FirebaseFirestore? _db;
  final AuthRepository? _auth;

  /// Текущий FCM-токен (показывается в настройках — удобно для тестовой отправки из консоли).
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);

  StreamSubscription<String>? _refreshSub;

  /// Сообщения, пришедшие, пока приложение открыто.
  Stream<RemoteMessage> get foregroundMessages =>
      _messaging == null ? const Stream<RemoteMessage>.empty() : FirebaseMessaging.onMessage;

  /// Запрос разрешения (Android 13+/iOS), получение и сохранение токена.
  Future<void> init() async {
    final messaging = _messaging;
    if (messaging == null) {
      token.value = 'demo_fcm_token_almau_week8';
      return;
    }
    try {
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      await _saveToken(await messaging.getToken());
      _refreshSub ??= messaging.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      debugPrint('Push init failed: $e');
      token.value ??= 'demo_fcm_token_almau_week8';
    }
  }

  Future<void> _saveToken(String? value) async {
    if (value == null) return;
    token.value = value;
    final uid = _auth?.currentUser?.uid;
    final db = _db;
    if (uid == null || db == null) return;
    try {
      await db.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([value]),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
  }
}

