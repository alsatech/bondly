import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';

/// Shimmer placeholder for the card stack shown during the initial load.
class DiscoverShimmer extends StatelessWidget {
  const DiscoverShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = size.width - 32;
    final cardHeight = size.height * 0.62;

    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: [
          // Stacked shimmer cards illusion — two offset cards behind the main.
          SizedBox(
            width: cardWidth,
            height: cardHeight + 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Back card — smaller & offset down.
                Positioned(
                  top: 16,
                  child: _ShimmerCard(
                    width: cardWidth - 32,
                    height: cardHeight - 8,
                  ),
                ),
                // Front card — full size.
                Positioned(
                  top: 0,
                  child: _ShimmerCard(
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Action button shimmer row.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShimmerCircle(size: 56),
              const SizedBox(width: 40),
              _ShimmerCircle(size: 72),
              const SizedBox(width: 40),
              _ShimmerCircle(size: 56),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}
