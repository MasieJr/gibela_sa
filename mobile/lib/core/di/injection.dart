import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gibela_sa/core/config/api_config.dart';
import 'package:gibela_sa/core/network/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
  );

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
}
