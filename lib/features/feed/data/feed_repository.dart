import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../domain/feed_failure.dart';
import 'models/feed_page.dart';
import 'models/like_result.dart';

class FeedRepository {
  const FeedRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches a page of feed posts.
  ///
  /// [cursor] is an ISO-8601 timestamp from the previous page's [FeedPage.nextCursor].
  /// Pass null to fetch from the top of the feed.
  Future<FeedPage> fetchFeed({int limit = 20, String? cursor}) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (cursor != null) params['cursor'] = cursor;

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.postsFeed,
        queryParameters: params,
      );

      final data = response.data;
      if (data == null) throw const FeedServerFailure();

      return FeedPage.fromJson(data);
    } on FeedFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const FeedUnknownFailure();
    }
  }

  /// Toggles like on [postId]. Returns the updated like state from the server.
  Future<LikeResult> toggleLike(String postId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.postLike(postId),
      );

      final data = response.data;
      if (data == null) throw const FeedServerFailure();

      return LikeResult.fromJson(data);
    } on FeedFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const FeedUnknownFailure();
    }
  }

  FeedFailure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const FeedNetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 500) return const FeedServerFailure();
        return FeedServerFailure(
          e.response?.data?['detail']?.toString() ?? 'Error del servidor.',
        );
      default:
        return const FeedUnknownFailure();
    }
  }
}
