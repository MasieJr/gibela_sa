import 'package:dio/dio.dart';

import '../models/taxi_route.dart';

class RoutesApi {
  final Dio dio;

  RoutesApi(this.dio);

  Future<List<TaxiRoute>> getRoutes() async {
    final response = await dio.get('/routes');

    final data = response.data as List;

    return data
        .map((route) => TaxiRoute.fromJson(route as Map<String, dynamic>))
        .toList();
  }
}
