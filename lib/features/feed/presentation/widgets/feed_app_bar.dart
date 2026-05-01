import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/snack_helper.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FeedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Text(
        'Bondly.',
        style: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () => SnackHelper.showSuccess(context, 'Proximamente'),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        IconButton(
          icon: const Icon(
            Icons.send_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () => SnackHelper.showSuccess(context, 'Proximamente'),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
