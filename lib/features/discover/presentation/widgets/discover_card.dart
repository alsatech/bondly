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
    final cardHeight = size.height * 0.62;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or gradient
            _buildBackground(),

            // Bottom-to-top dark gradient for text legibility (only when avatar present).
            if (candidate.avatarUrl != null)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

            // Swipe overlay tint.
            if (swipeDirection != 0.0) _buildSwipeOverlay(),

            // Bottom-left content
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: _buildContent(),
            ),

            // Swipe stamp labels.
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
        ? AppColors.success.withValues(alpha: swipeDirection.abs() * 0.35)
        : AppColors.textSecondary.withValues(alpha: swipeDirection.abs() * 0.25);

    return Positioned.fill(child: ColoredBox(color: color));
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Alta afinidad" pill — only when score > 0.7.
        if (candidate.score > 0.7) ...[
          _AffinityBadge(),
          const SizedBox(height: 8),
        ],
        // Full name
        Text(
          candidate.fullName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Shared interests chip
        if (candidate.sharedInterestsCount > 0) ...[
          const SizedBox(height: 8),
          _SharedInterestsBadge(count: candidate.sharedInterestsCount),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

/// Full coral→purple gradient background shown when avatar_url is null.
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
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AffinityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Alta afinidad',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
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
        color: AppColors.accent.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count intereses en común',
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
