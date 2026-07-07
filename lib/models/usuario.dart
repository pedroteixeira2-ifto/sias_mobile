/// Espelha o JSON devolvido por /api/auth/verificar-2fa e /api/auth/me
/// (ver _usuario_json em app/routes/api.py).
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String papel;
  final int? departamentoId;
  final bool emailVerificado;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
    this.departamentoId,
    required this.emailVerificado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      papel: json['papel'] as String,
      departamentoId: json['departamento_id'] as int?,
      emailVerificado: json['email_verificado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'papel': papel,
        'departamento_id': departamentoId,
        'email_verificado': emailVerificado,
      };
}
