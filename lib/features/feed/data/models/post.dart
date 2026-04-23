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
  });

  final String id;
  final PostAuthor author;
  final String? caption;
  final List<PostMedia> media;
  final int likesCount;
  final bool hasLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>? ?? [];
    final mediaList = rawMedia
        .map((m) => PostMedia.fromJson(m as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

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
    );
  }

  Post copyWith({
    int? likesCount,
    bool? hasLiked,
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
    );
  }

  @override
  List<Object?> get props => [id, author, caption, media, likesCount, hasLiked, createdAt, updatedAt];
}
