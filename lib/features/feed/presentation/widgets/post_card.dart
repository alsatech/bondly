import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
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
            author: widget.post.author,
            createdAt: widget.post.createdAt,
            onMenuTap: widget.onMenuTap,
          ),
          if (widget.post.media.isNotEmpty) ...[
            Stack(
              children: [
                PostMediaView(mediaItems: widget.post.media),
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
            likesCount: widget.post.likesCount,
            hasLiked: widget.post.hasLiked,
            onLikeTap: widget.onLikeTap,
          ),
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            _CaptionSection(
              caption: widget.post.caption!,
              authorName: widget.post.author.fullName,
              expanded: _captionExpanded,
              onToggle: () => setState(() => _captionExpanded = !_captionExpanded),
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
