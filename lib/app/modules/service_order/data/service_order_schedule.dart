import '../../../core/base/base.schedule.dart';
import '../../../core/di/dependency_injection.dart';
import '../models/service_order.model.dart';
import '../repositories/service_order_repository.dart';
import 'service_order_provider.dart';

class ServiceOrderSchedule extends BaseSchedule<ServiceOrder, ServiceOrderRepository, ServiceOrderProvider> {
  static final ServiceOrderSchedule _instance = ServiceOrderSchedule._init();
  factory ServiceOrderSchedule() => _instance;

  ServiceOrderSchedule._init() : super(
    repository: getIt<ServiceOrderRepository>(),
    provider: ServiceOrderProvider(),
    featureName: 'ordens_servico',
    syncInterval: const Duration(minutes: 5),
  );

  @override
  Future<ServiceOrder> resolveConflict(ServiceOrder local, ServiceOrder remote) async {
    // Versão remota ganha por padrão, mantendo id local
    return remote.copyWith(
      id: local.id,
      isSync: 1,
    );
  }
}
