import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/service_order_controller.dart';
import '../../../../core/mixins/messages_mixin.dart';

class ServiceOrderListPage extends StatefulWidget {
  const ServiceOrderListPage({Key? key}) : super(key: key);

  @override
  State<ServiceOrderListPage> createState() => _ServiceOrderListPageState();
}

class _ServiceOrderListPageState extends State<ServiceOrderListPage> with MessagesMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceOrderController>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ServiceOrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => controller.syncOrders(),
          ),
        ],
      ),
      body: controller.isLoading && controller.orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controller.orders.isEmpty
              ? const Center(child: Text('Nenhuma ordem de serviço cadastrada.'))
              : ListView.builder(
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    
                    Color statusColor;
                    IconData statusIcon;
                    
                    switch (order.status) {
                      case 'Executada':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'Em execução':
                        statusColor = Colors.blue;
                        statusIcon = Icons.play_circle_filled;
                        break;
                      case 'Em aberto':
                      default:
                        statusColor = Colors.orange;
                        statusIcon = Icons.info_outline;
                        break;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(statusIcon, color: statusColor, size: 20),
                      ),
                      title: Text(order.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Criada em: ${order.createdAt?.toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${order.valor.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            order.status,
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to detail
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/service_order/form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
