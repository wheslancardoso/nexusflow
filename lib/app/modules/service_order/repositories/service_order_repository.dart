import '../../../core/repositories/base_repository.dart';
import '../../../core/services/database_helper.dart';
import '../../../core/services/dio_client.dart';
import '../models/service_order.model.dart';

class ServiceOrderRepository extends BaseRepository<ServiceOrder> {
  final DatabaseHelper _dbHelper;
  final DioClient _dioClient;

  ServiceOrderRepository(this._dbHelper, this._dioClient);

  @override
  Future<int> saveLocal(ServiceOrder model) async {
    return await _dbHelper.insert('service_orders', model.toMap());
  }

  @override
  Future<List<ServiceOrder>> getAllLocal() async {
    final results = await _dbHelper.queryAll('service_orders');
    return results.map((e) => ServiceOrder.fromMap(e)).toList();
  }

  @override
  Future<ServiceOrder?> getByIdLocal(String id) async {
    final result = await _dbHelper.queryById('service_orders', id);
    return result != null ? ServiceOrder.fromMap(result) : null;
  }

  @override
  Future<int> deleteLocal(String id) async {
    return await _dbHelper.delete('service_orders', id);
  }

  @override
  Future<int> updateLocal(ServiceOrder model) async {
    return await _dbHelper.update('service_orders', model.toMap(), model.id!);
  }

  @override
  Future<ServiceOrder> saveRemote(ServiceOrder model) async {
    final response = await _dioClient.post('/service-orders', data: model.toMap());
    return ServiceOrder.fromMap(response.data);
  }

  @override
  Future<List<ServiceOrder>> getAllRemote() async {
    final response = await _dioClient.get('/service-orders');
    final List data = response.data;
    return data.map((e) => ServiceOrder.fromMap(e)).toList();
  }

  @override
  Future<ServiceOrder?> getByIdRemote(String id) async {
    final response = await _dioClient.get('/service-orders/$id');
    return ServiceOrder.fromMap(response.data);
  }

  @override
  Future<void> deleteRemote(String id) async {
    await _dioClient.delete('/service-orders/$id');
  }

  @override
  Future<void> sync() async {
    final localOrders = await getAllLocal();
    final pendingOrders = localOrders.where((o) => o.status == 'P').toList();

    for (var order in pendingOrders) {
      try {
        await saveRemote(order);
        // Update local status to 'S' (Synchronized)
        final updatedOrder = ServiceOrder(
          id: order.id,
          cliente: order.cliente,
          descricao: order.descricao,
          valor: order.valor,
          status: 'Executada', // Semantic status for faturada/synced
          fotoPath: order.fotoPath,
          fotoAntesPath: order.fotoAntesPath,
          assinatura: order.assinatura,
          createdAt: order.createdAt,
        );
        await updateLocal(updatedOrder);
      } catch (e) {
        // Log error and continue with next order
        print('Failed to sync order ${order.id}: $e');
      }
    }
  }
}
