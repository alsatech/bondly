import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/bondly_button.dart';
import '../../../../shared/widgets/snack_helper.dart';
import '../../data/models/discovery_candidate.dart';
import '../../domain/discover_failure.dart';
import '../providers/discover_notifier.dart';
import '../providers/discover_providers.dart';
import '../widgets/discover_action_button.dart' show LikeActionButton, SkipActionButton;
import '../widgets/discover_card.dart';
import '../widgets/discover_empty_state.dart';
import '../widgets/discover_shimmer.dart';
import '../widgets/match_modal.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  late final AppinioSwiperController _swiperController;

  /// Normalized swipe offset [-1, 1] tracked for overlay tinting.
  double _swipeDirection = 0.0;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverNotifierProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  // ── Swipe handlers ─────────────────────────────────────────────────────────

  void _handleSwipeEnd(
      int previousIndex, int targetIndex, SwiperActivity activity) {
    if (activity is! Swipe) return;
    final direction = activity.direction;
    if (direction == AxisDirection.right) {
      _onLike(previousIndex);
    } else {
      _onSkip();
    }
  }

  void _onLike(int index) {
    final state = ref.read(discoverNotifierProvider);
    if (state is! DiscoverReady) return;
    if (index >= state.queue.length) return;
    final candidate = state.queue[index];
    ref.read(discoverNotifierProvider.notifier).like(candidate.id).catchError(
      (Object e) {
        if (e is DiscoverFailure && mounted) {
          SnackHelper.showError(context, e.message);
        }
      },
    );
  }

  void _onSkip() {
    ref.read(discoverNotifierProvider.notifier).skip();
  }

  void _onCardPositionChanged(SwiperPosition position) {
    if (!mounted) return;
    final screenWidth = MediaQuery.sizeOf(context).width;
    setState(() {
      _swipeDirection =
          (position.offset.dx / (screenWidth * 0.5)).clamp(-1.0, 1.0);
    });
  }

  // ── Match modal ────────────────────────────────────────────────────────────

  void _showMatchModal(String matchedName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => MatchModal(
        matchedName: matchedName,
        onContinue: () {
          Navigator.of(context).pop();
          ref.read(discoverNotifierProvider.notifier).clearLastMatchResult();
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<DiscoverState>(discoverNotifierProvider, (previous, next) {
      if (next is DiscoverReady &&
          next.lastMatchResult != null &&
          next.lastMatchResult!.isMutualMatch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showMatchModal(
              _getCandidateName(next.lastMatchResult!.targetUserId));
        });
      }
    });

    final discoverState = ref.watch(discoverNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(discoverState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'Discover',
        style: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          onPressed: () => SnackHelper.showSuccess(context, 'Proximamente'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(DiscoverState state) {
    return switch (state) {
      DiscoverInitial() => const SizedBox.shrink(),
      DiscoverLoading() => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Center(child: DiscoverShimmer()),
        ),
      DiscoverEmpty() => DiscoverEmptyState(
          onRefresh: () =>
              ref.read(discoverNotifierProvider.notifier).refresh(),
        ),
      DiscoverError(failure: final failure) => _buildErrorState(failure),
      DiscoverReady(queue: final queue) when queue.isEmpty =>
        DiscoverEmptyState(
          onRefresh: () =>
              ref.read(discoverNotifierProvider.notifier).refresh(),
        ),
      DiscoverReady(queue: final queue) => _buildReady(queue),
    };
  }

  Widget _buildErrorState(DiscoverFailure failure) {
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
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BondlyButton(
              label: 'Retry',
              onPressed: () =>
                  ref.read(discoverNotifierProvider.notifier).loadInitial(),
              variant: BondlyButtonVariant.primary,
              minimumSize: const Size(200, 50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(List<DiscoveryCandidate> queue) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppinioSwiper(
              controller: _swiperController,
              cardCount: queue.length,
              backgroundCardCount: 2,
              backgroundCardScale: 0.93,
              backgroundCardOffset: const Offset(0, 24),
              maxAngle: 10,
              threshold: 60,
              swipeOptions: const SwipeOptions.symmetric(horizontal: true),
              onSwipeEnd: _handleSwipeEnd,
              onCardPositionChanged: _onCardPositionChanged,
              onEnd: () => ref.read(discoverNotifierProvider.notifier).skip(),
              cardBuilder: (context, index) {
                if (index >= queue.length) return const SizedBox.shrink();
                return DiscoverCard(
                  candidate: queue[index],
                  swipeDirection: index == 0 ? _swipeDirection : 0.0,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionRow(size),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildActionRow(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SkipActionButton(
          size: 58,
          onPressed: () => _swiperController.swipeLeft(),
        ),
        const SizedBox(width: 36),
        LikeActionButton(
          size: 74,
          onPressed: () => _swiperController.swipeRight(),
        ),
      ],
    );
  }

  String _getCandidateName(String targetUserId) {
    final state = ref.read(discoverNotifierProvider);
    if (state is DiscoverReady) {
      final match = state.queue.where((c) => c.id == targetUserId);
      if (match.isNotEmpty) return match.first.fullName;
    }
    return 'this person';
  }
}
