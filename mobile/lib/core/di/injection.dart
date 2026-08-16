import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/config/api_config.dart';
import '../../features/routes/data/routes_api.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
  );

  getIt.registerLazySingleton<RoutesApi>(() => RoutesApi(getIt<Dio>()));
}
