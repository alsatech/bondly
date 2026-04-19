import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create(SecureStorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Required for ngrok free tier
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storage: storage, dio: dio),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    ]);

    return dio;
  }
}
