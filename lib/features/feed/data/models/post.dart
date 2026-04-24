import 'package:equatable/equatable.dart';
import 'post_author.dart';
import 'post_media.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.author,
    this.caption,
    required this.media,
    required this.likesCount,
    required this.hasLiked,
    required this.createdAt,
    required this.updatedAt,
    this.isPrivate = false,
    this.isEvent = false,
    this.isSale = false,
    this.musicName,
    this.musicArtist,
    this.locationName,
    this.locationArea,
    this.externalUrl,
    this.brandIds = const [],
    this.commentsCount = 0,
    this.priceCents,
    this.productType,
    this.isFree,
  });

  final String id;
  final PostAuthor author;
  final String? caption;
  final List<PostMedia> media;
  final int likesCount;
  final bool hasLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extended fields
  final bool isPrivate;
  final bool isEvent;
  final bool isSale;
  final String? musicName;
  final String? musicArtist;
  final String? locationName;
  final String? locationArea;
  final String? externalUrl;
  final List<String> brandIds;
  final int commentsCount;

  // Sale-only fields
  final int? priceCents;
  final String? productType;
  final bool? isFree;

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>? ?? [];
    final mediaList = rawMedia
        .map((m) => PostMedia.fromJson(m as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    // Brand IDs: backend may return brands as objects or just ids.
    final rawBrands = json['brands'] as List<dynamic>? ?? [];
    final brandIds = rawBrands.map((b) {
      if (b is Map<String, dynamic>) return b['id']?.toString() ?? '';
      return b.toString();
    }).where((id) => id.isNotEmpty).toList();

    return Post(
      id: json['id']?.toString() ?? '',
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      caption: json['caption'] as String?,
      media: mediaList,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      hasLiked: json['has_liked'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      isPrivate: json['is_private'] as bool? ?? false,
      isEvent: json['is_event'] as bool? ?? false,
      isSale: json['is_sale'] as bool? ?? false,
      musicName: json['music_name'] as String?,
      musicArtist: json['music_artist'] as String?,
      locationName: json['location_name'] as String?,
      locationArea: json['location_area'] as String?,
      externalUrl: json['external_url'] as String?,
      brandIds: brandIds,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      priceCents: (json['price_cents'] as num?)?.toInt(),
      productType: json['product_type'] as String?,
      isFree: json['is_free'] as bool?,
    );
  }

  Post copyWith({
    int? likesCount,
    bool? hasLiked,
    int? commentsCount,
    bool? isPrivate,
    bool? isEvent,
    bool? isSale,
    String? musicName,
    String? musicArtist,
    String? locationName,
    String? locationArea,
    String? externalUrl,
    List<String>? brandIds,
    int? priceCents,
    String? productType,
    bool? isFree,
  }) {
    return Post(
      id: id,
      author: author,
      caption: caption,
      media: media,
      likesCount: likesCount ?? this.likesCount,
      hasLiked: hasLiked ?? this.hasLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPrivate: isPrivate ?? this.isPrivate,
      isEvent: isEvent ?? this.isEvent,
      isSale: isSale ?? this.isSale,
      musicName: musicName ?? this.musicName,
      musicArtist: musicArtist ?? this.musicArtist,
      locationName: locationName ?? this.locationName,
      locationArea: locationArea ?? this.locationArea,
      externalUrl: externalUrl ?? this.externalUrl,
      brandIds: brandIds ?? this.brandIds,
      commentsCount: commentsCount ?? this.commentsCount,
      priceCents: priceCents ?? this.priceCents,
      productType: productType ?? this.productType,
      isFree: isFree ?? this.isFree,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        caption,
        media,
        likesCount,
        hasLiked,
        createdAt,
        updatedAt,
        isPrivate,
        isEvent,
        isSale,
        musicName,
        musicArtist,
        locationName,
        locationArea,
        externalUrl,
        brandIds,
        commentsCount,
        priceCents,
        productType,
        isFree,
      ];
}
