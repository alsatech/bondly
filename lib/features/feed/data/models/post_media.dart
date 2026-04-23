import 'package:equatable/equatable.dart';

enum MediaContentType { photo, video }

class PostMedia extends Equatable {
  const PostMedia({
    required this.id,
    required this.url,
    required this.contentType,
    this.thumbnailUrl,
    this.durationSeconds,
    required this.position,
  });

  final String id;
  final String url;
  final MediaContentType contentType;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final int position;

  bool get isVideo => contentType == MediaContentType.video;
  bool get isPhoto => contentType == MediaContentType.photo;

  /// URL to display: thumbnail for video, direct URL for photo.
  String get displayUrl => isVideo ? (thumbnailUrl ?? url) : url;

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    final rawType = json['content_type'] as String? ?? 'photo';
    return PostMedia(
      id: json['id']?.toString() ?? '',
      url: json['url'] as String? ?? '',
      contentType: rawType == 'video'
          ? MediaContentType.video
          : MediaContentType.photo,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, url, contentType, thumbnailUrl, durationSeconds, position];
}
