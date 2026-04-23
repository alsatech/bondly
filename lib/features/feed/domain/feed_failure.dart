sealed class FeedFailure {
  const FeedFailure(this.message);
  final String message;
}

final class FeedNetworkFailure extends FeedFailure {
  const FeedNetworkFailure([super.message = 'Sin conexión. Revisa tu red e intenta de nuevo.']);
}

final class FeedServerFailure extends FeedFailure {
  const FeedServerFailure([super.message = 'Error del servidor. Intenta de nuevo más tarde.']);
}

final class FeedUnknownFailure extends FeedFailure {
  const FeedUnknownFailure([super.message = 'Algo salió mal. Intenta de nuevo.']);
}
