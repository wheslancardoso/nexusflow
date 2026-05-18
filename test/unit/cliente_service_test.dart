import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/modules/clientes/cliente.model.dart';
import 'package:nexusflow/app/modules/clientes/domain/cliente.service.dart';
import 'package:nexusflow/app/modules/clientes/data/cliente.repository.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late ClienteRepository repository;
  late ClienteService service;

  setUpAll(() async {
    await getIt.reset();
    await initDependencyInjection();
    repository = getIt<ClienteRepository>();
    service = getIt<ClienteService>();
  });

  setUp(() async {
    // Clean database before each test
    final db = await repository.dbHelper.database;
    await db.delete(repository.tableName);
  });

  group('ClienteService Unit Tests', () {
    test('deve criar um cliente com sucesso se passar nas validações e atribuir um ID auto-incrementado', () async {
      final client = Cliente(
        nome: 'Lucas Silva',
        email: 'lucas@email.com',
        telefone: '11988887777',
        documento: '44455566677',
      );

      final created = await service.create(client);

      // Verificações
      expect(created.id, isNotNull);
      expect(created.nome, equals('Lucas Silva'));
      expect(created.email, equals('lucas@email.com'));

      // Verifica se realmente salvou na tabela do banco
      final found = await service.listar();
      expect(found.length, equals(1));
      expect(found.first.nome, equals('Lucas Silva'));
    });

    test('deve falhar e não salvar no banco se a entidade possuir campos vazios', () async {
      final invalid = Cliente(
        nome: '',
        email: 'invalido@email.com',
        telefone: '',
      );

      expect(() => service.create(invalid), throwsA(isA<Exception>()));

      // Verifica que o banco continua vazio
      final list = await service.listar();
      expect(list.isEmpty, isTrue);
    });

    test('deve buscar um cliente com sucesso a partir de seu CPF/CNPJ', () async {
      final client = Cliente(
        nome: 'Renata Dias',
        email: 'renata@email.com',
        telefone: '11977776666',
        documento: '12345678909',
      );

      await service.create(client);

      // Busca por documento exato
      final found = await service.findByDocumento('12345678909');
      expect(found, isNotNull);
      expect(found!.nome, equals('Renata Dias'));

      // Busca por documento inexistente
      final notFound = await service.findByDocumento('00000000000');
      expect(notFound, isNull);
    });

    test('deve desativar (soft delete) um cliente ao deletá-lo', () async {
      final client = Cliente(
        nome: 'Roberta Martins',
        email: 'roberta@email.com',
        telefone: '11966665555',
      );

      final created = await service.create(client);
      expect(created.id, isNotNull);

      // Executa exclusão lógica
      await service.delete(created.id!);

      // Listar não deve mais retornar o cliente desativado (ativo = 0)
      final list = await service.listar();
      expect(list.isEmpty, isTrue);

      // No entanto, o registro ainda existe no banco para histórico (soft delete offline-first!)
      final db = await repository.dbHelper.database;
      final maps = await db.query(repository.tableName);
      expect(maps.length, equals(1));
      expect(maps.first['ativo'], equals(0));
    });
  });
}
