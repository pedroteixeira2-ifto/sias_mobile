/// Espelha cada item de "agendamentos" em
/// GET /api/cliente/meus-agendamentos/status — consumido pelo
/// QueueProvider a cada 10s (ver §4.2 da especificação).
class AgendamentoStatus {
  final int agendamentoId;
  final String statusApp; // ver utils/constants.dart -> StatusFila
  final String inicio;
  final String? fim;
  final String? servicoNome;
  final String? departamentoNome;
  final int? posicao;
  final int? pessoasNaFrente;
  final String? terminalTipo;
  final String? terminalNumero;
  final String? atendenteNome;

  const AgendamentoStatus({
    required this.agendamentoId,
    required this.statusApp,
    required this.inicio,
    this.fim,
    this.servicoNome,
    this.departamentoNome,
    this.posicao,
    this.pessoasNaFrente,
    this.terminalTipo,
    this.terminalNumero,
    this.atendenteNome,
  });

  String? get localAtendimento {
    if (terminalTipo == null || terminalNumero == null) return null;
    return '$terminalTipo $terminalNumero';
  }

  factory AgendamentoStatus.fromJson(Map<String, dynamic> json) {
    return AgendamentoStatus(
      agendamentoId: json['agendamento_id'] as int,
      statusApp: json['status_app'] as String,
      inicio: json['inicio'] as String,
      fim: json['fim'] as String?,
      servicoNome: json['servico_nome'] as String?,
      departamentoNome: json['departamento_nome'] as String?,
      posicao: json['posicao'] as int?,
      pessoasNaFrente: json['pessoas_na_frente'] as int?,
      terminalTipo: json['terminal_tipo'] as String?,
      terminalNumero: json['terminal_numero'] as String?,
      atendenteNome: json['atendente_nome'] as String?,
    );
  }
}
