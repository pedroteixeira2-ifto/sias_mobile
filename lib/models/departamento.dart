/// Espelha /api/departamentos (departamentos do tipo 'especialidade').
class Departamento {
  final int id;
  final String nome;
  final String? descricao;

  const Departamento({required this.id, required this.nome, this.descricao});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
    );
  }
}
