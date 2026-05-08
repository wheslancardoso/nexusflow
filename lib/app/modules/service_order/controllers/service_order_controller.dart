import '../../../core/view_models/base.view_model.dart';
import '../../../core/services/in_memory_store.dart';
import '../models/service_order.model.dart';
import '../repositories/service_order_repository.dart';

class ServiceOrderController extends BaseViewModel {
  final ServiceOrderRepository _repository;
  final InMemoryStore _store;
  List<ServiceOrder> _orders = [];

  ServiceOrderController(this._repository, this._store);

  List<ServiceOrder> get orders => _orders;

  Future<void> fetchOrders() async {
    await runWithLoading(() async {
      // Prioritize in-memory store for UI consistency in this sprint
      _orders = _store.orders;
      
      // Optionally sync with local DB in background
      // final localOrders = await _repository.getAllLocal();
      // ...
    });
  }

  Future<bool> saveOrder(ServiceOrder order) async {
    bool success = false;
    await runWithLoading(() async {
      // Save to store
      _store.addOrder(order);
      
      // Also save to local DB for persistence
      await _repository.saveLocal(order);
      
      await fetchOrders();
      success = true;
    });
    return success;
  }

  Future<void> syncOrders() async {
    await runWithLoading(() async {
      await _repository.sync();
      await fetchOrders();
    });
  }
}
