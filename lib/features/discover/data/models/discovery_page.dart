import 'package:equatable/equatable.dart';
import 'discovery_candidate.dart';

class DiscoveryPage extends Equatable {
  const DiscoveryPage({
    required this.candidates,
    required this.nextOffset,
    required this.hasMore,
  });

  final List<DiscoveryCandidate> candidates;
  final int nextOffset;
  final bool hasMore;

  factory DiscoveryPage.fromJson(Map<String, dynamic> json) {
    final rawList = json['candidates'] as List<dynamic>? ?? const [];
    return DiscoveryPage(
      candidates: rawList
          .map((e) => DiscoveryCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextOffset: (json['next_offset'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [candidates, nextOffset, hasMore];
}
