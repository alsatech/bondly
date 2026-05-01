import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

/// Three-column stat block:  BONDS | CIRCLE | FOUNDER TIES
///
/// Numbers use Playfair Display italic for the distinctive personality
/// shown in the design reference.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  // Placeholder values — replace with provider model when available.
  static const _bonds = '248';
  static const _circle = '1,124';
  static const _founderTies = '36';

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _StatCell(value: _bonds, label: 'BONDS'),
          _Divider(),
          _StatCell(value: _circle, label: 'CIRCLE'),
          _Divider(),
          _StatCell(
            value: _founderTies,
            label: 'FOUNDER TIES',
            valueColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: valueColor ?? AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.border,
    );
  }
}
