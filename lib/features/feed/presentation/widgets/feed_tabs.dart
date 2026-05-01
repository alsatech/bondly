import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../providers/feed_notifier.dart';

class FeedTabs extends StatelessWidget {
  const FeedTabs({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  final FeedTab activeTab;
  final ValueChanged<FeedTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FeedTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tab = FeedTab.values[index];
          final isActive = tab == activeTab;
          return _FeedTabChip(
            tab: tab,
            isActive: isActive,
            onTap: () => onTabSelected(tab),
          );
        },
      ),
    );
  }
}

class _FeedTabChip extends StatelessWidget {
  const _FeedTabChip({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final FeedTab tab;
  final bool isActive;
  final VoidCallback onTap;

  /// Returns true only for the Founders tab, which gets a diamond prefix icon.
  bool get _isFounders => tab == FeedTab.founders;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isFounders) ...[
              Icon(
                Icons.diamond_outlined,
                size: 12,
                color: isActive ? Colors.black : AppColors.gold,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              // Strip the leading "★ " from the label — we render the icon above.
              _isFounders ? 'Founders' : tab.label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? Colors.black : AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
