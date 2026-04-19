import 'package:flutter/material.dart';

abstract final class AppColors {
  // Emotional (Branding)
  static const primary = Color(0xFFFF5A5F);
  static const primaryHover = Color(0xFFFF7A7F);

  // Action (CTAs)
  static const accent = Color(0xFF6C63FF);
  static const accentHover = Color(0xFF8B85FF);
  static const success = Color(0xFF2ECC71);

  // Neutral Base (UX)
  static const background = Color(0xFF0F0F12);
  static const card = Color(0xFF1C1C22);
  static const border = Color(0xFF2A2A33);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B8);

  // Shimmer
  static const shimmerBase = Color(0xFF1C1C22);
  static const shimmerHighlight = Color(0xFF2A2A33);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C22), Color(0xFF0F0F12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
