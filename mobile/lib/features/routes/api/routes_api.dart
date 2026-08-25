import 'package:dio/dio.dart';

import '../models/taxi_route.dart';

class RoutesApi {
  final Dio dio;

  RoutesApi(this.dio);

  Future<List<TaxiRoute>> getRoutes() async {
    final response = await dio.get('/routes');
    final data = response.data as List<dynamic>;
    return data
        .map(
          (route) =>
              TaxiRoute.fromJson(Map<String, dynamic>.from(route as Map)),
        )
        .toList();
  }

  Future<TaxiRoute> getRouteById(String id) async {
    final response = await dio.get('/routes/$id');
    final data = Map<String, dynamic>.from(response.data as Map);
    return TaxiRoute.fromJson(data);
  }
}
