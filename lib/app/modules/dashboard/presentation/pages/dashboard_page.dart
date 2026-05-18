import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../service_order/models/service_order.model.dart';
import '../../../service_order/controllers/service_order_controller.dart';
import '../../../clientes/cliente.model.dart';
import '../../../clientes/domain/cliente.service.dart';
import '../../../usuarios/data/usuario.model.dart';
import '../../../usuarios/domain/usuario.service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/liquid_background.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  int _activeTab = 0; // 0: Painel, 1: Clientes, 2: Nova OS, 3: Equipe
  String _osFilter = 'Total'; // Filter for recent OS list

  // SQLite loaded lists
  List<Cliente> _clientes = [];
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  // Clientes Tab controller & search query
  final _searchClientController = TextEditingController();
  String _clientSearchQuery = '';

  // New OS Tab form variables (Frictionless Unified Flow)
  final _osClientCpfController = TextEditingController();
  final _osClientNomeController = TextEditingController();
  final _osClientEmailController = TextEditingController();
  final _osClientFoneController = TextEditingController();
  final _osClientEnderecoController = TextEditingController();
  bool _isExistingClient = false;
  bool _isSearchingCpf = false;

  final _osDescriptionController = TextEditingController();
  final _osValueController = TextEditingController();
  List<Offset?> _signaturePoints = [];
  bool _hasFotoAntes = false;
  bool _hasFotoDepois = false;
  bool _isSavingOS = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Fetch orders via ServiceOrderController on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceOrderController>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchClientController.dispose();
    _osClientCpfController.dispose();
    _osClientNomeController.dispose();
    _osClientEmailController.dispose();
    _osClientFoneController.dispose();
    _osClientEnderecoController.dispose();
    _osDescriptionController.dispose();
    _osValueController.dispose();
    super.dispose();
  }

  String _formatCpf(String text) {
    final clean = text.replaceAll(RegExp(r'\D'), '');
    if (clean.length <= 3) return clean;
    if (clean.length <= 6) return '${clean.substring(0, 3)}.${clean.substring(3)}';
    if (clean.length <= 9) return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6)}';
    final capped = clean.substring(0, 11);
    return '${capped.substring(0, 3)}.${capped.substring(3, 6)}.${capped.substring(6, 9)}-${capped.substring(9)}';
  }

  Future<void> _onCpfChanged(String value) async {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 11) {
      setState(() => _isSearchingCpf = true);
      try {
        final client = await getIt<ClienteService>().findByDocumento(clean);
        if (client != null) {
          setState(() {
            _osClientNomeController.text = client.nome;
            _osClientEmailController.text = client.email;
            _osClientFoneController.text = client.telefone;
            _osClientEnderecoController.text = client.endereco ?? '';
            _isExistingClient = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ Cliente ${client.nome} identificado no SQLite!'),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          setState(() {
            _isExistingClient = false;
          });
        }
      } catch (e) {
        // Safe fallback
      } finally {
        setState(() => _isSearchingCpf = false);
      }
    } else {
      if (_isExistingClient) {
        setState(() {
          _isExistingClient = false;
          _osClientNomeController.clear();
          _osClientEmailController.clear();
          _osClientFoneController.clear();
          _osClientEnderecoController.clear();
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await getIt<ClienteService>().listar();
      final users = await getIt<UsuarioService>().listar();
      setState(() {
        _clientes = clients;
        _usuarios = users;
      });
    } catch (e) {
      // Fallback grace
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 🌐 PREMIUM CYBER GLASS HEADER
              _buildHeader(),
              
              // 📑 INTERACTIVE UNIFIED TAB FEED
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        physics: const BouncingScrollPhysics(),
                        child: _buildActiveTabContent(),
                      ),
              ),
            ],
          ),
        ),
      ),
      
      // 🔮 FLOATING LIQUID GLASS BAR (Frictionless navigation hub)
      extendBody: true,
      bottomNavigationBar: _buildFloatingGlassTabBar(),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXUSFLOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'ServiceFlow OS Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Sync Pulse Badge
          GestureDetector(
            onTap: () {
              _loadData();
              context.read<ServiceOrderController>().syncOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronização forçada com o SQLite executada!'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF00E5FF), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ONLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- FLOATING TABS BAR ---
  Widget _buildFloatingGlassTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 72,
      child: GlassContainer(
        borderRadius: 24,
        borderColor: Colors.white.withOpacity(0.12),
        gradientColors: [
          Colors.black.withOpacity(0.6),
          Colors.black.withOpacity(0.4),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Painel', const Key('tab-painel')),
            _buildTabItem(1, Icons.people_outline, Icons.people, 'Clientes', const Key('tab-clientes')),
            _buildTabItem(2, Icons.add_task_outlined, Icons.add_task, 'Nova OS', const Key('tab-nova-os')),
            _buildTabItem(3, Icons.shield_outlined, Icons.shield, 'Equipe', const Key('tab-equipe')),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData outlineIcon, IconData solidIcon, String label, Key key) {
    final isActive = _activeTab == index;
    final activeColor = index == 0
        ? const Color(0xFF818CF8) // Indigo
        : index == 1
            ? const Color(0xFFFBBF24) // Orange
            : index == 2
                ? const Color(0xFF22D3EE) // Cyan
                : const Color(0xFF34D399); // Green

    return Expanded(
      child: InkWell(
        key: key,
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? activeColor.withOpacity(0.3) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Icon(
                isActive ? solidIcon : outlineIcon,
                color: isActive ? activeColor : Colors.white.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white.withOpacity(0.4),
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MAIN ROUTE CONTENT SWITCHER ---
  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildClientesTab();
      case 2:
        return _buildNewOsTab();
      case 3:
        return _buildUsuariosTab();
      default:
        return _buildDashboardTab();
    }
  }

  // ==========================================
  // TAB 1: PAINEL (DASHBOARD & KPI)
  // ==========================================
  Widget _buildDashboardTab() {
    final dashboardController = context.watch<DashboardController>();

    final colorTotal = const Color(0xFF6366F1);
    final colorAberto = Colors.orangeAccent;
    final colorExecucao = const Color(0xFF00E5FF);
    final colorExecutado = Colors.greenAccent;

    // Filter local orders
    final activeOrders = dashboardController.getOrdersByStatus(_osFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Greeting Glass Card
        _buildGreetingCard(),
        const SizedBox(height: 24),

        // Title
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Desempenho e Indicadores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // KPI GRIDS
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            _buildKpiCard(
              title: 'Total Geral',
              count: dashboardController.totalCount,
              value: dashboardController.totalValue,
              color: colorTotal,
              filterTag: 'Total',
            ),
            _buildKpiCard(
              title: 'Em Aberto',
              count: dashboardController.abertoCount,
              value: dashboardController.abertoValue,
              color: colorAberto,
              filterTag: 'Em aberto',
            ),
            _buildKpiCard(
              title: 'Em Execução',
              count: dashboardController.execucaoCount,
              value: dashboardController.execucaoValue,
              color: colorExecucao,
              filterTag: 'Em execução',
            ),
            _buildKpiCard(
              title: 'Executadas',
              count: dashboardController.executadaCount,
              value: dashboardController.executadaValue,
              color: colorExecutado,
              filterTag: 'Executada',
            ),
          ],
        ),

        const SizedBox(height: 28),

        // OS LIST CARD CONTAINER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'O.S. Recentes (${_osFilter})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (_osFilter != 'Total')
              TextButton(
                onPressed: () => setState(() => _osFilter = 'Total'),
                child: const Text('Limpar Filtro', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: activeOrders.isEmpty
              ? Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, color: Colors.white.withOpacity(0.2), size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma O.S. encontrada para o filtro $_osFilter.',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeOrders.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 24),
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];
                    Color statusColor = colorAberto;
                    if (order.status == 'Em execução') statusColor = colorExecucao;
                    if (order.status == 'Executada') statusColor = colorExecutado;

                    return InkWell(
                      onTap: () => _showOsDetailsSheet(order),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Row(
                          children: [
                            // Glass Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(color: statusColor.withOpacity(0.2)),
                              ),
                              child: Icon(Icons.build_circle_outlined, color: statusColor, size: 22),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.cliente,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.descricao,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Amount and status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(order.valor),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withOpacity(0.2), width: 0.8),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: Colors.white.withOpacity(0.12),
      gradientColors: [
        Colors.white.withOpacity(0.06),
        Colors.white.withOpacity(0.01),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Olá, Técnico ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '🛠️',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Bem-vindo ao centro de operações offline-first. Gerencie suas ordens de serviço e clientes sem atritos.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required int count,
    required double value,
    required Color color,
    required String filterTag,
  }) {
    final isSelected = _osFilter == filterTag;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: -2,
            ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 20,
        borderColor: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
        gradientColors: [
          if (isSelected) color.withOpacity(0.12) else Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.01),
        ],
        padding: const EdgeInsets.all(14),
        child: InkWell(
          onTap: () {
            setState(() {
              _osFilter = filterTag;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment, color: color, size: 12),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    currencyFormat.format(value),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: CLIENTES (LIST & INSTANT FORM MODAL)
  // ==========================================
  Widget _buildClientesTab() {
    // Filtered clients list
    final filteredClients = _clientes.where((c) {
      return c.nome.toLowerCase().contains(_clientSearchQuery.toLowerCase()) ||
          c.email.toLowerCase().contains(_clientSearchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title and ADD Client button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gerenciamento de Clientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddClientModalSheet(),
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text('Novo', style: TextStyle(color: Colors.black, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24), // Orange accented button
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // SEARCH BAR FIELD
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          borderRadius: 16,
          child: TextField(
            controller: _searchClientController,
            onChanged: (val) {
              setState(() {
                _clientSearchQuery = val;
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
              hintText: 'Filtrar por nome ou e-mail...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
              fillColor: Colors.transparent,
              filled: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // CLIENTS LISTING
        filteredClients.isEmpty
            ? GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.group_off_outlined, color: Colors.white.withOpacity(0.2), size: 44),
                    const SizedBox(height: 12),
                    Text(
                      _clientSearchQuery.isEmpty
                          ? 'Nenhum cliente cadastrado ainda. Toque em "Novo" para cadastrar.'
                          : 'Nenhum cliente encontrado para a busca "$_clientSearchQuery".',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredClients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: Colors.white.withOpacity(0.08),
                    child: Row(
                      children: [
                        // Circle Letter
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            client.nome.isNotEmpty ? client.nome[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.nome,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                client.email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                client.telefone,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Status Pill (Sync Tag)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: client.isSync == 1
                                    ? Colors.greenAccent.withOpacity(0.08)
                                    : Colors.orangeAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: client.isSync == 1
                                      ? Colors.greenAccent.withOpacity(0.2)
                                      : Colors.orangeAccent.withOpacity(0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                client.isSync == 1 ? 'Sincronizado' : 'Offline',
                                style: TextStyle(
                                  color: client.isSync == 1 ? Colors.greenAccent : Colors.orangeAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  // Dynamic Add Client Modal Form
  void _showAddClientModalSheet() {
    final formKey = GlobalKey<FormState>();
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final foneCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GlassContainer(
                borderRadius: 24,
                borderColor: Colors.white.withOpacity(0.15),
                gradientColors: [
                  const Color(0xFF0F0C1B).withOpacity(0.9),
                  const Color(0xFF07050E).withOpacity(0.95),
                ],
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cadastrar Novo Cliente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Form fields
                      _buildModalGlassTextField(nomeCtrl, 'Nome Completo', Icons.person, (val) => val == null || val.isEmpty ? 'Informe o nome' : null),
                      const SizedBox(height: 12),
                      _buildModalGlassTextField(emailCtrl, 'E-mail', Icons.email, (val) => val == null || !val.contains('@') ? 'E-mail inválido' : null, keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildModalGlassTextField(foneCtrl, 'Telefone', Icons.phone, (val) => val == null || val.isEmpty ? 'Informe o telefone' : null, keyboard: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildModalGlassTextField(docCtrl, 'CPF / CNPJ (Opcional)', Icons.badge, null),
                      const SizedBox(height: 12),
                      _buildModalGlassTextField(endCtrl, 'Endereço (Opcional)', Icons.location_on, null),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSaving = true);
                                  try {
                                    final novoCliente = Cliente(
                                      nome: nomeCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      telefone: foneCtrl.text.trim(),
                                      documento: docCtrl.text.trim().isNotEmpty ? docCtrl.text.trim() : null,
                                      endereco: endCtrl.text.trim().isNotEmpty ? endCtrl.text.trim() : null,
                                    );
                                    
                                    await getIt<ClienteService>().create(novoCliente);
                                    await _loadData(); // Refresh UI list
                                    
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cliente cadastrado com sucesso!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (err) {
                                    setModalState(() => isSaving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro ao salvar cliente: $err'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text('Salvar Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalGlassTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType keyboard = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    Key? key,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextFormField(
        key: key,
        controller: ctrl,
        validator: validator,
        keyboardType: keyboard,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white38, size: 18),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: suffixIcon,
                )
              : null,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          filled: true,
          fillColor: Colors.transparent,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: NOVA OS WIZARD (NO NAVIGATION FRICTION)
  // ==========================================
  Widget _buildNewOsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Faturar Nova O.S.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Crie uma Ordem de Serviço em 1 passo, com assinatura e cadastro em tempo real.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),

        // SEÇÃO 1: DADOS DO CLIENTE (Auto-Busca por CPF)
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderColor: Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        '1. Identificação do Cliente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_isExistingClient)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                          SizedBox(width: 4),
                          Text(
                            'CLIENTE IDENTIFICADO',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // CPF com máscara
              _buildModalGlassTextField(
                _osClientCpfController,
                'CPF / CNPJ do Cliente',
                Icons.badge_outlined,
                null,
                keyboard: TextInputType.number,
                onChanged: (val) {
                  final formatted = _formatCpf(val);
                  if (formatted != val) {
                    _osClientCpfController.text = formatted;
                    _osClientCpfController.selection = TextSelection.collapsed(
                      offset: formatted.length,
                    );
                  }
                  _onCpfChanged(formatted);
                },
                suffixIcon: _isSearchingCpf
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        ),
                      )
                    : null,
                key: const Key('os-cpf-field'),
              ),
              const SizedBox(height: 12),

              // Nome completo
              _buildModalGlassTextField(
                _osClientNomeController,
                'Nome Completo do Cliente',
                Icons.person_outline,
                null,
                key: const Key('os-nome-field'),
              ),
              const SizedBox(height: 12),

              // WhatsApp
              _buildModalGlassTextField(
                _osClientFoneController,
                'Telefone / WhatsApp',
                Icons.phone_outlined,
                null,
                keyboard: TextInputType.phone,
                key: const Key('os-fone-field'),
              ),
              const SizedBox(height: 12),

              // E-mail
              _buildModalGlassTextField(
                _osClientEmailController,
                'E-mail de Contato',
                Icons.mail_outline,
                null,
                keyboard: TextInputType.emailAddress,
                key: const Key('os-email-field'),
              ),
              const SizedBox(height: 12),

              // Endereço
              _buildModalGlassTextField(
                _osClientEnderecoController,
                'Endereço Residencial (Opcional)',
                Icons.location_on_outlined,
                null,
                key: const Key('os-endereco-field'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // SEÇÃO 2: DADOS DO SERVIÇO, EVIDÊNCIAS & ASSINATURA
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderColor: Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.build_circle, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    '2. Detalhes da Ordem de Serviço',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descricao textfield
              const Text(
                'Descrição Detalhada do Serviço',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  key: const Key('os-desc-field'),
                  controller: _osDescriptionController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escreva detalhes do reparo, peças trocadas...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Valor textfield
              const Text(
                'Valor Estimado (R\$)',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  key: const Key('os-val-field'),
                  controller: _osValueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: 150.00',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // IN-PLACE DRAWING SIGNATURE PAD (PURE FLUTTER GESTURES)
              GlassSignaturePad(
                onSignatureChanged: (points) {
                  _signaturePoints = points;
                },
              ),

              const SizedBox(height: 20),

              // Rounded photo blocks (Mock Camera choice)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _hasFotoAntes = !_hasFotoAntes);
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: _hasFotoAntes ? const Color(0xFF00E5FF).withOpacity(0.05) : Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hasFotoAntes ? const Color(0xFF00E5FF).withOpacity(0.4) : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasFotoAntes ? Icons.check_circle : Icons.add_a_photo_outlined,
                              color: _hasFotoAntes ? const Color(0xFF00E5FF) : Colors.white38,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasFotoAntes ? 'Foto Antes ✓' : 'Foto Antes',
                              style: TextStyle(
                                color: _hasFotoAntes ? const Color(0xFF00E5FF) : Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _hasFotoDepois = !_hasFotoDepois);
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: _hasFotoDepois ? const Color(0xFF34D399).withOpacity(0.05) : Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hasFotoDepois ? const Color(0xFF34D399).withOpacity(0.4) : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasFotoDepois ? Icons.check_circle : Icons.add_a_photo_outlined,
                              color: _hasFotoDepois ? const Color(0xFF34D399) : Colors.white38,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasFotoDepois ? 'Foto Depois ✓' : 'Foto Depois',
                              style: TextStyle(
                                color: _hasFotoDepois ? const Color(0xFF34D399) : Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Glowing Register OS button
              ElevatedButton(
                key: const Key('os-faturar-btn'),
                onPressed: _isSavingOS ? null : () => _handleSaveOS(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF), // Cyber Cyan glowing action
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 8,
                  shadowColor: const Color(0xFF00E5FF).withOpacity(0.3),
                ),
                child: _isSavingOS
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Registrar Ordem de Serviço',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveOS() async {
    final cpf = _osClientCpfController.text.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um CPF válido (11 dígitos).'), backgroundColor: Colors.orange),
      );
      return;
    }

    final nome = _osClientNomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome completo do cliente.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final email = _osClientEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um e-mail de contato válido.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final fone = _osClientFoneController.text.trim();
    if (fone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o telefone/WhatsApp do cliente.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final desc = _osDescriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe a descrição do serviço.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final valText = _osValueController.text.trim();
    final value = double.tryParse(valText) ?? 0.0;
    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um valor estimado válido.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSavingOS = true);

    try {
      // 1. Cadastra o cliente atomicamente caso não exista previamente no SQLite
      if (!_isExistingClient) {
        final novoCliente = Cliente(
          nome: nome,
          email: email,
          telefone: fone,
          documento: cpf,
          endereco: _osClientEnderecoController.text.trim().isNotEmpty
              ? _osClientEnderecoController.text.trim()
              : null,
        );
        await getIt<ClienteService>().create(novoCliente);
        // Recarrega a lista de clientes locais
        await _loadData();
      }

      // 2. Cria e persiste a Ordem de Serviço
      final newOS = ServiceOrder(
        cliente: nome,
        descricao: desc,
        valor: value,
        status: 'Em aberto',
        fotoAntesPath: _hasFotoAntes ? '/simulated/camera/foto_antes.png' : null,
        fotoPath: _hasFotoDepois ? '/simulated/camera/foto_depois.png' : null,
        assinatura: _signaturePoints.isNotEmpty ? 'SIMULATED_BASE64_SIGNATURE_COMPLETED' : null,
      );

      final controller = context.read<ServiceOrderController>();
      final success = await controller.saveOrder(newOS);

      if (success) {
        // Limpa campos do formulário
        _osClientCpfController.clear();
        _osClientNomeController.clear();
        _osClientEmailController.clear();
        _osClientFoneController.clear();
        _osClientEnderecoController.clear();
        _osDescriptionController.clear();
        _osValueController.clear();
        _signaturePoints.clear();
        _hasFotoAntes = false;
        _hasFotoDepois = false;
        _isExistingClient = false;

        // Notifica dashboard
        context.read<DashboardController>().refresh();

        setState(() {
          _isSavingOS = false;
          _activeTab = 0; // Transiciona de volta para o Painel
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ O.S. faturada e cliente persistido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Falha ao persistir O.S. no SQLite.');
      }
    } catch (err) {
      setState(() => _isSavingOS = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar O.S. e cliente: $err'), backgroundColor: Colors.red),
      );
    }
  }

  // ==========================================
  // TAB 4: EQUIPE (USUARIOS SQLite LISTING)
  // ==========================================
  Widget _buildUsuariosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Equipe Técnica',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lista de colaboradores do SQLite sincronizados com o Supabase Auth.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),

        _usuarios.isEmpty
            ? GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.shield_moon_outlined, color: Colors.white.withOpacity(0.2), size: 44),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhum usuário técnico registrado.',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usuarios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _usuarios[index];
                  final isSync = user.isSync == 1;

                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: Colors.white.withOpacity(0.08),
                    child: Row(
                      children: [
                        // Gear Circle Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF34D399), Color(0xFF059669)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.engineering, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 14),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nomeCompleto,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Role Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Text(
                                  user.perfil.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sync Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSync ? Colors.greenAccent.withOpacity(0.08) : Colors.orangeAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSync ? Colors.greenAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isSync ? 'Sincronizado' : 'Offline',
                            style: TextStyle(
                              color: isSync ? Colors.greenAccent : Colors.orangeAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  // --- DETAIL BOTTOM SHEET FOR SERVICE ORDERS ---
  void _showOsDetailsSheet(ServiceOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return GlassContainer(
              borderRadius: 28,
              borderColor: Colors.white.withOpacity(0.15),
              gradientColors: [
                const Color(0xFF0F0C1B).withOpacity(0.9),
                const Color(0xFF07050E).withOpacity(0.95),
              ],
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Pull pill
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalhes da O.S.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Client name
                  Text(
                    order.cliente,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    currencyFormat.format(order.valor),
                    style: const TextStyle(color: Color(0xFF34D399), fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),

                  // Description card
                  const Text('Descrição do Serviço', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: Colors.white.withOpacity(0.06),
                    gradientColors: [Colors.white.withOpacity(0.02), Colors.transparent],
                    child: Text(
                      order.descricao,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Data de Criação', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      Text(
                        order.createdAt != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!)
                            : 'N/A',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Sync status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status de Sincronismo', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      Text(
                        order.isSync == 1 ? 'Sincronizado (Supabase)' : 'Local (SQLite)',
                        style: TextStyle(
                          color: order.isSync == 1 ? Colors.greenAccent : Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Evidence photos if present
                  if (order.fotoAntesPath != null || order.fotoPath != null) ...[
                    const Text('Fotos de Evidência', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (order.fotoAntesPath != null)
                          Expanded(
                            child: GlassContainer(
                              height: 100,
                              borderColor: Colors.white.withOpacity(0.08),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image, color: Color(0xFF00E5FF), size: 24),
                                  const SizedBox(height: 6),
                                  Text('Evidência Antes', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        if (order.fotoAntesPath != null && order.fotoPath != null) const SizedBox(width: 12),
                        if (order.fotoPath != null)
                          Expanded(
                            child: GlassContainer(
                              height: 100,
                              borderColor: Colors.white.withOpacity(0.08),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image, color: Color(0xFF34D399), size: 24),
                                  const SizedBox(height: 6),
                                  Text('Evidência Depois', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // Signature if present
                  if (order.assinatura != null) ...[
                    const SizedBox(height: 24),
                    const Text('Assinatura do Cliente', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GlassContainer(
                      height: 100,
                      borderColor: Colors.white.withOpacity(0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.draw, color: Color(0xFF00E5FF), size: 24),
                          const SizedBox(height: 6),
                          Text('Assinatura Registrada ✓', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Close button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Fechar Detalhes'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// CUSTOM IN-PLACE SIGNATURE WIDGET
// ==========================================
class GlassSignaturePad extends StatefulWidget {
  final Function(List<Offset?> points) onSignatureChanged;

  const GlassSignaturePad({Key? key, required this.onSignatureChanged}) : super(key: key);

  @override
  State<GlassSignaturePad> createState() => _GlassSignaturePadState();
}

class _GlassSignaturePadState extends State<GlassSignaturePad> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assinatura Autorizada (Toque e Desenhe)',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _points.clear());
                widget.onSignatureChanged(_points);
              },
              icon: const Icon(Icons.clear, size: 14, color: Colors.pinkAccent),
              label: const Text('Limpar', style: TextStyle(color: Colors.pinkAccent, fontSize: 11)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
            )
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localPos = box.globalToLocal(details.globalPosition);
                // Simple boundary clamping to keep within drawing box
                if (localPos.dy >= 0 && localPos.dy <= 120 && localPos.dx >= 0 && localPos.dx <= box.size.width) {
                  setState(() {
                    _points.add(localPos);
                  });
                  widget.onSignatureChanged(_points);
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _points.add(null);
                });
                widget.onSignatureChanged(_points);
              },
              child: CustomPaint(
                painter: SignaturePainter(_points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF) // Cyber Cyan signature line
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
