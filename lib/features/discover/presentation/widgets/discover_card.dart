import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/discovery_candidate.dart';

/// The swipeable card that displays a discovery candidate.
///
/// [swipeDirection] controls the directional color overlay:
/// - > 0 → green (like)
/// - < 0 → soft gray (skip)
/// - 0 → no overlay
class DiscoverCard extends StatelessWidget {
  const DiscoverCard({
    super.key,
    required this.candidate,
    this.swipeDirection = 0.0,
  });

  final DiscoveryCandidate candidate;

  /// Normalized horizontal swipe offset in the range [-1, 1].
  final double swipeDirection;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = size.width - 32;
    final cardHeight = size.height * 0.62;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Avatar / Gradient background
            _buildBackground(),

            // Bottom gradient scrim for text legibility.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha:0.82),
                    ],
                  ),
                ),
              ),
            ),

            // Swipe overlay (like = green, skip = gray).
            if (swipeDirection != 0.0) _buildSwipeOverlay(),

            // Card content — badges + info at the bottom.
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: _buildContent(),
            ),

            // Like / skip stamp labels shown on swipe.
            if (swipeDirection > 0.15)
              Positioned(
                top: 32,
                left: 24,
                child: _SwipeStamp(label: 'ME GUSTA', color: AppColors.success),
              ),
            if (swipeDirection < -0.15)
              Positioned(
                top: 32,
                right: 24,
                child: _SwipeStamp(label: 'PASAR', color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (candidate.avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: candidate.avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _AvatarPlaceholder(initial: candidate.initial),
        errorWidget: (_, __, ___) =>
            _AvatarPlaceholder(initial: candidate.initial),
      );
    }
    return _AvatarPlaceholder(initial: candidate.initial);
  }

  Widget _buildSwipeOverlay() {
    final isLike = swipeDirection > 0;
    final color = isLike
        ? AppColors.success.withValues(alpha:swipeDirection.abs() * 0.35)
        : AppColors.textSecondary.withValues(alpha:swipeDirection.abs() * 0.25);

    return Positioned.fill(
      child: ColoredBox(color: color),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badges row.
        Row(
          children: [
            if (candidate.sharedInterestsCount > 0)
              _Badge(
                label:
                    '${candidate.sharedInterestsCount} intereses en común',
                color: AppColors.accent.withValues(alpha:0.85),
              ),
            if (candidate.sharedInterestsCount > 0 && candidate.score >= 0.8)
              const SizedBox(width: 8),
            if (candidate.score >= 0.8)
              const _Badge(
                label: 'Alta afinidad',
                color: AppColors.primary,
              ),
          ],
        ),
        if (candidate.sharedInterestsCount > 0 || candidate.score >= 0.8)
          const SizedBox(height: 10),
        // Full name.
        Text(
          candidate.fullName,
          style: AppTypography.displayMedium.copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha:0.6),
                blurRadius: 8,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Bio.
        if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            candidate.bio!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary.withValues(alpha:0.82),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha:0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: color,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
