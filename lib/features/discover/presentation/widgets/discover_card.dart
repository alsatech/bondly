import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final cardHeight = size.height * 0.64;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or gradient placeholder
            _buildBackground(),

            // Bottom gradient for text legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),

            // Swipe direction color overlay
            if (swipeDirection != 0.0) _buildSwipeOverlay(),

            // Bottom content: name, badges
            Positioned(
              left: 22,
              right: 22,
              bottom: 30,
              child: _buildContent(),
            ),

            // Swipe direction stamp
            if (swipeDirection > 0.15)
              Positioned(
                top: 36,
                left: 24,
                child: _SwipeStamp(
                  label: 'LIKE',
                  color: AppColors.success,
                ),
              ),
            if (swipeDirection < -0.15)
              Positioned(
                top: 36,
                right: 24,
                child: _SwipeStamp(
                  label: 'PASS',
                  color: AppColors.textSecondary,
                ),
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
        placeholder: (_, __) => _GradientBackground(initial: candidate.initial),
        errorWidget: (_, __, ___) =>
            _GradientBackground(initial: candidate.initial),
      );
    }
    return _GradientBackground(initial: candidate.initial);
  }

  Widget _buildSwipeOverlay() {
    final isLike = swipeDirection > 0;
    final color = isLike
        ? AppColors.success.withValues(alpha: swipeDirection.abs() * 0.30)
        : AppColors.textSecondary.withValues(alpha: swipeDirection.abs() * 0.20);
    return Positioned.fill(child: ColoredBox(color: color));
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // High-affinity badge
        if (candidate.score > 0.7) ...[
          _AffinityBadge(),
          const SizedBox(height: 10),
        ],
        // Full name — Playfair Display, large
        Text(
          candidate.fullName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Shared interests
        if (candidate.sharedInterestsCount > 0) ...[
          const SizedBox(height: 8),
          _SharedInterestsBadge(count: candidate.sharedInterestsCount),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.playfairDisplay(
          fontSize: 96,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _AffinityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 11),
          const SizedBox(width: 4),
          Text(
            'High affinity',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedInterestsBadge extends StatelessWidget {
  const _SharedInterestsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count interests in common',
        style: AppTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
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
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: color,
          letterSpacing: 2.5,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
