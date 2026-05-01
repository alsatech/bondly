import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../widgets/profile_bonds_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_patterns_section.dart';
import '../widgets/profile_stats_row.dart';

/// Profile screen — matches Bondly design references (profile1.png, profile2.png).
///
/// This is a presentation-only screen. All data is passed in via parameters.
/// When the profile provider is built, replace the placeholder data with
/// `ref.watch(profileProvider)` and wire the real model.
///
/// Layout:
///   [← FEED]  [NAME]  [...]
///   ♦ FOUNDER · VOL. 04         04 (large watermark)
///   [Big Playfair Name]
///   — FOUNDER — MAISON ONYX
///   [bio text]
///   [stats: BONDS | CIRCLE | FOUNDER TIES]
///   [+ BOND btn]  [MESSAGE btn]  [share icon]
///   § PATTERNS 05                 read by Bondly
///   [2-col pattern cards]
///   § BONDS 04                    LATEST 4 OF 248 · …
///   [bond index list]
///   § EVENTS 02
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          _ProfileAppBar(),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Founder badge + volume number (watermark)
                  const ProfileHeader(),

                  const SizedBox(height: 24),

                  // Stats row: Bonds | Circle | Founder Ties
                  const ProfileStatsRow(),

                  const SizedBox(height: 20),

                  // Action buttons: + BOND | MESSAGE | share
                  const _ActionButtons(),

                  const SizedBox(height: 32),

                  // § PATTERNS section
                  const ProfilePatternsSection(),

                  const SizedBox(height: 28),

                  // § BONDS index
                  const ProfileBondsSection(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      floating: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'FEED',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 80,
      centerTitle: true,
      title: Text(
        'SOREN',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action buttons row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // + BOND — gold fill
        Expanded(
          child: _GoldButton(
            label: '+ BOND',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        // MESSAGE — dark outline
        Expanded(
          child: _OutlineButton(
            label: 'MESSAGE',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        // Share icon — square outline
        _IconBox(
          icon: Icons.ios_share_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: const Icon(
          Icons.ios_share_rounded,
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}
