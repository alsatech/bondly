import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.dio,
  });

  final SecureStorageService storage;
  final Dio dio;

  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints that do not need a token
    final skipPaths = [ApiEndpoints.login, ApiEndpoints.register];
    if (skipPaths.any((p) => options.path.contains(p))) {
      return handler.next(options);
    }

    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;
      try {
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null) {
          await storage.clearTokens();
          _isRefreshing = false;
          return handler.next(err);
        }

        final response = await dio.post(
          ApiEndpoints.refresh,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken == null) {
          await storage.clearTokens();
          _isRefreshing = false;
          return handler.next(err);
        }

        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        // Retry original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(err.requestOptions);

        // Retry pending requests
        for (final pending in _pendingRequests) {
          pending.headers['Authorization'] = 'Bearer $newAccessToken';
          dio.fetch(pending);
        }
        _pendingRequests.clear();
        _isRefreshing = false;

        return handler.resolve(retryResponse);
      } catch (e) {
        await storage.clearTokens();
        _pendingRequests.clear();
        _isRefreshing = false;
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
