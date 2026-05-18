import '../../../core/base/base.repository.dart';
import 'usuario.model.dart';

class UsuarioRepository extends BaseRepository<Usuario> {
  @override
  String get tableName => 'usuarios';

  @override
  Usuario fromMap(Map<String, dynamic> map) {
    return Usuario.fromMap(map);
  }
}
