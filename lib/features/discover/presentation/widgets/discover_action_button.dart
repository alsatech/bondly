import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

/// Like action button (heart) — green fill with glow. Primary CTA.
class LikeActionButton extends StatelessWidget {
  const LikeActionButton({
    super.key,
    required this.onPressed,
    this.size = 68,
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
    this.size = 54,
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

/// Super like / star button — gold, medium size.
/// Optional third action shown between skip and like.
class SuperLikeActionButton extends StatelessWidget {
  const SuperLikeActionButton({
    super.key,
    required this.onPressed,
    this.size = 54,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _CircleActionButton(
      onPressed: onPressed,
      size: size,
      icon: Icons.star_rounded,
      iconColor: AppColors.gold,
      backgroundColor: AppColors.card,
      shadowColor: AppColors.gold,
      hasBorder: true,
      borderColor: AppColors.gold.withValues(alpha: 0.35),
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
    this.borderColor,
  });

  final VoidCallback onPressed;
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final bool hasBorder;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: hasBorder
              ? Border.all(
                  color: borderColor ?? AppColors.border,
                  width: 1.0,
                )
              : null,
          boxShadow: shadowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.38,
        ),
      ),
    );
  }
}

/// Compact label row shown below the action buttons.
/// Mirrors the "SWIPE UNTIL LATE" text pattern in the reference.
class ActionRowLabel extends StatelessWidget {
  const ActionRowLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'SWIPE UNTIL LATE',
      style: GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary.withValues(alpha: 0.4),
        letterSpacing: 2.0,
      ),
    );
  }
}
