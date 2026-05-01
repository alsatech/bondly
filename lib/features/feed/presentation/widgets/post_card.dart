import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/snack_helper.dart';
import '../../data/models/post.dart';
import '../../data/models/post_media.dart';
import 'post_header.dart';

/// Main post card — matches the Bondly design reference:
///
///  [avatar · username · time · +BOND]
///  [PLACE icon  LocationName (Playfair)]
///  [— area subtitle]
///  [image 1:1 | drop-cap caption body]
///  [music bar]
///  [N  THREADS / REPLY / SHARE  ] [bookmark]
///
/// Like button + count live on the left edge vertically (design ref post1/post3).
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
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final hasMedia = post.media.isNotEmpty;
    final hasLocation = post.locationName != null && post.locationName!.isNotEmpty;
    final hasMusic = post.musicName != null && post.musicName!.isNotEmpty;
    final hasCaption = post.caption != null && post.caption!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left edge: like button + count column ──────────────────────────
          _LikeColumn(
            likesCount: post.likesCount,
            hasLiked: post.hasLiked,
            onTap: widget.onLikeTap,
          ),
          // ── Main content ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: avatar · username · time · +BOND
                PostHeader(
                  author: post.author,
                  createdAt: post.createdAt,
                  onMenuTap: widget.onMenuTap,
                ),

                // Location block
                if (hasLocation) ...[
                  _LocationBlock(
                    category: _inferCategory(post),
                    locationName: post.locationName!,
                    locationArea: post.locationArea,
                  ),
                  const SizedBox(height: 8),
                ],

                // Image + caption side-by-side (when both present)
                if (hasMedia || hasCaption)
                  _MediaCaptionRow(
                    mediaItems: post.media,
                    caption: post.caption,
                    hasMedia: hasMedia,
                    hasCaption: hasCaption,
                  ),

                // Music bar
                if (hasMusic) ...[
                  const SizedBox(height: 8),
                  _MusicBar(
                    musicName: post.musicName!,
                    musicArtist: post.musicArtist,
                  ),
                ],

                const SizedBox(height: 10),

                // Bottom actions row
                _BottomActionsRow(
                  commentsCount: post.commentsCount,
                  onReplyTap: () =>
                      SnackHelper.showSuccess(context, 'Proximamente'),
                  onShareTap: () =>
                      SnackHelper.showSuccess(context, 'Proximamente'),
                  onBookmarkTap: () =>
                      SnackHelper.showSuccess(context, 'Proximamente'),
                ),

                // Divider at card bottom
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(height: 1, color: AppColors.border),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Infer a display category label from post flags.
  String _inferCategory(Post post) {
    if (post.isEvent) return 'EVENT';
    if (post.isSale) return 'BRAND';
    if (post.locationArea != null &&
        post.locationArea!.toLowerCase().contains('food')) {
      return 'FOOD';
    }
    return 'PLACE';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Like column (left edge, vertical)
// ─────────────────────────────────────────────────────────────────────────────

class _LikeColumn extends StatelessWidget {
  const _LikeColumn({
    required this.likesCount,
    required this.hasLiked,
    required this.onTap,
  });

  final int likesCount;
  final bool hasLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 4, right: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                hasLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(hasLiked),
                color: hasLiked ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt(likesCount),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: hasLiked ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location block
// ─────────────────────────────────────────────────────────────────────────────

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({
    required this.category,
    required this.locationName,
    this.locationArea,
  });

  final String category;
  final String locationName;
  final String? locationArea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PLACE · pin icon
          Row(
            children: [
              Text(
                '$category ',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Location name in Playfair Display
          Text(
            locationName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (locationArea != null && locationArea!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                '— ${locationArea!.toUpperCase()}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image + Caption side-by-side row
// ─────────────────────────────────────────────────────────────────────────────

class _MediaCaptionRow extends StatelessWidget {
  const _MediaCaptionRow({
    required this.mediaItems,
    required this.caption,
    required this.hasMedia,
    required this.hasCaption,
  });

  final List<PostMedia> mediaItems;
  final String? caption;
  final bool hasMedia;
  final bool hasCaption;

  @override
  Widget build(BuildContext context) {
    // If only caption, no image — full-width text.
    if (!hasMedia && hasCaption) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: _DropCapText(caption: caption!),
      );
    }

    // If only image, no caption — full-width image (4:3 ratio).
    if (hasMedia && !hasCaption) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: _NetworkImage(url: mediaItems.first.displayUrl),
          ),
        ),
      );
    }

    // Both present: image square on the left, drop-cap text on the right.
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square image (relative to parent width)
          SizedBox(
            width: 130,
            height: 130,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _NetworkImage(url: mediaItems.first.displayUrl),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DropCapText(caption: caption!),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppColors.border),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.border,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}

/// Drop-cap style body text: first letter large + rest of text inline.
class _DropCapText extends StatelessWidget {
  const _DropCapText({required this.caption});
  final String caption;

  @override
  Widget build(BuildContext context) {
    if (caption.isEmpty) return const SizedBox.shrink();

    final firstChar = caption.characters.first;
    final rest = caption.length > 1 ? caption.substring(1) : '';

    return RichText(
      text: TextSpan(
        children: [
          // Drop-cap first letter
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Text(
                firstChar,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 0.9,
                ),
              ),
            ),
          ),
          TextSpan(
            text: rest,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Music bar
// ─────────────────────────────────────────────────────────────────────────────

class _MusicBar extends StatelessWidget {
  const _MusicBar({required this.musicName, this.musicArtist});

  final String musicName;
  final String? musicArtist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Waveform-style icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              musicArtist != null && musicArtist!.isNotEmpty
                  ? '$musicName — $musicArtist'
                  : musicName,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom actions row: N THREADS / REPLY / SHARE  [bookmark]
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionsRow extends StatelessWidget {
  const _BottomActionsRow({
    required this.commentsCount,
    required this.onReplyTap,
    required this.onShareTap,
    required this.onBookmarkTap,
  });

  final int commentsCount;
  final VoidCallback onReplyTap;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Thread count
          if (commentsCount > 0) ...[
            Text(
              commentsCount.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
          ],
          _ActionLabel(
            label: commentsCount > 0 ? 'THREADS' : 'THREADS',
            onTap: onReplyTap,
          ),
          _Divider(),
          _ActionLabel(label: 'REPLY', onTap: onReplyTap),
          _Divider(),
          _ActionLabel(label: 'SHARE', onTap: onShareTap),
          const Spacer(),
          // Bookmark
          GestureDetector(
            onTap: onBookmarkTap,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '/',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: AppColors.border,
        ),
      ),
    );
  }
}
