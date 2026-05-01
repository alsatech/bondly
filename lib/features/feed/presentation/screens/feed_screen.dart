import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/widgets/bondly_button.dart';
import '../../../../../shared/widgets/snack_helper.dart';
import '../../data/models/post.dart';
import '../../domain/feed_failure.dart';
import '../providers/feed_notifier.dart';
import '../providers/feed_providers.dart';
import '../widgets/feed_app_bar.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_shimmer.dart';
import '../widgets/feed_tabs.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double _paginationThreshold = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedNotifierProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _paginationThreshold) {
      ref.read(feedNotifierProvider.notifier).maybePrefetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeedAppBar(),
      body: SafeArea(
        child: _buildBody(feedState),
      ),
      // Create-post FAB — coral circle, bottom-right
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_post_fab',
        onPressed: _openCreatePost,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(FeedState state) {
    return switch (state) {
      FeedInitial() => const SizedBox.shrink(),
      FeedLoading() => const FeedShimmer(),
      FeedEmpty(activeTab: final tab) => Column(
          children: [
            const SizedBox(height: 10),
            FeedTabs(
              activeTab: tab,
              onTabSelected: (t) =>
                  ref.read(feedNotifierProvider.notifier).selectTab(t),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FeedEmptyState(
                onRefresh: () =>
                    ref.read(feedNotifierProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      FeedError(failure: final failure) => _buildError(failure),
      FeedReady(
        posts: final posts,
        isPaginating: final isPaginating,
        activeTab: final tab,
      ) =>
        _buildReady(posts: posts, isPaginating: isPaginating, activeTab: tab),
    };
  }

  Widget _buildReady({
    required List<Post> posts,
    required bool isPaginating,
    required FeedTab activeTab,
  }) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Tabs pinned just under the app bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: FeedTabs(
                activeTab: activeTab,
                onTabSelected: (t) =>
                    ref.read(feedNotifierProvider.notifier).selectTab(t),
              ),
            ),
          ),
          // Post cards — edge-to-edge, separated by a 1px divider drawn inside each card
          SliverList.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onLikeTap: () => _handleLike(post.id),
                onMenuTap: () =>
                    SnackHelper.showSuccess(context, 'Proximamente'),
              );
            },
          ),
          // Pagination indicator
          if (isPaginating)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildError(FeedFailure failure) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              failure.message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BondlyButton(
              label: 'Reintentar',
              onPressed: () =>
                  ref.read(feedNotifierProvider.notifier).loadInitial(),
              variant: BondlyButtonVariant.primary,
              minimumSize: const Size(200, 50),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike(String postId) async {
    try {
      await ref.read(feedNotifierProvider.notifier).toggleLike(postId);
    } on FeedFailure catch (e) {
      if (mounted) SnackHelper.showError(context, e.message);
    }
  }

  Future<void> _openCreatePost() async {
    final result = await context.push<dynamic>(AppRoutes.createPost);
    if (result != null && mounted) {
      ref.read(feedNotifierProvider.notifier).refresh();
    }
  }
}
