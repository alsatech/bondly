import 'package:equatable/equatable.dart';
import 'post.dart';

class FeedPage extends Equatable {
  const FeedPage({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });

  final List<Post> posts;

  /// ISO-8601 timestamp used as the cursor for the next page request.
  final String? nextCursor;
  final bool hasMore;

  factory FeedPage.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'] as List<dynamic>? ?? [];
    return FeedPage(
      posts: rawPosts
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [posts, nextCursor, hasMore];
}
