import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  AuthUser? get currentUser;

  Future<void> signInWithEmail(String email, String password);

  Future<void> registerWithEmail(String email, String password, {String? displayName});

  Future<void> signInWithGoogle();

  Future<void> signInOffline();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
