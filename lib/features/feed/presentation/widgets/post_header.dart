import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../data/models/post_author.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({
    super.key,
    required this.author,
    required this.createdAt,
    required this.onMenuTap,
  });

  final PostAuthor author;
  final DateTime createdAt;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AuthorAvatar(author: author),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  author.fullName.toLowerCase().replaceAll(' ', '.'),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Time indicator
          Text(
            _formatRelativeTime(createdAt),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          // + BOND CTA — wired to onMenuTap for now (no follow module yet).
          GestureDetector(
            onTap: onMenuTap,
            child: Text(
              '+ BOND',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}H';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}sem';
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.author});

  final PostAuthor author;

  @override
  Widget build(BuildContext context) {
    if (author.avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: author.avatarUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 18,
          backgroundImage: imageProvider,
        ),
        placeholder: (_, __) => _InitialAvatar(initial: author.initial),
        errorWidget: (_, __, ___) => _InitialAvatar(initial: author.initial),
      );
    }
    return _InitialAvatar(initial: author.initial);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.border,
      child: Text(
        initial,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
