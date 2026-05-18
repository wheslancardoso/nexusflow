import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/modules/clientes/cliente.model.dart';
import 'package:nexusflow/app/modules/clientes/domain/cliente.validation.dart';
import 'package:nexusflow/app/modules/clientes/data/cliente.repository.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late ClienteRepository repository;
  late ClienteValidation validation;

  setUpAll(() async {
    await getIt.reset();
    await initDependencyInjection();
    repository = getIt<ClienteRepository>();
    validation = getIt<ClienteValidation>();
  });

  setUp(() async {
    // Clear in-memory client table before each test
    final db = await repository.dbHelper.database;
    await db.delete(repository.tableName);
  });

  group('ClienteValidation Unit Tests', () {
    test('deve lançar exceção se campos obrigatórios estiverem vazios na criação', () async {
      final invalidClient = Cliente(
        nome: '',
        email: '',
        telefone: '',
      );

      expect(
        () => validation.validateFieldCreate(invalidClient),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('O nome é obrigatório'))),
      );
    });

    test('deve lançar exceção se o e-mail já estiver cadastrado para outro cliente ativo', () async {
      final existingClient = Cliente(
        nome: 'João Silva',
        email: 'joao@email.com',
        telefone: '11999999999',
      );

      // Insere no banco in-memory
      await repository.insert(existingClient);

      final duplicatedClient = Cliente(
        nome: 'João Duplicado',
        email: 'joao@email.com',
        telefone: '11888888888',
      );

      expect(
        () => validation.validateRulesCreate(duplicatedClient),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Este e-mail já está cadastrado'))),
      );
    });

    test('deve passar com sucesso se o cliente for válido e único', () async {
      final validClient = Cliente(
        nome: 'Maria Souza',
        email: 'maria@email.com',
        telefone: '11777777777',
      );

      await expectLater(validation.validateFieldCreate(validClient), completes);
      await expectLater(validation.validateRulesCreate(validClient), completes);
    });
  });
}
