import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../domain/discover_failure.dart';
import 'models/discovery_page.dart';
import 'models/match_result.dart';

class DiscoverRepository {
  DiscoverRepository({required this.dio});

  final Dio dio;

  /// Fetch paginated discovery feed.
  Future<DiscoveryPage> fetchCandidates({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.matchesDiscover,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return DiscoveryPage.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (_) {
      throw const DiscoverUnknownFailure();
    }
  }

  /// Send a like to [userId].
  ///
  /// Returns [MatchResult] on success.
  /// Maps a 409 (already matched) to [DiscoverAlreadyMatchedFailure] instead
  /// of crashing the UI.
  Future<MatchResult> likeUser(String userId) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.matches}/$userId',
      );
      return MatchResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (_) {
      throw const DiscoverUnknownFailure();
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  DiscoverFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const DiscoverNetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String? ??
        e.response?.data?['detail'] as String?;

    return switch (statusCode) {
      409 => const DiscoverAlreadyMatchedFailure(),
      500 || 502 || 503 =>
        DiscoverServerFailure(message ?? 'Error del servidor.'),
      _ => DiscoverUnknownFailure(message ?? e.message ?? 'Error desconocido.'),
    };
  }
}
