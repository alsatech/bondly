import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bondly_shimmer.dart';

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const _PostCardShimmer(),
    );
  }
}

class _PostCardShimmer extends StatelessWidget {
  const _PostCardShimmer();

  @override
  Widget build(BuildContext context) {
    return BondlyShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  const ShimmerCircle(size: 40),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 120, height: 13, borderRadius: 6),
                      const SizedBox(height: 5),
                      ShimmerBox(width: 70, height: 11, borderRadius: 6),
                    ],
                  ),
                ],
              ),
            ),
            // Media placeholder
            Container(
              color: AppColors.border,
              height: MediaQuery.sizeOf(context).width - 32,
            ),
            // Actions row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  ShimmerBox(width: 48, height: 18, borderRadius: 9),
                  const SizedBox(width: 16),
                  ShimmerBox(width: 32, height: 18, borderRadius: 9),
                  const SizedBox(width: 16),
                  ShimmerBox(width: 32, height: 18, borderRadius: 9),
                ],
              ),
            ),
            // Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
                  const SizedBox(height: 5),
                  ShimmerBox(width: 200, height: 13, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
