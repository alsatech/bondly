import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Like action button (heart) shown below the swipe stack.
class LikeActionButton extends StatelessWidget {
  const LikeActionButton({
    super.key,
    required this.onPressed,
    this.size = 60,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _CircleActionButton(
      onPressed: onPressed,
      size: size,
      icon: Icons.favorite_rounded,
      iconColor: AppColors.success,
      borderColor: AppColors.success,
      shadowColor: AppColors.success,
    );
  }
}

/// Skip action button (X) shown below the swipe stack.
class SkipActionButton extends StatelessWidget {
  const SkipActionButton({
    super.key,
    required this.onPressed,
    this.size = 60,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _CircleActionButton(
      onPressed: onPressed,
      size: size,
      icon: Icons.close_rounded,
      iconColor: AppColors.textSecondary,
      borderColor: AppColors.border,
      shadowColor: AppColors.textSecondary,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal shared implementation
// ---------------------------------------------------------------------------

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.onPressed,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final VoidCallback onPressed;
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.card,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.42,
        ),
      ),
    );
  }
}
