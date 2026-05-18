import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/core/services/in_memory_store.dart';
import 'package:nexusflow/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:nexusflow/app/modules/service_order/models/service_order.model.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late InMemoryStore store;
  late DashboardController controller;

  setUp(() async {
    await getIt.reset();
    store = InMemoryStore();
    store.clear();
    controller = DashboardController(store);
  });

  group('DashboardController Unit Tests', () {
    test('deve inicializar com totais zerados se a loja estiver vazia', () async {
      expect(controller.totalCount, equals(0));
      expect(controller.totalValue, equals(0.0));
      expect(controller.abertoCount, equals(0));
      expect(controller.execucaoCount, equals(0));
      expect(controller.executadaCount, equals(0));
    });

    test('deve calcular corretamente totais e subdivisões por status', () async {
      // Adiciona O.S. com statuses diferentes
      store.addOrder(ServiceOrder(
        cliente: 'Cliente A',
        status: 'Em aberto',
        descricao: 'Serviço A',
        valor: 150.0,
      ));
      store.addOrder(ServiceOrder(
        cliente: 'Cliente B',
        status: 'Em execução',
        descricao: 'Serviço B',
        valor: 300.0,
      ));
      store.addOrder(ServiceOrder(
        cliente: 'Cliente C',
        status: 'Executada',
        descricao: 'Serviço C',
        valor: 500.0,
      ));
      store.addOrder(ServiceOrder(
        cliente: 'Cliente D',
        status: 'Em aberto',
        descricao: 'Serviço D',
        valor: 200.0,
      ));

      // Verificações globais
      expect(controller.totalCount, equals(4));
      expect(controller.totalValue, equals(1150.0));

      // Verificações "Em aberto"
      expect(controller.abertoCount, equals(2));
      expect(controller.abertoValue, equals(350.0));

      // Verificações "Em execução"
      expect(controller.execucaoCount, equals(1));
      expect(controller.execucaoValue, equals(300.0));

      // Verificações "Executada"
      expect(controller.executadaCount, equals(1));
      expect(controller.executadaValue, equals(500.0));
    });

    test('deve filtrar ordens corretamente por status', () async {
      store.addOrder(ServiceOrder(
        cliente: 'Cliente A',
        status: 'Em aberto',
        descricao: 'Serviço A',
        valor: 100.0,
      ));
      store.addOrder(ServiceOrder(
        cliente: 'Cliente B',
        status: 'Executada',
        descricao: 'Serviço B',
        valor: 200.0,
      ));

      final allOrders = controller.getOrdersByStatus('Total');
      final abertoOrders = controller.getOrdersByStatus('Em aberto');
      final executadaOrders = controller.getOrdersByStatus('Executada');

      expect(allOrders.length, equals(2));
      expect(abertoOrders.length, equals(1));
      expect(abertoOrders.first.cliente, equals('Cliente A'));
      expect(executadaOrders.length, equals(1));
      expect(executadaOrders.first.cliente, equals('Cliente B'));
    });
  });
}
