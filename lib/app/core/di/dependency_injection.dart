import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/dio_client.dart';
import '../services/database_helper.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/auth/controllers/login_controller.dart';
import '../../modules/service_order/repositories/service_order_repository.dart';
import '../../modules/service_order/controllers/service_order_controller.dart';

import '../services/in_memory_store.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  // External
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Services
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<InMemoryStore>(() => InMemoryStore());
  getIt.registerLazySingleton<DioClient>(() => DioClient(
    'https://api.serviceflow.com',
    getIt<FlutterSecureStorage>(),
  ));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
    getIt<DioClient>(),
    getIt<FlutterSecureStorage>(),
  ));
  getIt.registerLazySingleton<ServiceOrderRepository>(() => ServiceOrderRepository(
    getIt<DatabaseHelper>(),
    getIt<DioClient>(),
  ));

  // Controllers (ViewModels)
  getIt.registerFactory<LoginController>(() => LoginController());
  getIt.registerFactory<DashboardController>(() => DashboardController(getIt<InMemoryStore>()));
  getIt.registerFactory<ServiceOrderController>(() => ServiceOrderController(
    getIt<ServiceOrderRepository>(),
    getIt<InMemoryStore>(),
  ));
}
