import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/discovery_candidate.dart';

/// The swipeable card that displays a discovery candidate.
///
/// Reference: Bellweather Coffee card — full-bleed photo, name in large
/// Playfair Display at bottom, tagline + attribution below, swipe overlays.
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
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo / gradient placeholder
            _buildBackground(),

            // Gradient scrim — heavier at bottom for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.30, 0.72, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),

            // Swipe direction tint overlay
            if (swipeDirection != 0.0) _buildSwipeOverlay(),

            // Top-right: online/score indicator
            if (candidate.score > 0.7)
              Positioned(
                top: 20,
                right: 20,
                child: _AffinityPill(),
              ),

            // Bottom content block
            Positioned(
              left: 22,
              right: 22,
              bottom: 28,
              child: _buildContent(),
            ),

            // Swipe direction stamps
            if (swipeDirection > 0.15)
              Positioned(
                top: 28,
                left: 22,
                child: _SwipeStamp(
                  label: 'LIKE',
                  color: AppColors.success,
                ),
              ),
            if (swipeDirection < -0.15)
              Positioned(
                top: 28,
                right: 22,
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
        errorWidget: (_, __, ___) => _GradientBackground(initial: candidate.initial),
      );
    }
    return _GradientBackground(initial: candidate.initial);
  }

  Widget _buildSwipeOverlay() {
    final isLike = swipeDirection > 0;
    final color = isLike
        ? AppColors.success.withValues(alpha: swipeDirection.abs() * 0.28)
        : AppColors.textSecondary.withValues(alpha: swipeDirection.abs() * 0.18);
    return Positioned.fill(child: ColoredBox(color: color));
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Interests / shared count as small pill
        if (candidate.sharedInterestsCount > 0) ...[
          _SharedInterestsPill(count: candidate.sharedInterestsCount),
          const SizedBox(height: 10),
        ],

        // Full name — large Playfair Display
        Text(
          candidate.fullName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 12,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Bio / tagline if available (first two lines)
        if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            candidate.bio!,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 10),

        // Bottom metadata row
        _MetaRow(candidate: candidate),
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
          colors: [Color(0xFF1C1C22), Color(0xFF0F0F12)],
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
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _AffinityPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 10),
          const SizedBox(width: 4),
          Text(
            'High affinity',
            style: GoogleFonts.dmSans(
              fontSize: 10,
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

class _SharedInterestsPill extends StatelessWidget {
  const _SharedInterestsPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count interests in common',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.80),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Bottom meta row: gender dot · mutual follow badge · "SWIPE TO CONNECT" label.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.candidate});

  final DiscoveryCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gender pill if available
        if (candidate.gender != null && candidate.gender!.isNotEmpty) ...[
          Text(
            candidate.gender!,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Mutual follow badge
        if (candidate.isMutualFollow) ...[
          Text(
            'Follows you',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.success.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],

        const Spacer(),

        // Right side: "SWIPE TO CONNECT" hint
        Text(
          'SWIPE TO CONNECT',
          style: GoogleFonts.dmSans(
            fontSize: 8,
            color: Colors.white.withValues(alpha: 0.30),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2.0),
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: color,
          letterSpacing: 2.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
