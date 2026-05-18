import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/core/services/in_memory_store.dart';
import 'package:nexusflow/app/modules/service_order/controllers/service_order_controller.dart';
import 'package:nexusflow/app/modules/service_order/repositories/service_order_repository.dart';
import 'package:nexusflow/app/modules/service_order/models/service_order.model.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late InMemoryStore store;
  late ServiceOrderRepository repository;
  late ServiceOrderController controller;

  setUpAll(() async {
    await getIt.reset();
    await initDependencyInjection();
    store = getIt<InMemoryStore>();
    repository = getIt<ServiceOrderRepository>();
    controller = getIt<ServiceOrderController>();
  });

  setUp(() async {
    store.clear();
    // Clear local SQLite in-memory database table before each test
    final db = await repository.dbHelper.database;
    await db.delete(repository.tableName);
  });

  group('ServiceOrderController Unit Tests', () {
    test('deve inicializar com lista de ordens vazia', () async {
      await controller.fetchOrders();
      expect(controller.orders.length, equals(0));
    });

    test('deve salvar uma nova ordem de serviço localmente e no store in-memory', () async {
      final order = ServiceOrder(
        cliente: 'Cliente Teste E2E',
        status: 'Em aberto',
        descricao: 'Substituição de capacitor',
        valor: 180.0,
      );

      final success = await controller.saveOrder(order);

      // Verificações
      expect(success, isTrue);
      expect(controller.orders.length, equals(1));
      expect(controller.orders.first.cliente, equals('Cliente Teste E2E'));
      expect(controller.orders.first.valor, equals(180.0));

      // Verifica se salvou persistente no DB de testes em memória
      final localOrders = await repository.getAllLocal();
      expect(localOrders.length, equals(1));
      expect(localOrders.first.descricao, equals('Substituição de capacitor'));
    });

    test('deve gerenciar isLoading corretamente durante as operações', () async {
      final order = ServiceOrder(
        cliente: 'Maria Auxiliadora',
        status: 'Em execução',
        descricao: 'Instalação de cooler extra',
        valor: 90.0,
      );

      // Inicia salvamento
      final future = controller.saveOrder(order);

      // Como o controller é assíncrono com runWithLoading, isLoading deve estar ativo
      expect(controller.isLoading, isTrue);

      await future;

      // Finalizado o salvamento, isLoading volta a ser falso
      expect(controller.isLoading, isFalse);
    });
  });
}
