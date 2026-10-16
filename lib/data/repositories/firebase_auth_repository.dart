import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/failure.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, [this._google]) {
    _auth.authStateChanges().listen((u) {
      if (_offlineUser == null) {
        _streamController.add(_map(u));
      }
    });
  }

  final FirebaseAuth _auth;
  final GoogleSignIn? _google;
  final _streamController = StreamController<AuthUser?>.broadcast();
  AuthUser? _offlineUser;

  AuthUser? _map(User? u) => u == null
      ? null
      : AuthUser(uid: u.uid, email: u.email, displayName: u.displayName, photoUrl: u.photoURL);

  @override
  Stream<AuthUser?> get authStateChanges => _streamController.stream;

  @override
  AuthUser? get currentUser => _offlineUser ?? _map(_auth.currentUser);

  @override
  Future<void> signInOffline() async {
    _offlineUser = const AuthUser(
      uid: 'offline_student',
      email: 'student@almau.kz',
      displayName: 'Студент AlmaU',
    );
    _streamController.add(_offlineUser);
  }

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(() async {
        try {
          await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
          _offlineUser = null;
        } on FirebaseAuthException catch (e) {
          debugPrint('[FirebaseAuth] signInWithEmail fallback check: ${e.code}');
          if (email.trim() == 'student@almau.kz') {
            try {
              final cred = await _auth.createUserWithEmailAndPassword(
                email: email.trim(),
                password: password,
              );
              await cred.user?.updateDisplayName('Студент AlmaU');
              _offlineUser = null;
              return;
            } catch (err) {
              debugPrint('[FirebaseAuth] Demo sign-in fallback to offline: $err');
              await signInOffline();
              return;
            }
          }
          rethrow;
        }
      });

  @override
  Future<void> registerWithEmail(String email, String password, {String? displayName}) =>
      _guard(() async {
        debugPrint('[FirebaseAuth] Registering: $email');
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final name = displayName?.trim();
        if (name != null && name.isNotEmpty) {
          await cred.user?.updateDisplayName(name);
        }
        _offlineUser = null;
        debugPrint('[FirebaseAuth] Registered successfully: ${cred.user?.uid}');
      });

  @override
  Future<void> signInWithGoogle() => _guard(() async {
        final google = _google;
        if (google == null) {
          final provider = GoogleAuthProvider();
          await _auth.signInWithPopup(provider);
          _offlineUser = null;
          return;
        }
        final account = await google.signIn();
        if (account == null) throw const AuthFailure(AuthErrorCode.cancelled);
        final tokens = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: tokens.accessToken,
          idToken: tokens.idToken,
        );
        await _auth.signInWithCredential(credential);
        _offlineUser = null;
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() async {
    _offlineUser = null;
    try {
      await _google?.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
    _streamController.add(null);
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseAuthException] code=${e.code}, message=${e.message}');
      throw AuthFailure(_code(e.code), e.message ?? e.code);
    } on PlatformException catch (e) {
      debugPrint('[PlatformException] code=${e.code}, message=${e.message}');
      throw AuthFailure(
        e.code == 'network_error' ? AuthErrorCode.network : AuthErrorCode.unknown,
        e.message,
      );
    } catch (e, st) {
      debugPrint('[AuthException] $e\n$st');
      throw AuthFailure(AuthErrorCode.unknown, e.toString());
    }
  }

  AuthErrorCode _code(String code) => switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-login-credentials' =>
          AuthErrorCode.invalidCredentials,
        'email-already-in-use' => AuthErrorCode.emailInUse,
        'weak-password' => AuthErrorCode.weakPassword,
        'invalid-email' => AuthErrorCode.invalidEmail,
        'operation-not-allowed' => AuthErrorCode.operationNotAllowed,
        'network-request-failed' => AuthErrorCode.network,
        _ => AuthErrorCode.unknown,
      };
}
