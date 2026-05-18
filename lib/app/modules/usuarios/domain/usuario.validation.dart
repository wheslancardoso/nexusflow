import '../../../core/base/base.validation.dart';
import '../data/usuario.model.dart';
import '../data/usuario.repository.dart';

class UsuarioValidation extends BaseValidation<Usuario, UsuarioRepository> {
  final UsuarioRepository _repository;

  UsuarioValidation(this._repository);

  @override
  Future<void> validateFieldCreate(Usuario entity) async {
    if (entity.supabaseId.trim().isEmpty) {
      throw Exception('Validation: O id do Supabase é obrigatório.');
    }
    if (entity.email.trim().isEmpty) {
      throw Exception('Validation: O e-mail é obrigatório.');
    }
    if (entity.nomeCompleto.trim().isEmpty) {
      throw Exception('Validation: O nome completo é obrigatório.');
    }
  }

  @override
  Future<void> validateRulesCreate(Usuario entity) async {
    final db = await _repository.dbHelper.database;
    final results = await db.query(
      _repository.tableName,
      where: 'email = ? AND ativo = ?',
      whereArgs: [entity.email, 1],
    );
    if (results.isNotEmpty) {
      throw Exception('Validation: Este e-mail de usuário já está cadastrado.');
    }
  }

  @override
  Future<void> validateFieldUpdate(Usuario entity) async {
    await validateFieldCreate(entity);
  }

  @override
  Future<void> validateRulesUpdate(Usuario entity) async {
    final db = await _repository.dbHelper.database;
    final results = await db.query(
      _repository.tableName,
      where: 'email = ? AND id != ? AND ativo = ?',
      whereArgs: [entity.email, entity.id, 1],
    );
    if (results.isNotEmpty) {
      throw Exception('Validation: Este e-mail de usuário já está em uso.');
    }
  }
}
