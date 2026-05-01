import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

/// Renders the top biographical block of the profile page:
///
///   ♦ FOUNDER · VOL. 04          04 (watermark right)
///   [Big italic name — Playfair]
///   — FOUNDER — MAISON ONYX
///   [Bio text]
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  // Placeholder data — replace with provider model when available.
  static const _founderLabel = 'FOUNDER · VOL. 04';
  static const _volumeWatermark = '04';
  static const _displayName = 'Soren Adebayo';
  static const _subtitle = 'FOUNDER — MAISON ONYX';
  static const _bio =
      'I make rooms that feel like the right answer. Candle-lit dinners, slow records, a small circle.';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ♦ FOUNDER · VOL. 04
            Row(
              children: [
                const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 11),
                const SizedBox(width: 5),
                Text(
                  _founderLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Large Playfair name
            Text(
              _displayName,
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 6),

            // — FOUNDER — MAISON ONYX
            Row(
              children: [
                Container(
                  width: 24,
                  height: 1,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Text(
                  _subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Bio
            Text(
              _bio,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.55,
              ),
            ),
          ],
        ),

        // Volume watermark — large faded number top-right
        Positioned(
          top: -6,
          right: 0,
          child: Text(
            _volumeWatermark,
            style: GoogleFonts.playfairDisplay(
              fontSize: 72,
              fontWeight: FontWeight.w700,
              color: AppColors.border.withValues(alpha: 0.6),
              letterSpacing: -4,
            ),
          ),
        ),
      ],
    );
  }
}
