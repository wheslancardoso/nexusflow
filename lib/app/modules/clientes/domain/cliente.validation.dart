import '../../../core/base/base.validation.dart';
import '../cliente.model.dart';
import '../data/cliente.repository.dart';

class ClienteValidation extends BaseValidation<Cliente, ClienteRepository> {
  final ClienteRepository _repository;

  ClienteValidation(this._repository);

  @override
  Future<void> validateFieldCreate(Cliente entity) async {
    if (entity.nome.trim().isEmpty) {
      throw Exception('Validation: O nome é obrigatório.');
    }
    if (entity.email.trim().isEmpty) {
      throw Exception('Validation: O e-mail é obrigatório.');
    }
    if (entity.telefone.trim().isEmpty) {
      throw Exception('Validation: O telefone é obrigatório.');
    }
  }

  @override
  Future<void> validateRulesCreate(Cliente entity) async {
    final db = await _repository.dbHelper.database;
    final results = await db.query(
      _repository.tableName,
      where: 'email = ? AND ativo = ?',
      whereArgs: [entity.email, 1],
    );
    if (results.isNotEmpty) {
      throw Exception('Validation: Este e-mail já está cadastrado para outro cliente.');
    }
  }

  @override
  Future<void> validateFieldUpdate(Cliente entity) async {
    await validateFieldCreate(entity);
  }

  @override
  Future<void> validateRulesUpdate(Cliente entity) async {
    final db = await _repository.dbHelper.database;
    final results = await db.query(
      _repository.tableName,
      where: 'email = ? AND id != ? AND ativo = ?',
      whereArgs: [entity.email, entity.id, 1],
    );
    if (results.isNotEmpty) {
      throw Exception('Validation: Este e-mail já está em uso por outro cliente.');
    }
  }
}
