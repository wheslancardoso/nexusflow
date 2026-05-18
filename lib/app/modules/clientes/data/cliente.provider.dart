import '../../../core/base/base.provider.dart';
import '../cliente.model.dart';

class ClienteProvider extends BaseProvider<Cliente> {
  @override
  String get endpoint => '/rest/v1/clientes';

  @override
  Map<String, dynamic> toExternalFormat(Cliente entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      'nome': entity.nome,
      'email': entity.email,
      'telefone': entity.telefone,
      'documento': entity.documento,
      'endereco': entity.endereco,
      'cidade': entity.cidade,
      'estado': entity.estado,
      'cep': entity.cep,
      'ativo': entity.ativo,
    };
  }

  @override
  Cliente fromExternalFormat(Map<String, dynamic> data) {
    return Cliente(
      id: data['id'] as int?,
      nome: data['nome'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telefone: data['telefone'] as String? ?? '',
      documento: data['documento'] as String?,
      endereco: data['endereco'] as String?,
      cidade: data['cidade'] as String?,
      estado: data['estado'] as String?,
      cep: data['cep'] as String?,
      ativo: data['ativo'] as int? ?? 1,
      isSync: 1,
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
    );
  }

  @override
  Future<bool> validateBeforeSync(Cliente entity) async {
    return entity.nome.isNotEmpty && entity.email.isNotEmpty && entity.telefone.isNotEmpty;
  }
}
