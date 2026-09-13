import 'package:dio/dio.dart';
import 'package:gibela_sa/core/config/api_config.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:gibela_sa/core/models/place.dart';
import 'package:gibela_sa/core/models/taxi_route.dart';
import 'package:maplibre/maplibre.dart';

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

  Future<List<Place>> searchPlace(String name) async {
    try {
      final response = await dio.get(
        '/places/search',
        queryParameters: {'q': name},
      );

      return (response.data as List)
          .map((json) => Place.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('Search error: ${e.message}');
      rethrow;
    }
  }

  Future<Journey> planTrip(Geographic origin, Geographic destination) async {
    try {
      final response = await dio.get(
        '/journeys/plan',
        queryParameters: {
          'fromLat': origin.lat,
          'fromLng': origin.lon,
          'toLat': destination.lat,
          'toLng': destination.lon,
        },
      );

      return Journey.fromJson(response.data);
    } on DioException catch (e) {
      print('Search error: ${e.message}');
      rethrow;
    }
  }
}
