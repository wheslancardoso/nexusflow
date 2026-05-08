import '../../../core/view_models/base.view_model.dart';
import '../../../core/services/in_memory_store.dart';
import '../../service_order/models/service_order.model.dart';

class DashboardController extends BaseViewModel {
  final InMemoryStore _store;

  DashboardController(this._store);

  List<ServiceOrder> get orders => _store.orders;

  int get totalCount => orders.length;
  double get totalValue => orders.fold(0, (sum, item) => sum + item.valor);

  int get abertoCount => orders.where((o) => o.status == 'Em aberto').length;
  double get abertoValue => orders
      .where((o) => o.status == 'Em aberto')
      .fold(0, (sum, item) => sum + item.valor);

  int get execucaoCount => orders.where((o) => o.status == 'Em execução').length;
  double get execucaoValue => orders
      .where((o) => o.status == 'Em execução')
      .fold(0, (sum, item) => sum + item.valor);

  int get executadaCount => orders.where((o) => o.status == 'Executada').length;
  double get executadaValue => orders
      .where((o) => o.status == 'Executada')
      .fold(0, (sum, item) => sum + item.valor);

  List<ServiceOrder> getOrdersByStatus(String status) {
    if (status == 'Total') return orders;
    return orders.where((o) => o.status == status).toList();
  }

  void refresh() {
    notifyListeners();
  }
}
