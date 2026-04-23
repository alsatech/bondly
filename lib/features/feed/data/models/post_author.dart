import 'package:equatable/equatable.dart';

class PostAuthor extends Equatable {
  const PostAuthor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  String get initial => fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}
