import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/dio_client.dart';
import '../helpers/database_helper.dart';

// Logging
import '../logging/log.service.dart';

// Auth module
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/auth/controllers/login_controller.dart';

// Dashboard module
import '../services/in_memory_store.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';

// Clientes module
import '../../modules/clientes/data/cliente.repository.dart';
import '../../modules/clientes/domain/cliente.validation.dart';
import '../../modules/clientes/domain/cliente.service.dart';

// Usuarios module
import '../../modules/usuarios/data/usuario.repository.dart';
import '../../modules/usuarios/domain/usuario.validation.dart';
import '../../modules/usuarios/domain/usuario.service.dart';

// Service Orders module (compatibility)
import '../../modules/service_order/repositories/service_order_repository.dart';
import '../../modules/service_order/controllers/service_order_controller.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  // 1. External dependencies
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // 2. Core database helper
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<InMemoryStore>(() => InMemoryStore());

  // 3. Log Service
  getIt.registerLazySingleton<LogService>(() => LogService.instance);

  // 4. HTTP client (legacy DioClient for auth module compat)
  getIt.registerLazySingleton<DioClient>(() => DioClient(
    'https://api.serviceflow.com',
    getIt<FlutterSecureStorage>(),
  ));

  // 5. Auth Module
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
    getIt<DioClient>(),
    getIt<FlutterSecureStorage>(),
  ));
  getIt.registerFactory<LoginController>(() => LoginController());

  // 6. Dashboard Module
  getIt.registerFactory<DashboardController>(() => DashboardController(getIt<InMemoryStore>()));

  // 7. Clientes Module
  getIt.registerLazySingleton<ClienteRepository>(() => ClienteRepository());
  getIt.registerLazySingleton<ClienteValidation>(() => ClienteValidation(getIt<ClienteRepository>()));
  getIt.registerLazySingleton<ClienteService>(() => ClienteService(
    repository: getIt<ClienteRepository>(),
    validation: getIt<ClienteValidation>(),
  ));

  // 8. Usuarios Module
  getIt.registerLazySingleton<UsuarioRepository>(() => UsuarioRepository());
  getIt.registerLazySingleton<UsuarioValidation>(() => UsuarioValidation(getIt<UsuarioRepository>()));
  getIt.registerLazySingleton<UsuarioService>(() => UsuarioService(
    repository: getIt<UsuarioRepository>(),
    validation: getIt<UsuarioValidation>(),
  ));

  // 9. Service Orders Module (legacy/compatibility)
  getIt.registerLazySingleton<ServiceOrderRepository>(() => ServiceOrderRepository(
    getIt<DatabaseHelper>(),
    getIt<DioClient>(),
  ));
  getIt.registerFactory<ServiceOrderController>(() => ServiceOrderController(
    getIt<ServiceOrderRepository>(),
    getIt<InMemoryStore>(),
  ));
}
