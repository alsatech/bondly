import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

/// § PATTERNS section — 2-column insight cards.
///
/// Design ref shows: section header "§ PATTERNS 05  read by Bondly",
/// then two cards per row with italic Playfair value text + signal %.
class ProfilePatternsSection extends StatelessWidget {
  const ProfilePatternsSection({super.key});

  static const _patterns = [
    _PatternData('YOU BOND MOST WITH', 'private events', '34%', '01'),
    _PatternData('YOUR FAVORITE HOUR', '21:00 — 23:00', null, '02'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _SectionHeaderRow(
          label: 'PATTERNS',
          count: '05',
          trailing: 'read by Bondly',
        ),
        const SizedBox(height: 12),
        // Cards grid — 2 columns
        Row(
          children: [
            Expanded(child: _PatternCard(data: _patterns[0])),
            const SizedBox(width: 10),
            Expanded(child: _PatternCard(data: _patterns[1])),
          ],
        ),
      ],
    );
  }
}

class _PatternData {
  const _PatternData(this.label, this.value, this.signal, this.index);
  final String label;
  final String value;
  final String? signal;
  final String index;
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.data});
  final _PatternData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index
          Text(
            data.index,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            data.label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Value — Playfair italic
          Text(
            data.value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          if (data.signal != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'SIGNAL',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  data.signal!,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section header row: § LABEL  COUNT          trailing text
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({
    required this.label,
    required this.count,
    this.trailing,
  });

  final String label;
  final String count;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '§ ',
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          count,
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.playfairDisplay(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
