import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
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
            // Illustration placeholder — compass rose icon in a gradient circle.
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: AppColors.textPrimary,
                size: 52,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Por ahora no hay nadie nuevo.',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Vuelve pronto para descubrir nuevas personas.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            BondlyButton(
              label: 'Refrescar',
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
