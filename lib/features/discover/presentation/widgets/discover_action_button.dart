import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Like action button (heart) — primary CTA, 72px, green background with glow.
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

/// Skip action button (X) — 56px, dark background.
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
      iconColor: Colors.white,
      backgroundColor: AppColors.border,
      shadowColor: Colors.transparent,
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
    required this.backgroundColor,
    required this.shadowColor,
  });

  final VoidCallback onPressed;
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
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
          color: backgroundColor,
          boxShadow: shadowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.30),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
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
