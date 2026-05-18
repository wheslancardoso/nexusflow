import '../../../core/base/base.schedule.dart';
import 'usuario.model.dart';
import 'usuario.provider.dart';
import 'usuario.repository.dart';

class UsuarioSchedule extends BaseSchedule<Usuario, UsuarioRepository, UsuarioProvider> {
  static final UsuarioSchedule _instance = UsuarioSchedule._init();
  factory UsuarioSchedule() => _instance;

  UsuarioSchedule._init() : super(
    repository: UsuarioRepository(),
    provider: UsuarioProvider(),
    featureName: 'usuarios',
    syncInterval: const Duration(minutes: 5),
  );

  @override
  Future<Usuario> resolveConflict(Usuario local, Usuario remote) async {
    return remote.copyWith(
      id: local.id,
      isSync: 1,
    );
  }
}
