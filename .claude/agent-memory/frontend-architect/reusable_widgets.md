---
name: Reusable Widgets
description: Shared and feature-specific widgets created in the Bondly frontend
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

## Discover widgets (lib/features/discover/presentation/widgets/)

### DiscoverCard (discover_card.dart)
Displays a single candidate card. Props: candidate (DiscoveryCandidate), swipeDirection (double -1..1 for overlay tint).
Shows avatar with gradient fallback, full name (Playfair Display), bio (3 lines), interest badge, affinity badge.

### LikeActionButton / SkipActionButton (discover_action_button.dart)
Circular buttons for like (green heart) and skip (gray X). Props: onPressed, size.
Note: Originally designed with factory constructors + private enum but refactored to two separate widgets to avoid library_private_types_in_public_api lint.

### MatchModal (match_modal.dart)
Full-screen overlay for mutual match moment. Props: matchedName, onContinue.
Uses coral→purple gradient, scale+fade animation (320ms easeOutBack). Never dismisses itself.

### DiscoverEmptyState (discover_empty_state.dart)
Centered illustration + copy + Refrescar button. Props: onRefresh.

### DiscoverShimmer (discover_shimmer.dart)
Shimmer placeholder for card stack loading state. No props.

## Auth widgets (lib/features/auth/presentation/widgets/)

### AuthStepIndicator (auth_step_indicator.dart)
Animated horizontal progress bar for multi-step forms.
Props: totalSteps, currentStep

### InterestChip (interest_chip.dart)
Selectable chip with animated border/color toggle.
Props: label, isSelected, onTap

## Posts / Create Post widgets (lib/features/posts/presentation/widgets/)

### MediaPickerSection (media_picker_section.dart)
Shows empty dashed zone or horizontal thumbnail grid.
Props: mediaFiles, onAdd, onRemove, enabled.
Exports `pickMediaFiles(context)` async helper that shows a bottom sheet for gallery/camera selection.

### BrandChipsSelector (brand_chips_selector.dart)
ConsumerWidget — watches `brandsProvider`. Renders FilterChip Wrap (multiselect).
Props: selectedIds (Set<String>), onChanged, enabled.
Loading: small CircularProgressIndicator. Error: "No se pudieron cargar marcas" + reintentar.

### SaleSection (sale_section.dart)
Sale-specific fields: price TextField (numeric → cents on submit), product type DropdownButtonFormField, isFree SwitchListTile.
Props: priceController, selectedProductType, isFree, onProductTypeChanged, onIsFreeChanged, enabled.

### LocationMusicSection (location_music_section.dart)
Two TextFields for location (name + area) and two for music (name + artist).
Props: 4 controllers, enabled.
