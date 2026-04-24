import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/snack_helper.dart';

class PostActionsRow extends StatelessWidget {
  const PostActionsRow({
    super.key,
    required this.likesCount,
    required this.hasLiked,
    required this.commentsCount,
    required this.onLikeTap,
  });

  final int likesCount;
  final bool hasLiked;
  final int commentsCount;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Like button — wired to backend.
          _LikeButton(
            likesCount: likesCount,
            hasLiked: hasLiked,
            onTap: onLikeTap,
          ),
          const SizedBox(width: 16),
          // Comment count — no-op tap (no comments module yet).
          _CountIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: commentsCount,
            onTap: () => SnackHelper.showSuccess(context, 'Próximamente'),
          ),
          const SizedBox(width: 16),
          // Share — no-op.
          _NoopIconButton(
            icon: Icons.send_outlined,
            onTap: () => SnackHelper.showSuccess(context, 'Próximamente'),
          ),
          const Spacer(),
          // Bookmark — no-op.
          _NoopIconButton(
            icon: Icons.bookmark_border_rounded,
            onTap: () => SnackHelper.showSuccess(context, 'Próximamente'),
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.likesCount,
    required this.hasLiked,
    required this.onTap,
  });

  final int likesCount;
  final bool hasLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              hasLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(hasLiked),
              color: hasLiked ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _formatCount(likesCount),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: hasLiked ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _NoopIconButton extends StatelessWidget {
  const _NoopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, color: AppColors.textSecondary, size: 22),
    );
  }
}

class _CountIconButton extends StatelessWidget {
  const _CountIconButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
