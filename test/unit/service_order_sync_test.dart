import 'package:flutter_test/flutter_test.dart';
import 'package:nexusflow/app/modules/service_order/models/service_order.model.dart';
import 'package:nexusflow/app/modules/service_order/data/service_order_provider.dart';
import 'package:nexusflow/app/modules/service_order/data/service_order_schedule.dart';
import 'package:nexusflow/app/core/di/dependency_injection.dart';

void main() {
  late ServiceOrderProvider provider;

  setUpAll(() async {
    await getIt.reset();
    await initDependencyInjection();
    provider = ServiceOrderProvider();
  });

  group('ServiceOrder Sincronização & Provider Unit Tests', () {
    test('deve converter ServiceOrder para o formato de API externa com as chaves corretas', () {
      final order = ServiceOrder(
        id: 10,
        cliente: '1',
        descricao: 'Limpeza de placa-mãe',
        valor: 150.0,
        fotoPath: '/images/photo.png',
        assinatura: 'base64sig',
      );

      final externalMap = provider.toExternalFormat(order);

      expect(externalMap['id'], equals(10));
      expect(externalMap['cliente'], equals('1'));
      expect(externalMap['descricao'], equals('Limpeza de placa-mãe'));
      expect(externalMap['valor'], equals(150.0));
      expect(externalMap['foto_path'], equals('/images/photo.png'));
      expect(externalMap['assinatura'], equals('base64sig'));
    });

    test('deve construir ServiceOrder corretamente a partir do formato de API externa e marcar como sincronizada', () {
      final externalMap = {
        'id': 25,
        'cliente': '2',
        'status': 'Em execução',
        'descricao': 'Reparo de tela notebook',
        'valor': 350.0,
        'foto_path': '/images/after.png',
        'assinatura': 'remoteSig',
        'created_at': '2026-05-18T10:00:00.000Z',
      };

      final order = provider.fromExternalFormat(externalMap);

      expect(order.id, equals(25));
      expect(order.cliente, equals('2'));
      expect(order.status, equals('Em execução'));
      expect(order.descricao, equals('Reparo de tela notebook'));
      expect(order.valor, equals(350.0));
      expect(order.fotoPath, equals('/images/after.png'));
      expect(order.assinatura, equals('remoteSig'));
      expect(order.isSynchronized, isTrue);
      expect(order.createdAt, isNotNull);
    });

    test('deve validar se a O.S. está apta para sincronizar', () async {
      final valid = ServiceOrder(
        cliente: '1',
        descricao: 'Troca de pasta térmica',
        valor: 80.0,
      );

      final invalidCliente = ServiceOrder(
        cliente: '',
        descricao: 'Troca de pasta térmica',
        valor: 80.0,
      );

      final invalidDesc = ServiceOrder(
        cliente: '1',
        descricao: '',
        valor: 80.0,
      );

      expect(await provider.validateBeforeSync(valid), isTrue);
      expect(await provider.validateBeforeSync(invalidCliente), isFalse);
      expect(await provider.validateBeforeSync(invalidDesc), isFalse);
    });

    test('deve instanciar ServiceOrderSchedule com sucesso recuperando dependências via GetIt', () {
      final schedule = ServiceOrderSchedule();
      
      expect(schedule.featureName, equals('ordens_servico'));
      expect(schedule.syncInterval.inMinutes, equals(5));
      expect(schedule.repository, isNotNull);
      expect(schedule.provider, isNotNull);
    });
  });
}
