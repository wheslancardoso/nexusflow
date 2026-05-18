import '../../core/base/base.model.dart';

class Cliente extends BaseModel {
  final String nome;
  final String email;
  final String telefone;
  final String? documento;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final int ativo;

  Cliente({
    super.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.documento,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.ativo = 1,
    super.isSync = 0,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'documento': documento,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'ativo': ativo,
      'is_sync': isSync,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      documento: map['documento'] as String?,
      endereco: map['endereco'] as String?,
      cidade: map['cidade'] as String?,
      estado: map['estado'] as String?,
      cep: map['cep'] as String?,
      ativo: map['ativo'] as int? ?? 1,
      isSync: map['is_sync'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  @override
  Cliente copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? documento,
    String? endereco,
    String? cidade,
    String? estado,
    String? cep,
    int? ativo,
    int? isSync,
    DateTime? createdAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      documento: documento ?? this.documento,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      ativo: ativo ?? this.ativo,
      isSync: isSync ?? this.isSync,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
