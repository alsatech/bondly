import 'package:equatable/equatable.dart';

class MatchResult extends Equatable {
  const MatchResult({
    required this.matchId,
    required this.targetUserId,
    required this.status,
    required this.score,
  });

  final String matchId;
  final String targetUserId;
  final String status;
  final double score;

  /// True when both users liked each other (mutual match).
  bool get isMutualMatch => status == 'accepted';

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      matchId: json['match_id']?.toString() ?? '',
      targetUserId: json['target_user_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'pending',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [matchId, targetUserId, status, score];
}
