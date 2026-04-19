import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum BondlyButtonVariant { primary, accent, outline, ghost }

class BondlyButton extends StatelessWidget {
  const BondlyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BondlyButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.minimumSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final BondlyButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final Size? minimumSize;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = minimumSize ?? const Size(double.infinity, 54);

    return switch (variant) {
      BondlyButtonVariant.primary => _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
          minimumSize: effectiveSize,
        ),
      BondlyButtonVariant.accent => _AccentButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
          minimumSize: effectiveSize,
        ),
      BondlyButtonVariant.outline => _OutlineButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
          minimumSize: effectiveSize,
        ),
      BondlyButtonVariant.ghost => _GhostButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          minimumSize: effectiveSize,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Variants
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.minimumSize,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? AppColors.primaryGradient
            : null,
        color: onPressed == null ? AppColors.border : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(label, style: AppTypography.buttonText),
                ],
              ),
      ),
    );
  }
}

class _AccentButton extends StatelessWidget {
  const _AccentButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.minimumSize,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        minimumSize: minimumSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.textPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label, style: AppTypography.buttonText),
              ],
            ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.minimumSize,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: minimumSize,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label, style: AppTypography.buttonText),
              ],
            ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.minimumSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: minimumSize,
      ),
      child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
    );
  }
}
