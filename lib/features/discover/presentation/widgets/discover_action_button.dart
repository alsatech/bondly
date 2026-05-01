import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Like action button (heart) — primary CTA, green fill with subtle glow.
class LikeActionButton extends StatelessWidget {
  const LikeActionButton({
    super.key,
    required this.onPressed,
    this.size = 72,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _CircleActionButton(
      onPressed: onPressed,
      size: size,
      icon: Icons.favorite_rounded,
      iconColor: Colors.white,
      backgroundColor: AppColors.success,
      shadowColor: AppColors.success,
    );
  }
}

/// Skip action button (X) — smaller, dark card background with border.
class SkipActionButton extends StatelessWidget {
  const SkipActionButton({
    super.key,
    required this.onPressed,
    this.size = 56,
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
      backgroundColor: AppColors.card,
      shadowColor: Colors.transparent,
      hasBorder: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal shared implementation
// ─────────────────────────────────────────────────────────────────────────────

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.onPressed,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.shadowColor,
    this.hasBorder = false,
  });

  final VoidCallback onPressed;
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: hasBorder
              ? Border.all(color: AppColors.border, width: 1.5)
              : null,
          boxShadow: shadowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.40,
        ),
      ),
    );
  }
}
