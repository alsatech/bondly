/// Sealed hierarchy for post-creation failures.
/// All public messages are user-facing (Spanish).
sealed class PostCreateFailure {
  const PostCreateFailure(this.message);
  final String message;
}

final class PostCreateNetworkFailure extends PostCreateFailure {
  const PostCreateNetworkFailure()
      : super('Sin conexión. Revisa tu internet.');
}

final class PostCreateServerFailure extends PostCreateFailure {
  const PostCreateServerFailure([
    super.message = 'Error del servidor. Intenta más tarde.',
  ]);
}

final class PostCreateValidationFailure extends PostCreateFailure {
  const PostCreateValidationFailure([
    super.message = 'Datos inválidos. Revisa los campos.',
  ]);
}

final class PostCreateUnknownFailure extends PostCreateFailure {
  const PostCreateUnknownFailure([
    super.message = 'Ocurrió un error inesperado.',
  ]);
}
