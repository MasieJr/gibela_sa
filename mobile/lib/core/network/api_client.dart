import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  Future<Response> getRoutes() {
    return dio.get('/routes');
  }
}
