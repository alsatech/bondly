import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../data/discover_repository.dart';
import 'discover_notifier.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepository(
    dio: ref.watch(dioProvider),
  );
});

// ---------------------------------------------------------------------------
// Notifier provider
// ---------------------------------------------------------------------------

final discoverNotifierProvider =
    NotifierProvider<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
