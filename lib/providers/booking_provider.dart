import 'package:flutter/foundation.dart';
import '../models/departamento.dart';
import '../models/horario_disponivel.dart';
import '../models/servico.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Estado do fluxo de agendamento em "Carrinho de Serviços" — ver §3 da
/// especificação. Mantém o departamento selecionado, os serviços
/// adicionados ao carrinho e os horários disponíveis para a data escolhida.
class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<Departamento> departamentos = [];
  Departamento? departamentoSelecionado;
  List<Servico> servicosDisponiveis = [];
  final List<Servico> carrinho = [];

  DateTime dataSelecionada = DateTime.now();
  List<HorarioDisponivel> horarios = [];

  /// Quantidade de horários disponíveis por dia (chave = data ISO
  /// "AAAA-MM-DD"), usada para destacar no seletor de dias quais datas
  /// realmente têm disponibilidade — ver carregarSemana().
  Map<String, int> contagemPorDia = {};

  bool carregando = false;
  String? erro;
  int? ultimoAgendamentoId;

  Future<void> carregarDepartamentos() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      departamentos = AppConfig.useMockData
          ? _mockDepartamentos
          : await _service.listarDepartamentos();
    } catch (e) {
      erro = _mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> selecionarDepartamento(Departamento departamento) async {
    departamentoSelecionado = departamento;
    carrinho.clear();
    carregando = true;
    notifyListeners();
    try {
      servicosDisponiveis = AppConfig.useMockData
          ? _mockServicos(departamento.id)
          : await _service.listarServicos(departamento.id);
    } catch (e) {
      erro = _mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void alternarNoCarrinho(Servico servico) {
    if (carrinho.any((s) => s.id == servico.id)) {
      carrinho.removeWhere((s) => s.id == servico.id);
    } else {
      carrinho.add(servico);
    }
    notifyListeners();
  }

  bool estaNoCarrinho(Servico servico) =>
      carrinho.any((s) => s.id == servico.id);

  Future<void> selecionarData(DateTime data) async {
    dataSelecionada = data;
    await carregarDisponibilidade();
  }

  Future<void> carregarDisponibilidade() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      horarios = AppConfig.useMockData
          ? _mockHorarios
          : await _service.consultarDisponibilidade(
              servicoIds: carrinho.map((s) => s.id).toList(),
              data: Formatters.dataIso(dataSelecionada),
            );
      contagemPorDia[Formatters.dataIso(dataSelecionada)] = horarios.length;
    } catch (e) {
      erro = _mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  /// Consulta a disponibilidade dos próximos 7 dias (mesma janela exibida
  /// pelo seletor de dias da CalendarScreen) e já seleciona automaticamente
  /// o primeiro dia que tiver algum horário livre, em vez de deixar o
  /// usuário parado em "hoje" quando hoje não tem disponibilidade
  /// cadastrada. Preenche [contagemPorDia] para destacar no seletor quais
  /// dias têm vaga.
  Future<void> carregarSemana() async {
    carregando = true;
    erro = null;
    contagemPorDia = {};
    notifyListeners();

    if (AppConfig.useMockData) {
      dataSelecionada = DateTime.now();
      horarios = _mockHorarios;
      contagemPorDia[Formatters.dataIso(dataSelecionada)] = horarios.length;
      carregando = false;
      notifyListeners();
      return;
    }

    final hoje = DateTime.now();
    final servicoIds = carrinho.map((s) => s.id).toList();
    bool encontrouDiaComVaga = false;

    for (var i = 0; i < 7; i++) {
      final dia = hoje.add(Duration(days: i));
      final dataIso = Formatters.dataIso(dia);
      try {
        final lista = await _service.consultarDisponibilidade(
          servicoIds: servicoIds,
          data: dataIso,
        );
        contagemPorDia[dataIso] = lista.length;
        if (lista.isNotEmpty && !encontrouDiaComVaga) {
          dataSelecionada = dia;
          horarios = lista;
          encontrouDiaComVaga = true;
        }
      } catch (e) {
        contagemPorDia[dataIso] = 0;
        erro ??= _mensagemDeErro(e);
      }
    }

    if (!encontrouDiaComVaga) {
      // Nenhum dia da semana tem vaga: mantém hoje selecionado e a lista
      // vazia, para que a tela explique que não há horários no período.
      dataSelecionada = hoje;
      horarios = [];
    }

    carregando = false;
    notifyListeners();
  }

  /// Retorna true em sucesso. Em conflito de concorrência, [erro] é
  /// preenchido e a grade de horários deve ser recarregada pela tela.
  Future<bool> confirmarHorario(HorarioDisponivel horario) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      if (AppConfig.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        ultimoAgendamentoId = 1042;
        return true;
      }
      ultimoAgendamentoId =
          await _service.confirmarAgendamento(horario.slotIdPrincipal);
      return true;
    } catch (e) {
      erro = _mensagemDeErro(e);
      if (!AppConfig.useMockData) {
        await carregarDisponibilidade();
      }
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  String _mensagemDeErro(Object e) {
    if (e is ApiException) return e.mensagem;
    return 'Não foi possível conectar ao servidor. Verifique sua internet.';
  }

  // ── Dados de exemplo (AppConfig.useMockData = true) ──────────────────
  static final List<Departamento> _mockDepartamentos = [
    const Departamento(id: 1, nome: 'Odontologia', descricao: 'Consultas e procedimentos odontológicos'),
    const Departamento(id: 2, nome: 'Emissão de RG', descricao: 'Documento de identidade civil'),
    const Departamento(id: 3, nome: 'Clínica Geral', descricao: 'Atendimento médico geral'),
  ];

  static List<Servico> _mockServicos(int departamentoId) {
    switch (departamentoId) {
      case 1:
        return const [
          Servico(id: 10, nome: 'Limpeza e profilaxia'),
          Servico(id: 11, nome: 'Avaliação inicial'),
          Servico(id: 12, nome: 'Extração'),
        ];
      case 2:
        return const [
          Servico(id: 20, nome: 'Primeira via'),
          Servico(id: 21, nome: 'Segunda via'),
        ];
      default:
        return const [
          Servico(id: 30, nome: 'Consulta de rotina'),
          Servico(id: 31, nome: 'Retorno'),
        ];
    }
  }

  static final List<HorarioDisponivel> _mockHorarios = const [
    HorarioDisponivel(hora: '08:30', servicoId: 10, servicoNome: 'Limpeza e profilaxia', departamentoNome: 'Odontologia', slotIds: [101]),
    HorarioDisponivel(hora: '09:00', servicoId: 10, servicoNome: 'Limpeza e profilaxia', departamentoNome: 'Odontologia', slotIds: [102]),
    HorarioDisponivel(hora: '10:15', servicoId: 11, servicoNome: 'Avaliação inicial', departamentoNome: 'Odontologia', slotIds: [103]),
    HorarioDisponivel(hora: '14:00', servicoId: 10, servicoNome: 'Limpeza e profilaxia', departamentoNome: 'Odontologia', slotIds: [104]),
  ];
}
