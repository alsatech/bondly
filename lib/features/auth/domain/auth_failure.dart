sealed class AuthFailure {
  const AuthFailure(this.message);
  final String message;
}

final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super('Email o contraseña incorrectos.');
}

final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super('Este correo ya está registrado.');
}

final class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Sin conexión. Revisa tu internet.');
}

final class ServerFailure extends AuthFailure {
  const ServerFailure([super.message = 'Error del servidor. Intenta más tarde.']);
}

final class TokenExpired extends AuthFailure {
  const TokenExpired() : super('Tu sesión expiró. Inicia sesión nuevamente.');
}

final class UnknownFailure extends AuthFailure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
