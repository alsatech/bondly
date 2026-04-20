/// Sealed hierarchy for Discover-feature failures.
/// All public messages are user-facing (Spanish).
sealed class DiscoverFailure {
  const DiscoverFailure(this.message);
  final String message;
}

final class DiscoverNetworkFailure extends DiscoverFailure {
  const DiscoverNetworkFailure()
      : super('Sin conexión. Revisa tu internet.');
}

final class DiscoverServerFailure extends DiscoverFailure {
  const DiscoverServerFailure([
    super.message = 'Error del servidor. Intenta más tarde.',
  ]);
}

final class DiscoverUnknownFailure extends DiscoverFailure {
  const DiscoverUnknownFailure([
    super.message = 'Ocurrió un error inesperado.',
  ]);
}

/// Returned when a like is sent but the match relationship already exists.
/// The UI should treat this as a no-op skip rather than a crash.
final class DiscoverAlreadyMatchedFailure extends DiscoverFailure {
  const DiscoverAlreadyMatchedFailure()
      : super('Ya enviaste un like a esta persona.');
}
