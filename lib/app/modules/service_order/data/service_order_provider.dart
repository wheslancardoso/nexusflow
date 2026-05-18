import '../../../core/base/base.provider.dart';
import '../models/service_order.model.dart';

class ServiceOrderProvider extends BaseProvider<ServiceOrder> {
  @override
  String get endpoint => '/rest/v1/ordens_servico';

  @override
  Map<String, dynamic> toExternalFormat(ServiceOrder entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      'cliente': entity.cliente,
      'status': entity.status,
      'descricao': entity.descricao,
      'valor': entity.valor,
      'foto_path': entity.fotoPath,
      'foto_antes_path': entity.fotoAntesPath,
      'assinatura': entity.assinatura,
    };
  }

  @override
  ServiceOrder fromExternalFormat(Map<String, dynamic> data) {
    return ServiceOrder(
      id: data['id'] as int?,
      cliente: data['cliente'] as String? ?? '',
      status: data['status'] as String? ?? 'Em aberto',
      descricao: data['descricao'] as String? ?? '',
      valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
      fotoPath: data['foto_path'] as String?,
      fotoAntesPath: data['foto_antes_path'] as String?,
      assinatura: data['assinatura'] as String?,
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
    )..markAsSynced();
  }

  @override
  Future<bool> validateBeforeSync(ServiceOrder entity) async {
    return entity.cliente.isNotEmpty && entity.descricao.isNotEmpty;
  }
}
