---
name: Reusable Widgets
description: Shared and auth-specific widgets created in the Bondly frontend
type: reference
---

## Shared widgets (lib/shared/widgets/)

### BondlyButton (bondly_button.dart)
Variants: primary (coral-purple gradient), accent (purple), outline, ghost
Props: label, onPressed, variant, isLoading, icon, minimumSize
Always pass `isLoading` to disable and show spinner.

### BondlyTextField (bondly_text_field.dart)
Wraps TextFormField with Bondly styling. Handles password toggle.
Props: controller, label, hint, prefixIcon, suffixIcon, isPassword, keyboardType, validator, onChanged, textInputAction, onFieldSubmitted, enabled, maxLines, autofocus

### BondlyShimmer / ShimmerBox / ShimmerCircle (bondly_shimmer.dart)
BondlyShimmer wraps any widget in shimmer animation.
ShimmerBox: rectangular placeholder (width, height, borderRadius).
ShimmerCircle: circular placeholder (size).

### SnackHelper (snack_helper.dart)
Static helpers: SnackHelper.showError(context, message), SnackHelper.showSuccess(context, message)
Both are floating snackbars with icon prefix.

## Auth widgets (lib/features/auth/presentation/widgets/)

### AuthStepIndicator (auth_step_indicator.dart)
Animated horizontal progress bar for multi-step forms.
Props: totalSteps, currentStep

### InterestChip (interest_chip.dart)
Selectable chip with animated border/color toggle.
Props: label, isSelected, onTap
