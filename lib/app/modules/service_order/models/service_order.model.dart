import '../../../core/base/base.model.dart';

class ServiceOrder extends BaseModel {
  final String cliente;
  final String status; // "Em aberto", "Em execução", "Executada"
  final String descricao;
  final double valor;
  final String? fotoPath; // Foto Depois
  final String? fotoAntesPath;
  final String? assinatura; // Base64 signature

  ServiceOrder({
    int? id,
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
    return {
      if (id != null) 'id': id,
      'cliente': cliente,
      'status': status,
      'descricao': descricao,
      'valor': valor,
      'foto_path': fotoPath,
      'foto_antes_path': fotoAntesPath,
      'assinatura': assinatura,
      'is_sync': isSync,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory ServiceOrder.fromMap(Map<String, dynamic> map) {
    return ServiceOrder(
      id: map['id'] as int?,
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

  @override
  ServiceOrder copyWith({
    int? id,
    String? cliente,
    String? status,
    String? descricao,
    double? valor,
    String? fotoPath,
    String? fotoAntesPath,
    String? assinatura,
    int? isSync,
    DateTime? createdAt,
  }) {
    final order = ServiceOrder(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      status: status ?? this.status,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      fotoPath: fotoPath ?? this.fotoPath,
      fotoAntesPath: fotoAntesPath ?? this.fotoAntesPath,
      assinatura: assinatura ?? this.assinatura,
    );
    order.isSync = isSync ?? this.isSync;
    order.createdAt = createdAt ?? this.createdAt;
    return order;
  }
}
