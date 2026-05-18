import '../../../core/base/base.model.dart';

class Usuario extends BaseModel {
  final String supabaseId;
  final String email;
  final String nomeCompleto;
  final String grupoId;
  final String perfil;
  final String? ultimoLogin;
  final String? avatarLocalPath;
  final String? configuracoes;
  final int ativo;

  Usuario({
    super.id,
    required this.supabaseId,
    required this.email,
    required this.nomeCompleto,
    required this.grupoId,
    this.perfil = 'tecnico',
    this.ultimoLogin,
    this.avatarLocalPath,
    this.configuracoes,
    this.ativo = 1,
    super.isSync = 0,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'supabase_id': supabaseId,
      'email': email,
      'nome_completo': nomeCompleto,
      'grupo_id': grupoId,
      'perfil': perfil,
      'ultimo_login': ultimoLogin,
      'avatar_local_path': avatarLocalPath,
      'configuracoes': configuracoes,
      'ativo': ativo,
      'is_sync': isSync,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      supabaseId: map['supabase_id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      nomeCompleto: map['nome_completo'] as String? ?? '',
      grupoId: map['grupo_id'] as String? ?? '',
      perfil: map['perfil'] as String? ?? 'tecnico',
      ultimoLogin: map['ultimo_login'] as String?,
      avatarLocalPath: map['avatar_local_path'] as String?,
      configuracoes: map['configuracoes'] as String?,
      ativo: map['ativo'] as int? ?? 1,
      isSync: map['is_sync'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  @override
  Usuario copyWith({
    int? id,
    String? supabaseId,
    String? email,
    String? nomeCompleto,
    String? grupoId,
    String? perfil,
    String? ultimoLogin,
    String? avatarLocalPath,
    String? configuracoes,
    int? ativo,
    int? isSync,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      email: email ?? this.email,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      grupoId: grupoId ?? this.grupoId,
      perfil: perfil ?? this.perfil,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      configuracoes: configuracoes ?? this.configuracoes,
      ativo: ativo ?? this.ativo,
      isSync: isSync ?? this.isSync,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
