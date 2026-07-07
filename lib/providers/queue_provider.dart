import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/agendamento_status.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';

/// Reflete a Máquina de Estados do backend para os agendamentos do dia —
/// ver §4.2 e §5 da especificação. Faz polling a cada
/// [AppConfig.pollingInterval] enquanto o app está em primeiro plano, e
/// deve ser pausado/retomado pelo widget raiz via
/// [pausarPolling]/[retomarPolling] em didChangeAppLifecycleState.
class QueueProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<AgendamentoStatus> agendamentosHoje = [];
  bool carregando = false;
  String? erro;
  Timer? _timer;

  Future<void> carregarAgora() async {
    carregando = true;
    notifyListeners();
    try {
      agendamentosHoje = AppConfig.useMockData
          ? _mockAgendamentos
          : await _service.statusFilaHoje();
      erro = null;
    } catch (e) {
      erro = _mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void iniciarPolling() {
    _timer?.cancel();
    carregarAgora();
    _timer = Timer.periodic(AppConfig.pollingInterval, (_) => carregarAgora());
  }

  void pausarPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void retomarPolling() {
    if (_timer == null) {
      iniciarPolling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _mensagemDeErro(Object e) {
    if (e is ApiException) return e.mensagem;
    return 'Não foi possível atualizar a fila. Verifique sua internet.';
  }

  // ── Dados de exemplo (AppConfig.useMockData = true) ──────────────────
  static final List<AgendamentoStatus> _mockAgendamentos = [
    const AgendamentoStatus(
      agendamentoId: 1042,
      statusApp: 'em_atendimento',
      inicio: '2026-07-06T14:00',
      servicoNome: 'Limpeza e profilaxia',
      departamentoNome: 'Odontologia',
      posicao: 12,
      terminalTipo: 'Consultório',
      terminalNumero: '3',
      atendenteNome: 'Dra. Ana Souza',
    ),
    const AgendamentoStatus(
      agendamentoId: 1043,
      statusApp: 'aguardando',
      inicio: '2026-07-06T15:30',
      servicoNome: 'Avaliação inicial',
      departamentoNome: 'Odontologia',
      posicao: 15,
      pessoasNaFrente: 2,
    ),
  ];
}
