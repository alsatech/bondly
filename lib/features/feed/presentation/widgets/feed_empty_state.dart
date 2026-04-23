import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bondly_button.dart';

class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key, required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dynamic_feed_outlined,
              color: AppColors.textSecondary,
              size: 72,
            ),
            const SizedBox(height: 20),
            Text(
              'Tu feed está vacío por ahora.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sigue a personas para ver sus publicaciones aquí.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BondlyButton(
              label: 'Refrescar',
              onPressed: onRefresh,
              variant: BondlyButtonVariant.primary,
              minimumSize: const Size(180, 48),
            ),
          ],
        ),
      ),
    );
  }
}
