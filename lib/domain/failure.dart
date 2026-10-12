enum FailureType { network, timeout, server, parse, unknown }

/// Ошибка слоя данных, понятная UI (без деталей Dio/Firebase).
class Failure implements Exception {
  const Failure(this.type, [this.message]);

  final FailureType type;
  final String? message;

  @override
  String toString() => 'Failure($type${message == null ? '' : ': $message'})';
}

enum AuthErrorCode {
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  network,
  cancelled,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthErrorCode code;

  @override
  String toString() => 'AuthFailure($code)';
}
