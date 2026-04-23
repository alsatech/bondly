import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../data/feed_repository.dart';
import 'feed_notifier.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    dio: ref.watch(dioProvider),
  );
});

// ---------------------------------------------------------------------------
// Notifier provider
// ---------------------------------------------------------------------------

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);
