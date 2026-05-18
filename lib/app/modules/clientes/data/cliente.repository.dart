import '../../../core/base/base.repository.dart';
import '../cliente.model.dart';

class ClienteRepository extends BaseRepository<Cliente> {
  @override
  String get tableName => 'clientes';

  @override
  Cliente fromMap(Map<String, dynamic> map) {
    return Cliente.fromMap(map);
  }
}
