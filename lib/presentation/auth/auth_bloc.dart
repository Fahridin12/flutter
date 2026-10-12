import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/failure.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AuthUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthEmailSignInRequested extends AuthEvent {
  const AuthEmailSignInRequested(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.email, this.password, {this.name});

  final String email;
  final String password;
  final String? name;

  @override
  List<Object?> get props => [email, password, name];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Одноразовое сообщение для пользователя (SnackBar).
enum AuthNotice {
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  network,
  unknown,
  resetEmailSent;

  static AuthNotice fromCode(AuthErrorCode code) => switch (code) {
        AuthErrorCode.invalidCredentials => AuthNotice.invalidCredentials,
        AuthErrorCode.emailInUse => AuthNotice.emailInUse,
        AuthErrorCode.weakPassword => AuthNotice.weakPassword,
        AuthErrorCode.invalidEmail => AuthNotice.invalidEmail,
        AuthErrorCode.network => AuthNotice.network,
        AuthErrorCode.cancelled || AuthErrorCode.unknown => AuthNotice.unknown,
      };
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.busy = false,
    this.notice,
    this.noticeTick = 0,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool busy;
  final AuthNotice? notice;

  /// Увеличивается при каждом новом сообщении, чтобы BlocListener сработал и на одинаковый текст.
  final int noticeTick;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool clearUser = false,
    bool? busy,
    AuthNotice? notice,
    int? noticeTick,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      busy: busy ?? this.busy,
      notice: notice ?? this.notice,
      noticeTick: noticeTick ?? this.noticeTick,
    );
  }

  @override
  List<Object?> get props => [status, user, busy, notice, noticeTick];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository)
      : super(AuthState(
          status: _repository.currentUser == null
              ? AuthStatus.unknown
              : AuthStatus.authenticated,
          user: _repository.currentUser,
        )) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthEmailSignInRequested>(
      (e, emit) => _run(emit, () => _repository.signInWithEmail(e.email, e.password)),
    );
    on<AuthRegisterRequested>(
      (e, emit) => _run(
        emit,
        () => _repository.registerWithEmail(e.email, e.password, displayName: e.name),
      ),
    );
    on<AuthGoogleSignInRequested>((e, emit) => _run(emit, _repository.signInWithGoogle));
    on<AuthPasswordResetRequested>(
      (e, emit) => _run(
        emit,
        () => _repository.sendPasswordReset(e.email),
        success: AuthNotice.resetEmailSent,
      ),
    );
    on<AuthSignOutRequested>((e, emit) => _run(emit, _repository.signOut));

    _subscription = _repository.authStateChanges.listen((u) => add(AuthUserChanged(u)));
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _subscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    emit(state.copyWith(
      status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      user: user,
      clearUser: user == null,
    ));
  }

  Future<void> _run(
    Emitter<AuthState> emit,
    Future<void> Function() action, {
    AuthNotice? success,
  }) async {
    emit(state.copyWith(busy: true));
    try {
      await action();
      emit(success == null
          ? state.copyWith(busy: false)
          : state.copyWith(busy: false, notice: success, noticeTick: state.noticeTick + 1));
    } on AuthFailure catch (f) {
      if (f.code == AuthErrorCode.cancelled) {
        emit(state.copyWith(busy: false));
      } else {
        emit(state.copyWith(
          busy: false,
          notice: AuthNotice.fromCode(f.code),
          noticeTick: state.noticeTick + 1,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        busy: false,
        notice: AuthNotice.unknown,
        noticeTick: state.noticeTick + 1,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
