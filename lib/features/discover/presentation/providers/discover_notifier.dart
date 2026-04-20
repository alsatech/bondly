import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/discovery_candidate.dart';
import '../../data/models/match_result.dart';
import '../../domain/discover_failure.dart';
import 'discover_providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class DiscoverState {
  const DiscoverState();
}

final class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

final class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

/// Active state — at least one card available or data fully loaded.
final class DiscoverReady extends DiscoverState {
  const DiscoverReady({
    required this.queue,
    required this.nextOffset,
    required this.hasMore,
    this.lastMatchResult,
    this.isPrefetching = false,
  });

  final List<DiscoveryCandidate> queue;
  final int nextOffset;
  final bool hasMore;

  /// Set after a successful like call; consumed by the screen to show the
  /// match modal when [MatchResult.isMutualMatch] is true.
  final MatchResult? lastMatchResult;

  /// True while a background page fetch is in progress.
  final bool isPrefetching;

  DiscoverReady copyWith({
    List<DiscoveryCandidate>? queue,
    int? nextOffset,
    bool? hasMore,
    // Use a sentinel to allow explicit null clearing of lastMatchResult.
    Object? lastMatchResult = _Sentinel.value,
    bool? isPrefetching,
  }) {
    return DiscoverReady(
      queue: queue ?? this.queue,
      nextOffset: nextOffset ?? this.nextOffset,
      hasMore: hasMore ?? this.hasMore,
      lastMatchResult: lastMatchResult == _Sentinel.value
          ? this.lastMatchResult
          : lastMatchResult as MatchResult?,
      isPrefetching: isPrefetching ?? this.isPrefetching,
    );
  }
}

final class DiscoverEmpty extends DiscoverState {
  const DiscoverEmpty();
}

final class DiscoverError extends DiscoverState {
  const DiscoverError(this.failure);
  final DiscoverFailure failure;
}

// Sentinel for nullable copyWith pattern.
enum _Sentinel { value }

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class DiscoverNotifier extends Notifier<DiscoverState> {
  @override
  DiscoverState build() {
    return const DiscoverInitial();
  }

  // ---------------------------------------------------------------------------
  // Public interface
  // ---------------------------------------------------------------------------

  /// Performs the initial data load. Should be called once when the screen mounts.
  Future<void> loadInitial() async {
    state = const DiscoverLoading();
    await _fetchPage(offset: 0, replace: true);
  }

  /// Advance the queue by discarding the top card (swipe left / skip).
  void skip() {
    final current = state;
    if (current is! DiscoverReady) return;

    final updated = current.queue.length > 1
        ? current.copyWith(queue: current.queue.sublist(1))
        : const DiscoverEmpty();

    state = updated;

    if (updated is DiscoverReady) {
      maybePrefetch();
    }
  }

  /// Send a like to [candidateId], then advance the queue.
  Future<void> like(String candidateId) async {
    final current = state;
    if (current is! DiscoverReady) return;

    // Optimistically advance the queue while the request is in flight.
    final nextQueue = current.queue.length > 1
        ? current.queue.sublist(1)
        : <DiscoveryCandidate>[];

    final optimisticState = nextQueue.isEmpty
        ? const DiscoverEmpty()
        : current.copyWith(
            queue: nextQueue,
            lastMatchResult: null,
          );

    state = optimisticState;

    if (optimisticState is DiscoverReady) {
      maybePrefetch();
    }

    try {
      final repo = ref.read(discoverRepositoryProvider);
      final result = await repo.likeUser(candidateId);

      // Only update with match result if we're still in a Ready state.
      final afterLike = state;
      if (afterLike is DiscoverReady) {
        state = afterLike.copyWith(lastMatchResult: result);
      } else if (afterLike is DiscoverEmpty) {
        // Queue exhausted but we still need to surface the match modal.
        // Re-enter Ready with empty queue so the screen can react.
        state = DiscoverReady(
          queue: const [],
          nextOffset: current.nextOffset,
          hasMore: current.hasMore,
          lastMatchResult: result,
        );
      }
    } on DiscoverAlreadyMatchedFailure {
      // Already matched — silently ignore (queue already advanced).
    } on DiscoverFailure {
      // Network/server error during like — we already advanced the queue so
      // we surface the error as a snack (done in the screen via ref.listen)
      // without reverting the card.
      rethrow;
    }
  }

  /// Clears result signal so the modal is shown only once.
  void clearLastMatchResult() {
    final current = state;
    if (current is! DiscoverReady) return;
    state = current.copyWith(lastMatchResult: null);
  }

  /// Refresh the entire queue from offset 0.
  Future<void> refresh() async {
    await _fetchPage(offset: 0, replace: true);
  }

  /// Called after each card action. Triggers a background fetch when the
  /// queue has 3 or fewer cards remaining and there is more data.
  void maybePrefetch() {
    final current = state;
    if (current is! DiscoverReady) return;
    if (!current.hasMore) return;
    if (current.isPrefetching) return;
    if (current.queue.length > 3) return;

    _fetchPage(offset: current.nextOffset, replace: false);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _fetchPage({
    required int offset,
    required bool replace,
  }) async {
    final repo = ref.read(discoverRepositoryProvider);

    // Mark prefetch in progress if appending.
    if (!replace) {
      final current = state;
      if (current is DiscoverReady) {
        state = current.copyWith(isPrefetching: true);
      }
    }

    try {
      final page = await repo.fetchCandidates(offset: offset);

      if (replace) {
        if (page.candidates.isEmpty) {
          state = const DiscoverEmpty();
        } else {
          state = DiscoverReady(
            queue: page.candidates,
            nextOffset: page.nextOffset,
            hasMore: page.hasMore,
          );
        }
      } else {
        final current = state;
        if (current is DiscoverReady) {
          final merged = [...current.queue, ...page.candidates];
          state = current.copyWith(
            queue: merged,
            nextOffset: page.nextOffset,
            hasMore: page.hasMore,
            isPrefetching: false,
          );
        } else if (current is DiscoverEmpty && page.candidates.isNotEmpty) {
          // Edge case: queue emptied while fetch was in flight.
          state = DiscoverReady(
            queue: page.candidates,
            nextOffset: page.nextOffset,
            hasMore: page.hasMore,
          );
        }
      }
    } on DiscoverFailure catch (failure) {
      if (replace) {
        state = DiscoverError(failure);
      } else {
        // Background prefetch failed — stay on current state, the screen will
        // show a snack via ref.listen.
        final current = state;
        if (current is DiscoverReady) {
          state = current.copyWith(isPrefetching: false);
        }
        rethrow;
      }
    }
  }
}
