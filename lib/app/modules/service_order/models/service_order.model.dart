import '../../../core/models/base.model.dart';

class ServiceOrder extends BaseModel {
  final String cliente;
  final String status; // "Em aberto", "Em execução", "Executada"
  final String descricao;
  final double valor;
  final String? fotoPath; // Foto Depois
  final String? fotoAntesPath;
  final String? assinatura; // Base64 signature

  ServiceOrder({
    String? id,
    DateTime? createdAt,
    required this.cliente,
    this.status = 'Em aberto',
    required this.descricao,
    required this.valor,
    this.fotoPath,
    this.fotoAntesPath,
    this.assinatura,
  }) : super(id: id, createdAt: createdAt ?? DateTime.now());

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'cliente': cliente,
      'status': status,
      'descricao': descricao,
      'valor': valor,
      'foto_path': fotoPath,
      'foto_antes_path': fotoAntesPath,
      'assinatura': assinatura,
      'created_at': createdAt?.toIso8601String(),
    });
    return map;
  }

  factory ServiceOrder.fromMap(Map<String, dynamic> map) {
    return ServiceOrder(
      id: map['id']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      cliente: map['cliente'] ?? '',
      status: map['status'] ?? 'Em aberto',
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      fotoPath: map['foto_path'],
      fotoAntesPath: map['foto_antes_path'],
      assinatura: map['assinatura'],
    );
  }
}
