import '../../../core/base/base.schedule.dart';
import '../cliente.model.dart';
import 'cliente.provider.dart';
import 'cliente.repository.dart';

class ClienteSchedule extends BaseSchedule<Cliente, ClienteRepository, ClienteProvider> {
  static final ClienteSchedule _instance = ClienteSchedule._init();
  factory ClienteSchedule() => _instance;

  ClienteSchedule._init() : super(
    repository: ClienteRepository(),
    provider: ClienteProvider(),
    featureName: 'clientes',
    syncInterval: const Duration(minutes: 5),
  );

  @override
  Future<Cliente> resolveConflict(Cliente local, Cliente remote) async {
    // Em caso de conflito, a versão remota ganha por padrão (ou podemos implementar lógica de mesclagem)
    return remote.copyWith(
      id: local.id,
      isSync: 1,
    );
  }
}
