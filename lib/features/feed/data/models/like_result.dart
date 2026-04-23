import 'package:equatable/equatable.dart';

class LikeResult extends Equatable {
  const LikeResult({
    required this.postId,
    required this.liked,
    required this.likesCount,
  });

  final String postId;
  final bool liked;
  final int likesCount;

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      postId: json['post_id']?.toString() ?? '',
      liked: json['liked'] as bool? ?? false,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [postId, liked, likesCount];
}
