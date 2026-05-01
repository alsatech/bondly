import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bondly_button.dart';

/// Shown when there are no candidates left and `has_more == false`.
class DiscoverEmptyState extends StatelessWidget {
  const DiscoverEmptyState({
    super.key,
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold star icon — no gradient circle, just a clean icon
            const Icon(
              Icons.explore_outlined,
              color: AppColors.gold,
              size: 48,
            ),
            const SizedBox(height: 28),
            Text(
              'The room is quiet\nfor now.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Come back soon to discover\nnew people worth keeping.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            BondlyButton(
              label: 'REFRESH',
              onPressed: onRefresh,
              variant: BondlyButtonVariant.outline,
              minimumSize: const Size(180, 50),
            ),
          ],
        ),
      ),
    );
  }
}
