import '../../modules/clientes/cliente.model.dart';
import '../../modules/service_order/models/service_order.model.dart';

class InMemoryStore {
  static final InMemoryStore _instance = InMemoryStore._internal();
  factory InMemoryStore() => _instance;
  InMemoryStore._internal();

  final List<Cliente> _clientes = [
    Cliente(
      id: '1',
      nome: 'Empresa Alpha',
      email: 'contato@alpha.com',
      telefone: '(11) 98888-7777',
      cpfCnpj: '12.345.678/0001-90',
    ),
    Cliente(
      id: '2',
      nome: 'João de Oliveira',
      email: 'joao@email.com',
      telefone: '(21) 97777-6666',
      cpfCnpj: '123.456.789-00',
    ),
  ];

  final List<ServiceOrder> _orders = [
    ServiceOrder(
      id: '101',
      cliente: 'Empresa Alpha',
      descricao: 'Manutenção de ar-condicionado',
      valor: 250.00,
      status: 'Executada',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ServiceOrder(
      id: '102',
      cliente: 'João de Oliveira',
      descricao: 'Reparo elétrico residencial',
      valor: 180.00,
      status: 'Em execução',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ServiceOrder(
      id: '103',
      cliente: 'Empresa Alpha',
      descricao: 'Troca de lâmpadas LED',
      valor: 120.00,
      status: 'Em aberto',
      createdAt: DateTime.now(),
    ),
  ];

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
}
