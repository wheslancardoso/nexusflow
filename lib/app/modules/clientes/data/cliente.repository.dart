import '../../../core/base/base.repository.dart';
import '../cliente.model.dart';

class ClienteRepository extends BaseRepository<Cliente> {
  @override
  String get tableName => 'clientes';

  @override
  Cliente fromMap(Map<String, dynamic> map) {
    return Cliente.fromMap(map);
  }

  Future<Cliente?> findByDocumento(String documento) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'documento = ? AND ativo = ?',
      whereArgs: [documento, 1],
    );
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }
}
