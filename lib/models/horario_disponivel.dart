/// Espelha cada item de "horarios" em POST /api/agendamento/disponibilidade.
///
/// Um horário agrupa um ou mais slot_ids equivalentes (mesmo horário e
/// mesmo serviço) — o backend escolhe automaticamente um deles ao
/// confirmar, e tenta os demais em caso de conflito de concorrência.
class HorarioDisponivel {
  final String hora; // "14:30"
  final int? servicoId;
  final String servicoNome;
  final String? departamentoNome;
  final List<int> slotIds;

  const HorarioDisponivel({
    required this.hora,
    required this.servicoId,
    required this.servicoNome,
    required this.departamentoNome,
    required this.slotIds,
  });

  int get slotIdPrincipal => slotIds.first;

  factory HorarioDisponivel.fromJson(Map<String, dynamic> json) {
    return HorarioDisponivel(
      hora: json['hora'] as String,
      servicoId: json['servico_id'] as int?,
      servicoNome: json['servico_nome'] as String? ?? 'Atendimento geral',
      departamentoNome: json['departamento_nome'] as String?,
      slotIds: (json['slot_ids'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
    );
  }
}
