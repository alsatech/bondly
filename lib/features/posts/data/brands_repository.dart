import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../domain/post_create_failure.dart';
import 'models/brand.dart';

class BrandsRepository {
  const BrandsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<Brand>> fetchBrands() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.brands);

      final data = response.data;
      if (data == null) return [];

      final list = data as List<dynamic>;
      return list
          .map((e) => Brand.fromJson(e as Map<String, dynamic>))
          .toList();
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
                'Datos inválidos.',
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
