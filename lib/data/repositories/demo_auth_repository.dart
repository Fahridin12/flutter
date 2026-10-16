import 'dart:async';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Локальный репозиторий авторизации для работы в офлайн/демо-режиме
/// (когда проект ещё не подключён к Firebase Console через flutterfire configure).
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({AuthUser? initialUser}) : _user = initialUser;

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _user = AuthUser(
      uid: 'demo_user',
      email: email.trim(),
      displayName: email.split('@').first,
    );
    _controller.add(_user);
  }

  @override
  Future<void> registerWithEmail(String email, String password, {String? displayName}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _user = AuthUser(
      uid: 'demo_user',
      email: email.trim(),
      displayName: (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : email.split('@').first,
    );
    _controller.add(_user);
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _user = const AuthUser(
      uid: 'demo_google_user',
      email: 'reader@almau.kz',
      displayName: 'AlmaU Reader',
    );
    _controller.add(_user);
  }

  @override
  Future<void> signInOffline() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _user = const AuthUser(
      uid: 'offline_student',
      email: 'student@almau.kz',
      displayName: 'Студент AlmaU',
    );
    _controller.add(_user);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _user = null;
    _controller.add(null);
  }
}
