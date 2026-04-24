import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../features/feed/data/models/post.dart';
import '../domain/post_create_failure.dart';

class PostsRepository {
  const PostsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Post> createPost({
    String? caption,
    required bool isPrivate,
    bool isEvent = false,
    bool isSale = false,
    String? musicName,
    String? musicArtist,
    String? locationName,
    String? locationArea,
    String? externalUrl,
    List<String> brandIds = const [],
    List<File> mediaFiles = const [],
    // Sale-only
    int? priceCents,
    String? productType,
    bool? isFree,
  }) async {
    try {
      final formData = FormData();

      // Scalar fields
      if (caption != null && caption.isNotEmpty) {
        formData.fields.add(MapEntry('caption', caption));
      }
      formData.fields.add(MapEntry('is_private', isPrivate.toString()));
      formData.fields.add(MapEntry('is_event', isEvent.toString()));
      formData.fields.add(MapEntry('is_sale', isSale.toString()));

      if (musicName != null && musicName.isNotEmpty) {
        formData.fields.add(MapEntry('music_name', musicName));
      }
      if (musicArtist != null && musicArtist.isNotEmpty) {
        formData.fields.add(MapEntry('music_artist', musicArtist));
      }
      if (locationName != null && locationName.isNotEmpty) {
        formData.fields.add(MapEntry('location_name', locationName));
      }
      if (locationArea != null && locationArea.isNotEmpty) {
        formData.fields.add(MapEntry('location_area', locationArea));
      }
      if (externalUrl != null && externalUrl.isNotEmpty) {
        formData.fields.add(MapEntry('external_url', externalUrl));
      }

      // Brand IDs — repeated key (standard multipart list)
      for (final id in brandIds) {
        formData.fields.add(MapEntry('brand_ids', id));
      }

      // Sale fields
      if (isSale) {
        if (priceCents != null) {
          formData.fields.add(MapEntry('price_cents', priceCents.toString()));
        }
        if (productType != null && productType.isNotEmpty) {
          formData.fields.add(MapEntry('product_type', productType));
        }
        if (isFree != null) {
          formData.fields.add(MapEntry('is_free', isFree.toString()));
        }
      }

      // Media files
      for (final file in mediaFiles) {
        final filename = file.path.split('/').last;
        formData.files.add(MapEntry(
          'media',
          await MultipartFile.fromFile(file.path, filename: filename),
        ));
      }

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.posts,
        data: formData,
        options: Options(
          // Override content-type: Dio sets multipart automatically when FormData
          // is passed, but we null the default 'application/json' header so Dio
          // can write the correct boundary.
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;
      if (data == null) throw const PostCreateServerFailure();

      return Post.fromJson(data);
    } on PostCreateFailure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw const PostCreateUnknownFailure();
    }
  }

  PostCreateFailure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const PostCreateNetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 422) {
          return PostCreateValidationFailure(
            e.response?.data?['detail']?.toString() ??
                'Datos inválidos. Revisa los campos.',
          );
        }
        if (statusCode >= 500) return const PostCreateServerFailure();
        return PostCreateServerFailure(
          e.response?.data?['detail']?.toString() ?? 'Error del servidor.',
        );
      default:
        return const PostCreateUnknownFailure();
    }
  }
}
