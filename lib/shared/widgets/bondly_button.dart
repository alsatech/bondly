import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

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

/// Primary — dark warm/gold tinted background, uppercase spaced label with star flankers.
/// Matches the "ENTER THE ROOM" / "CREATE ACCOUNT" style from design refs.
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
    final enabled = onPressed != null && !isLoading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(
            minWidth: minimumSize.width,
            minHeight: minimumSize.height,
          ),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF2B2318) // warm dark gold-tinted
                : AppColors.border,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? AppColors.gold.withValues(alpha: 0.35)
                  : AppColors.border,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: AppColors.gold,
                  ),
                )
              : icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [icon!, const SizedBox(width: 8), _ButtonLabel(label)],
                    )
                  : _ButtonLabel(label),
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '★',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.gold,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '★',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.gold,
            letterSpacing: 0,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.textPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Outline — subtle border, gold text, for secondary actions like "Skip for now".
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
        foregroundColor: AppColors.gold,
        minimumSize: minimumSize,
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4), width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.gold,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gold,
                    letterSpacing: 0.5,
                  ),
                ),
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
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
