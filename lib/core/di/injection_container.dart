import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../api/api_client.dart';
import '../api/local_storage_service.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/rates/data/datasources/rates_local_data_source.dart';
import '../../features/rates/data/repositories/rates_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<Dio>(
    () => createApiClient(getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthDataSource>(), getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<RatesLocalDataSource>(() => RatesLocalDataSource());
  getIt.registerLazySingleton<RatesRepository>(
    () => RatesRepository(getIt<RatesLocalDataSource>()),
  );

  // Register new repositories/services/BLoCs here as features are added.
}
