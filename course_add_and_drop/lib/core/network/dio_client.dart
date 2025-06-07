import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static Dio get instance {
    final dio = Dio()
      ..options.baseUrl = _getBaseUrl()
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    // Add logging interceptor for debugging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  }

  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    
    // For mobile platforms, use the Android emulator address
    // You can change this to your actual API endpoint
    return 'http://10.0.2.2:5000/api';
  }
}