/// Espelha /api/departamentos/<id>/servicos.
class Servico {
  final int id;
  final String nome;
  final String? descricao;

  const Servico({required this.id, required this.nome, this.descricao});

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
    );
  }
}
