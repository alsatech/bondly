import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../data/models/post.dart';
import 'post_actions_row.dart';
import 'post_header.dart';
import 'post_media_view.dart';
import 'post_overlay.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onMenuTap,
  });

  final Post post;
  final VoidCallback onLikeTap;
  final VoidCallback onMenuTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _captionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            author: post.author,
            createdAt: post.createdAt,
            onMenuTap: widget.onMenuTap,
          ),
          // Badges row (private / for sale)
          if (post.isPrivate || post.isSale)
            _BadgesRow(isPrivate: post.isPrivate, isSale: post.isSale, priceCents: post.priceCents),
          if (post.media.isNotEmpty) ...[
            Stack(
              children: [
                PostMediaView(mediaItems: post.media),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PostOverlay(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          PostActionsRow(
            likesCount: post.likesCount,
            hasLiked: post.hasLiked,
            commentsCount: post.commentsCount,
            onLikeTap: widget.onLikeTap,
          ),
          if (post.caption != null && post.caption!.isNotEmpty)
            _CaptionSection(
              caption: post.caption!,
              authorName: post.author.fullName,
              expanded: _captionExpanded,
              onToggle: () => setState(() => _captionExpanded = !_captionExpanded),
            ),
          // Location
          if (post.locationName != null && post.locationName!.isNotEmpty)
            _MetaRow(
              icon: Icons.location_on_outlined,
              primary: post.locationName!,
              secondary: post.locationArea,
            ),
          // Music
          if (post.musicName != null && post.musicName!.isNotEmpty)
            _MetaRow(
              icon: Icons.music_note_outlined,
              primary: post.musicArtist != null && post.musicArtist!.isNotEmpty
                  ? '${post.musicName} — ${post.musicArtist}'
                  : post.musicName!,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CaptionSection extends StatelessWidget {
  const _CaptionSection({
    required this.caption,
    required this.authorName,
    required this.expanded,
    required this.onToggle,
  });

  final String caption;
  final String authorName;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$authorName ',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: caption,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        maxLines: expanded ? null : 2,
        overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badges (private / for sale)
// ---------------------------------------------------------------------------

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({
    required this.isPrivate,
    required this.isSale,
    this.priceCents,
  });

  final bool isPrivate;
  final bool isSale;
  final int? priceCents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (isPrivate)
            _Badge(
              label: 'Privado',
              icon: Icons.lock_outline_rounded,
              color: AppColors.textSecondary,
            ),
          if (isSale)
            _Badge(
              label: priceCents != null
                  ? 'En venta \$${(priceCents! / 100).toStringAsFixed(0)}'
                  : 'En venta',
              icon: Icons.sell_outlined,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meta row (location / music)
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.primary,
    this.secondary,
  });

  final IconData icon;
  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondary != null && secondary!.isNotEmpty)
                  Text(
                    secondary!,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
