import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_failure.dart';
import 'models/auth_tokens.dart';
import 'models/register_request.dart';
import 'models/user_model.dart';

class AuthRepository {
  AuthRepository({
    required this.dio,
    required this.storage,
  });

  final Dio dio;
  final SecureStorageService storage;

  /// Login with email and password. Saves tokens on success.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // Fetch full user profile after login
      return getMe();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Multi-step registration. Persists interests + photo if provided.
  ///
  /// Steps 2 and 3 are best-effort: if they fail the account is still valid
  /// and the user can retry from the profile editor.
  Future<UserModel> register(RegisterRequest request) async {
    try {
      // Step 1: create account + store tokens
      final response = await dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // Step 2: persist interests
      if (request.interests.isNotEmpty) {
        try {
          await _setInterests(request.interests);
        } catch (_) {}
      }

      // Step 3: upload profile photo
      if (request.profilePhotoPath != null) {
        try {
          await _uploadProfilePhoto(request.profilePhotoPath!);
        } catch (_) {}
      }

      return getMe();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Refresh the access token using the stored refresh token.
  Future<AuthTokens> refreshToken() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) throw const TokenExpired();

      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return tokens;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Fetch the current authenticated user profile.
  Future<UserModel> getMe() async {
    try {
      final response = await dio.get(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;

      // Backend may wrap response in a 'user' or 'data' key
      final userJson = data['user'] as Map<String, dynamic>? ??
          data['data'] as Map<String, dynamic>? ??
          data;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Sign out — clears local tokens.
  Future<void> logout() async {
    await storage.clearTokens();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _setInterests(List<String> interests) async {
    await dio.put(
      ApiEndpoints.myInterests,
      data: {'interests': interests},
    );
  }

  Future<void> _uploadProfilePhoto(String filePath) async {
    // TODO: The backend POST /users/me/photos expects a JSON body with a
    // pre-uploaded URL (PhotoCreate schema), not a multipart file. We'll
    // need an upload service (S3/Cloudinary) before this works. For now
    // we keep the call so the flow is wired, but it will 422.
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        filePath,
        filename: File(filePath).uri.pathSegments.last,
      ),
    });

    await dio.post(
      ApiEndpoints.myPhotos,
      data: formData,
    );
  }

  AuthFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String? ??
        e.response?.data?['detail'] as String?;

    return switch (statusCode) {
      400 => EmailAlreadyInUse(),
      401 => InvalidCredentials(),
      409 => EmailAlreadyInUse(),
      500 || 502 || 503 => ServerFailure(message ?? 'Error del servidor.'),
      _ => UnknownFailure(message ?? e.message ?? 'Error desconocido.'),
    };
  }
}
