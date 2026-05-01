import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

/// § BONDS section — numbered bond index list with thumbnail, category, title, caption.
///
/// Design ref profile2.png shows:
///   № 02  [thumb]  PLACE · 28 APR
///                  Bellweather Coffee  (Playfair)
///                  A corner room, cardamom & cloud.
class ProfileBondsSection extends StatelessWidget {
  const ProfileBondsSection({super.key});

  static const _bonds = [
    _BondItem('01', null, 'EVENT', 'Apr 30', 'Onyx 04 Opening', 'Only candles, only analog.'),
    _BondItem('02', null, 'PLACE', 'Apr 28', 'Bellweather Coffee', 'A corner room, cardamom & cloud.'),
    _BondItem('03', null, 'FOOD', 'Apr 21', 'Le Servan', 'Eight at the bar, no menu.'),
    _BondItem('04', null, 'BRAND', 'Apr 14', 'Outer Harbor Records', 'First 500 of SIDE A pressed today.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _SectionHeaderRow(
          label: 'BONDS',
          count: '04',
          trailing: 'LATEST 4 OF 248 · LAST BOND 2H A...',
        ),
        const SizedBox(height: 14),

        // Bond list
        ...List.generate(_bonds.length, (i) {
          return Column(
            children: [
              _BondRow(bond: _bonds[i]),
              if (i < _bonds.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.border),
                )
              else
                const SizedBox(height: 16),
            ],
          );
        }),

        // View full index link
        GestureDetector(
          onTap: () {},
          child: Text(
            'VIEW THE FULL BONDS INDEX →',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BondItem {
  const _BondItem(
      this.index, this.imageUrl, this.category, this.date, this.title, this.subtitle);
  final String index;
  final String? imageUrl;
  final String category;
  final String date;
  final String title;
  final String subtitle;
}

class _BondRow extends StatelessWidget {
  const _BondRow({required this.bond});
  final _BondItem bond;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index watermark
        SizedBox(
          width: 40,
          child: Text(
            'No${bond.index}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: AppColors.border,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // Thumbnail — placeholder box (no live images yet)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: const Icon(
            Icons.image_outlined,
            color: AppColors.border,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        // Text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category · date
              Text(
                '${bond.category} · ${bond.date.toUpperCase()}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              // Title in Playfair
              Text(
                bond.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Subtitle
              Text(
                bond.subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header row (shared)
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
          Flexible(
            child: Text(
              trailing!,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
