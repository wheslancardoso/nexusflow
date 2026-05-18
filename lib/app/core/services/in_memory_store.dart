import '../../modules/clientes/cliente.model.dart';
import '../../modules/service_order/models/service_order.model.dart';

class InMemoryStore {
  static final InMemoryStore _instance = InMemoryStore._internal();
  factory InMemoryStore() => _instance;
  InMemoryStore._internal();

  final List<Cliente> _clientes = [];

  final List<ServiceOrder> _orders = [];

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<ServiceOrder> get orders => List.unmodifiable(_orders);

  void addCliente(Cliente cliente) {
    _clientes.add(cliente);
  }

  void addOrder(ServiceOrder order) {
    _orders.add(order);
  }

  void updateOrder(ServiceOrder updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }

  void clear() {
    _clientes.clear();
    _orders.clear();
  }
}
