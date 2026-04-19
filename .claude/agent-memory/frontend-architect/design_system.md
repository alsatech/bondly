---
name: Design System
description: Bondly color palette, typography, spacing, and component conventions
type: reference
---

## Colors (AppColors — lib/core/constants/app_colors.dart)
- `background` #0F0F12
- `card` #1C1C22
- `border` #2A2A33
- `primary` #FF5A5F (coral — emotional/branding)
- `primaryHover` #FF7A7F
- `accent` #6C63FF (purple — CTAs)
- `accentHover` #8B85FF
- `success` #2ECC71 (match moment)
- `textPrimary` #FFFFFF
- `textSecondary` #B0B0B8
- `shimmerBase` #1C1C22, `shimmerHighlight` #2A2A33

## Typography (AppTypography — lib/core/constants/app_typography.dart)
- Headlines/Display: **Playfair Display** (google_fonts)
- Body/UI: **DM Sans** (google_fonts)
- Theme applied globally via AppTheme.dark

## Component conventions
- Cards: rounded 16px, border AppColors.border, no elevation
- Inputs: rounded 14px, filled with AppColors.card, focus border AppColors.primary
- Buttons: rounded 14px, height 54px, primary uses gradient (coral→purple)
- Shimmer: BondlyShimmer wrapper (base #1C1C22, highlight #2A2A33)
- Snackbars: floating, rounded 12px, card background, icon prefix

## Animations
- Page transitions: fade (350ms) + slide for auth screens
- Widgets: AnimatedContainer (200–300ms, easeOut/easeOutCubic)
- Entry animations: SlideTransition from Offset(0, 0.06) + FadeTransition

## Spacing
- Screen horizontal padding: 24px
- Section gaps: 16px (fields), 32px (sections), 48px (large gaps)
- Button full-width by default (Size(double.infinity, 54))
