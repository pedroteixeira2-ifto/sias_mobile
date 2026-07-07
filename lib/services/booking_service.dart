import '../models/agendamento_status.dart';
import '../models/departamento.dart';
import '../models/horario_disponivel.dart';
import '../models/servico.dart';
import 'api_client.dart';

/// Endpoints de agendamento e consulta de slots/fila — espelha
/// /api/departamentos/*, /api/agendamento/* e /api/cliente/* em
/// app/routes/api.py.
class BookingService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Departamento>> listarDepartamentos() async {
    final resp = await _client.get('/departamentos');
    return (resp['departamentos'] as List<dynamic>)
        .map((e) => Departamento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Servico>> listarServicos(int departamentoId) async {
    final resp = await _client.get('/departamentos/$departamentoId/servicos');
    return (resp['servicos'] as List<dynamic>)
        .map((e) => Servico.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HorarioDisponivel>> consultarDisponibilidade({
    required List<int> servicoIds,
    required String data, // "AAAA-MM-DD"
  }) async {
    final resp = await _client.post('/agendamento/disponibilidade', body: {
      'servico_ids': servicoIds,
      'data': data,
    });
    return (resp['horarios'] as List<dynamic>)
        .map((e) => HorarioDisponivel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Retorna o agendamento_id criado. Em caso de conflito (slot tomado por
  /// outro usuário no mesmo instante), o ApiClient lança ApiException com
  /// codigo 'conflito' — a tela deve exibir um aviso e atualizar a grade.
  Future<int> confirmarAgendamento(int slotId) async {
    final resp = await _client.post('/agendamento/confirmar', body: {
      'slot_id': slotId,
    });
    return resp['agendamento_id'] as int;
  }

  Future<void> cancelarAgendamento(int agendamentoId) async {
    await _client.post('/agendamento/$agendamentoId/cancelar');
  }

  Future<List<Map<String, dynamic>>> meusAgendamentos() async {
    final resp = await _client.get('/cliente/meus-agendamentos');
    return (resp['agendamentos'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Consumido pelo QueueProvider em polling — ver §4.2 da especificação.
  Future<List<AgendamentoStatus>> statusFilaHoje() async {
    final resp = await _client.get('/cliente/meus-agendamentos/status');
    return (resp['agendamentos'] as List<dynamic>)
        .map((e) => AgendamentoStatus.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
