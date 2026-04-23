import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post.dart';
import '../../domain/feed_failure.dart';
import 'feed_providers.dart';

// ---------------------------------------------------------------------------
// Feed tabs
// ---------------------------------------------------------------------------

enum FeedTab { forYou, founders, places, events, food }

extension FeedTabLabel on FeedTab {
  String get label {
    return switch (this) {
      FeedTab.forYou => 'Para Ti',
      FeedTab.founders => '★ Founders',
      FeedTab.places => 'Lugares',
      FeedTab.events => 'Eventos',
      FeedTab.food => 'Comida',
    };
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class FeedState {
  const FeedState();
}

final class FeedInitial extends FeedState {
  const FeedInitial();
}

final class FeedLoading extends FeedState {
  const FeedLoading();
}

final class FeedReady extends FeedState {
  const FeedReady({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
    this.isPaginating = false,
    required this.activeTab,
  });

  final List<Post> posts;
  final String? nextCursor;
  final bool hasMore;

  /// True while a background pagination fetch is in progress.
  final bool isPaginating;
  final FeedTab activeTab;

  FeedReady copyWith({
    List<Post>? posts,
    Object? nextCursor = _Sentinel.value,
    bool? hasMore,
    bool? isPaginating,
    FeedTab? activeTab,
  }) {
    return FeedReady(
      posts: posts ?? this.posts,
      nextCursor: nextCursor == _Sentinel.value
          ? this.nextCursor
          : nextCursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isPaginating: isPaginating ?? this.isPaginating,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

final class FeedEmpty extends FeedState {
  const FeedEmpty({required this.activeTab});
  final FeedTab activeTab;
}

final class FeedError extends FeedState {
  const FeedError(this.failure);
  final FeedFailure failure;
}

// Sentinel for nullable copyWith.
enum _Sentinel { value }

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() => const FeedInitial();

  // ---------------------------------------------------------------------------
  // Public interface
  // ---------------------------------------------------------------------------

  Future<void> loadInitial() async {
    state = const FeedLoading();
    await _fetchPage(cursor: null, replace: true);
  }

  Future<void> refresh() async {
    await _fetchPage(cursor: null, replace: true);
  }

  /// Called when the user scrolls within [threshold] posts of the end.
  /// No-ops if already paginating or no more data.
  Future<void> maybePrefetch() async {
    final current = state;
    if (current is! FeedReady) return;
    if (!current.hasMore) return;
    if (current.isPaginating) return;

    await _fetchPage(cursor: current.nextCursor, replace: false);
  }

  /// Selects a tab. Updates active tab state immediately.
  /// NOTE: All tabs currently hit the same /feed endpoint — no server-side
  /// filtering. This is a known limitation tracked in TECH_DEBT.md.
  void selectTab(FeedTab tab) {
    final current = state;
    switch (current) {
      case FeedReady():
        state = current.copyWith(activeTab: tab);
      case FeedEmpty():
        state = FeedEmpty(activeTab: tab);
      default:
        break;
    }
  }

  FeedTab get _currentTab {
    final current = state;
    return switch (current) {
      FeedReady(activeTab: final t) => t,
      FeedEmpty(activeTab: final t) => t,
      _ => FeedTab.forYou,
    };
  }

  /// Optimistically toggles the like on [postId].
  /// Rolls back and surfaces an error on failure.
  Future<void> toggleLike(String postId) async {
    final current = state;
    if (current is! FeedReady) return;

    final postIndex = current.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final original = current.posts[postIndex];
    final optimisticPost = original.copyWith(
      hasLiked: !original.hasLiked,
      likesCount: original.hasLiked
          ? (original.likesCount - 1).clamp(0, double.maxFinite.toInt())
          : original.likesCount + 1,
    );

    // Apply optimistic update.
    final updatedPosts = List<Post>.from(current.posts)
      ..[postIndex] = optimisticPost;
    state = current.copyWith(posts: updatedPosts);

    try {
      final repo = ref.read(feedRepositoryProvider);
      final result = await repo.toggleLike(postId);

      // Reconcile with server truth.
      final afterLike = state;
      if (afterLike is! FeedReady) return;
      final reconcileIndex =
          afterLike.posts.indexWhere((p) => p.id == postId);
      if (reconcileIndex == -1) return;

      final reconciledPost = afterLike.posts[reconcileIndex].copyWith(
        hasLiked: result.liked,
        likesCount: result.likesCount,
      );
      final reconciledPosts = List<Post>.from(afterLike.posts)
        ..[reconcileIndex] = reconciledPost;
      state = afterLike.copyWith(posts: reconciledPosts);
    } on FeedFailure {
      // Roll back on failure.
      final afterFail = state;
      if (afterFail is! FeedReady) return;
      final rollbackIndex =
          afterFail.posts.indexWhere((p) => p.id == postId);
      if (rollbackIndex == -1) return;

      final rolledBack = List<Post>.from(afterFail.posts)
        ..[rollbackIndex] = original;
      state = afterFail.copyWith(posts: rolledBack);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _fetchPage({
    required String? cursor,
    required bool replace,
  }) async {
    final repo = ref.read(feedRepositoryProvider);
    final tab = _currentTab;

    if (!replace) {
      final current = state;
      if (current is FeedReady) {
        state = current.copyWith(isPaginating: true);
      }
    }

    try {
      final page = await repo.fetchFeed(cursor: cursor);

      if (replace) {
        if (page.posts.isEmpty) {
          state = FeedEmpty(activeTab: tab);
        } else {
          state = FeedReady(
            posts: page.posts,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            activeTab: tab,
          );
        }
      } else {
        final current = state;
        if (current is FeedReady) {
          state = current.copyWith(
            posts: [...current.posts, ...page.posts],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            isPaginating: false,
          );
        }
      }
    } on FeedFailure catch (failure) {
      if (replace) {
        state = FeedError(failure);
      } else {
        final current = state;
        if (current is FeedReady) {
          state = current.copyWith(isPaginating: false);
        }
        rethrow;
      }
    }
  }
}
