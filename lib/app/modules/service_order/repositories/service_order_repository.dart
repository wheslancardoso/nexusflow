import '../../../core/base/base.repository.dart';
import '../../../core/services/dio_client.dart';
import '../models/service_order.model.dart';

class ServiceOrderRepository extends BaseRepository<ServiceOrder> {
  final DioClient _dioClient;

  ServiceOrderRepository(dynamic _, this._dioClient); // Maintain dynamic parameter for DI compatibility

  @override
  String get tableName => 'ordens_servico';

  @override
  ServiceOrder fromMap(Map<String, dynamic> map) {
    // Map database fields to model fields if different
    return ServiceOrder(
      id: map['id'] as int?,
      cliente: map['cliente_id']?.toString() ?? map['cliente'] ?? '',
      descricao: map['observacao'] ?? map['descricao'] ?? '',
      valor: (map['valor_pecas'] as num?)?.toDouble() ?? (map['valor'] as num?)?.toDouble() ?? 0.0,
      fotoPath: map['foto_depois'] ?? map['foto_path'],
      fotoAntesPath: map['foto_antes'] ?? map['foto_antes_path'],
      assinatura: map['assinatura'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  // Compatibility methods mapping legacy calls to new BaseRepository calls
  Future<int> saveLocal(ServiceOrder model) async {
    return await insert(model);
  }

  Future<List<ServiceOrder>> getAllLocal() async {
    return await findAll();
  }

  Future<ServiceOrder?> getByIdLocal(int id) async {
    return await findById(id);
  }

  Future<int> deleteLocal(int id) async {
    return await delete(id);
  }

  Future<int> updateLocal(ServiceOrder model) async {
    return await update(model);
  }

  // Remote synchronization methods
  Future<ServiceOrder> saveRemote(ServiceOrder model) async {
    final response = await _dioClient.post('/service-orders', data: model.toMap());
    return ServiceOrder.fromMap(response.data);
  }

  Future<List<ServiceOrder>> getAllRemote() async {
    final response = await _dioClient.get('/service-orders');
    final List data = response.data;
    return data.map((e) => ServiceOrder.fromMap(e)).toList();
  }

  Future<ServiceOrder?> getByIdRemote(String id) async {
    final response = await _dioClient.get('/service-orders/$id');
    return ServiceOrder.fromMap(response.data);
  }

  Future<void> deleteRemote(String id) async {
    await _dioClient.delete('/service-orders/$id');
  }

  Future<void> sync() async {
    final pendingOrders = await findAllPendingSync();

    for (var order in pendingOrders) {
      try {
        await saveRemote(order);
        order.markAsSynced();
        await update(order);
      } catch (e) {
        print('Failed to sync order ${order.id}: $e');
      }
    }
  }
}

