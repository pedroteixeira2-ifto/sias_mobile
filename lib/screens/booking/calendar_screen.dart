import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/horario_disponivel.dart';
import '../../utils/formatters.dart';
import '../tracker/dashboard_screen.dart';

/// Tela de calendário e horários — consulta disponibilidade combinada dos
/// serviços do carrinho e confirma a reserva (§3.2 da especificação).
/// Em caso de conflito (slot reservado por outro usuário no mesmo
/// segundo), a API retorna 409 e a grade é recarregada automaticamente.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  Future<void> _confirmar(BuildContext context, HorarioDisponivel horario) async {
    final provider = context.read<BookingProvider>();
    final ok = await provider.confirmarHorario(horario);
    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Agendamento confirmado! Senha: A-${provider.ultimoAgendamentoId}')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.erro ?? 'Esse horário não está mais disponível.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final proximosDias = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Escolha o horário')),
      body: Column(
        children: [
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: proximosDias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final dia = proximosDias[i];
                final selecionado = dia.day == provider.dataSelecionada.day &&
                    dia.month == provider.dataSelecionada.month;
                return GestureDetector(
                  onTap: () => context.read<BookingProvider>().selecionarData(dia),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: selecionado
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Formatters.diaSemanaCurto(dia),
                            style: TextStyle(
                                fontSize: 11,
                                color: selecionado ? Colors.white70 : Colors.black54)),
                        Text(Formatters.diaMes(dia),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selecionado ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: provider.carregando
                ? const Center(child: CircularProgressIndicator())
                : provider.horarios.isEmpty
                    ? const Center(child: Text('Nenhum horário disponível nesta data.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.horarios.length,
                        itemBuilder: (context, i) {
                          final h = provider.horarios[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                child: Text(h.hora.substring(0, 2)),
                              ),
                              title: Text(h.hora),
                              subtitle: Text(h.servicoNome),
                              trailing: FilledButton(
                                onPressed: () => _confirmar(context, h),
                                child: const Text('Reservar'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
