import 'package:equatable/equatable.dart';

class DiscoveryCandidate extends Equatable {
  const DiscoveryCandidate({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.gender,
    required this.score,
    required this.sharedInterestsCount,
    required this.isMutualFollow,
  });

  final String id;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? gender;
  final double score;
  final int sharedInterestsCount;
  final bool isMutualFollow;

  factory DiscoveryCandidate.fromJson(Map<String, dynamic> json) {
    return DiscoveryCandidate(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      sharedInterestsCount:
          (json['shared_interests_count'] as num?)?.toInt() ?? 0,
      isMutualFollow: json['is_mutual_follow'] as bool? ?? false,
    );
  }

  /// Returns the initial letter of the full name for avatar placeholder.
  String get initial =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [
        id,
        fullName,
        bio,
        avatarUrl,
        gender,
        score,
        sharedInterestsCount,
        isMutualFollow,
      ];
}
