import '../../../core/base/base.provider.dart';
import 'usuario.model.dart';

class UsuarioProvider extends BaseProvider<Usuario> {
  @override
  String get endpoint => '/rest/v1/usuarios';

  @override
  Map<String, dynamic> toExternalFormat(Usuario entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      'supabase_id': entity.supabaseId,
      'email': entity.email,
      'nome_completo': entity.nomeCompleto,
      'grupo_id': entity.grupoId,
      'perfil': entity.perfil,
      'ultimo_login': entity.ultimoLogin,
      'avatar_local_path': entity.avatarLocalPath,
      'configuracoes': entity.configuracoes,
      'ativo': entity.ativo,
    };
  }

  @override
  Usuario fromExternalFormat(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'] as int?,
      supabaseId: data['supabase_id'] as String? ?? '',
      email: data['email'] as String? ?? '',
      nomeCompleto: data['nome_completo'] as String? ?? '',
      grupoId: data['grupo_id'] as String? ?? '',
      perfil: data['perfil'] as String? ?? 'tecnico',
      ultimoLogin: data['ultimo_login'] as String?,
      avatarLocalPath: data['avatar_local_path'] as String?,
      configuracoes: data['configuracoes'] as String?,
      ativo: data['ativo'] as int? ?? 1,
      isSync: 1,
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
    );
  }

  @override
  Future<bool> validateBeforeSync(Usuario entity) async {
    return entity.supabaseId.isNotEmpty && entity.email.isNotEmpty && entity.nomeCompleto.isNotEmpty;
  }
}
