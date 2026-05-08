import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../service_order/models/service_order.model.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorTotal = theme.primaryColor;
    final colorAberto = Colors.orange;
    final colorExecucao = Colors.blue;
    final colorExecutado = Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/clientes/form'),
            tooltip: 'Novo Cliente',
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () async {
              await Navigator.pushNamed(context, '/service_order/form');
              if (mounted) context.read<DashboardController>().refresh();
            },
            tooltip: 'Nova O.S.',
          ),
        ],
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Visão Geral das OS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _KpiCard(
                        title: 'Total',
                        quantidade: controller.totalCount,
                        valorTotal: controller.totalValue,
                        color: colorTotal,
                        onTap: () => _showOsList(context, 'Total', controller.orders, colorTotal),
                      ),
                      _KpiCard(
                        title: 'Em Aberto',
                        quantidade: controller.abertoCount,
                        valorTotal: controller.abertoValue,
                        color: colorAberto,
                        onTap: () => _showOsList(context, 'Em aberto', controller.getOrdersByStatus('Em aberto'), colorAberto),
                      ),
                      _KpiCard(
                        title: 'Em Execução',
                        quantidade: controller.execucaoCount,
                        valorTotal: controller.execucaoValue,
                        color: colorExecucao,
                        onTap: () => _showOsList(context, 'Em execução', controller.getOrdersByStatus('Em execução'), colorExecucao),
                      ),
                      _KpiCard(
                        title: 'Executadas',
                        quantidade: controller.executadaCount,
                        valorTotal: controller.executadaValue,
                        color: colorExecutado,
                        onTap: () => _showOsList(context, 'Executada', controller.getOrdersByStatus('Executada'), colorExecutado),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOsList(BuildContext context, String title, List<ServiceOrder> orders, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OS: $title',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${orders.length} itens',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: orders.isEmpty
                      ? const Center(child: Text('Nenhuma ordem de serviço encontrada.'))
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(Icons.assignment, color: color, size: 20),
                              ),
                              title: Text(
                                order.cliente,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                order.descricao,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                currencyFormat.format(order.valor),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                // Here we could navigate to OS Detail
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final int quantidade;
  final double valorTotal;
  final Color color;
  final VoidCallback onTap;

  const _KpiCard({
    required this.title,
    required this.quantidade,
    required this.valorTotal,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                quantidade.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Text(
                'Ordens',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(valorTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
