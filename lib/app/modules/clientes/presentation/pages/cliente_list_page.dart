import 'package:flutter/material.dart';
import '../../../../core/base/base.controller.dart';
import '../../cliente.model.dart';
import '../../data/cliente.repository.dart';
import '../../domain/cliente.validation.dart';
import '../../domain/cliente.service.dart';
import 'cliente_form_page.dart';

// ignore: must_be_immutable
class ClienteListPage extends BaseController<Cliente, ClienteRepository, ClienteValidation, ClienteService> {
  ClienteListPage({Key? key, required ClienteService service}) : super(service, key: key);

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return _ClienteListView(controller: this);
  }
}

class _ClienteListView extends StatefulWidget {
  final ClienteListPage controller;

  const _ClienteListView({required this.controller});

  @override
  State<_ClienteListView> createState() => _ClienteListViewState();
}

class _ClienteListViewState extends State<_ClienteListView> {
  List<Cliente> _clientes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    final list = await widget.controller.executeListOperation(
      context,
      widget.controller.service.listar(),
      loadingMessage: 'Carregando clientes...',
      errorMessage: 'Falha ao carregar lista de clientes.',
    );
    setState(() {
      _clientes = list;
      _isLoading = false;
    });
  }

  Future<void> _deletarCliente(Cliente cliente) async {
    final success = await widget.controller.executeCrudOperation(
      context,
      widget.controller.service.delete(cliente.id!),
      requiresConfirmation: true,
      confirmTitle: 'Excluir Cliente',
      confirmMessage: 'Tem certeza que deseja excluir ${cliente.nome}?',
      loadingMessage: 'Excluindo...',
      successMessage: 'Cliente excluído com sucesso!',
      errorMessage: 'Erro ao excluir cliente.',
    );

    if (success) {
      _loadClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum cliente cadastrado.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientes[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            cliente.nome.isNotEmpty ? cliente.nome.substring(0, 1).toUpperCase() : 'C',
                            style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cliente.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Icon(
                              cliente.isSynchronized ? Icons.cloud_done : Icons.cloud_queue,
                              color: cliente.isSynchronized ? Colors.green : Colors.orange,
                              size: 18,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(cliente.email, style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(cliente.telefone, style: TextStyle(color: Colors.grey[600])),
                            if (cliente.documento != null && cliente.documento!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Doc: ${cliente.documento}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClienteFormPage(
                                      service: widget.controller.service,
                                      model: cliente,
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  _loadClientes();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletarCliente(cliente),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClienteFormPage(
                service: widget.controller.service,
              ),
            ),
          );
          if (added == true) {
            _loadClientes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
