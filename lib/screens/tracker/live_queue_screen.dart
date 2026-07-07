import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento_status.dart';
import '../../providers/queue_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Reflete em tempo real a posição do cliente na fila (polling a cada
/// 10s via QueueProvider) — ver §4.2 da especificação. Quando o status
/// muda para 'em_atendimento', a interface fica verde pulsante indicando
/// o Guichê/Consultório de destino.
class LiveQueueScreen extends StatelessWidget {
  const LiveQueueScreen({super.key, required this.agendamento});

  final AgendamentoStatus agendamento;

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, queue, _) {
        final atual = queue.agendamentosHoje.firstWhere(
          (a) => a.agendamentoId == agendamento.agendamentoId,
          orElse: () => agendamento,
        );
        final cor = AppTheme.corDoStatus(atual.statusApp);
        final emAtendimento = atual.statusApp == StatusFila.emAtendimento;

        return Scaffold(
          backgroundColor: cor.withValues(alpha: 0.06),
          appBar: AppBar(title: const Text('Acompanhar fila')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingIcon(color: cor, pulsando: emAtendimento, icon: AppTheme.iconeDoStatus(atual.statusApp)),
                  const SizedBox(height: 24),
                  Text(
                    AppTheme.rotuloDoStatus(atual.statusApp),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: cor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(atual.servicoNome ?? '', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (emAtendimento && atual.localAtendimento != null)
                    _InfoCartao(
                      titulo: 'Dirija-se a',
                      valor: atual.localAtendimento!,
                      icone: Icons.meeting_room_outlined,
                    ),
                  if (atual.statusApp == StatusFila.aguardando &&
                      atual.pessoasNaFrente != null)
                    _InfoCartao(
                      titulo: 'Pessoas na sua frente',
                      valor: '${atual.pessoasNaFrente}',
                      icone: Icons.people_outline,
                    ),
                  if (atual.statusApp == StatusFila.aguardandoTriagemInicial ||
                      atual.statusApp == StatusFila.aguardandoTriagemIntermediaria)
                    const _InfoCartao(
                      titulo: 'Próximo passo',
                      valor: 'Dirija-se à recepção para validar seus documentos',
                      icone: Icons.badge_outlined,
                    ),
                  const SizedBox(height: 32),
                  Text(
                    'Atualizado automaticamente a cada 10 segundos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoCartao extends StatelessWidget {
  const _InfoCartao({required this.titulo, required this.valor, required this.icone});

  final String titulo;
  final String valor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(valor, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.color, required this.pulsando, required this.icon});

  final Color color;
  final bool pulsando;
  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulsando) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: widget.color.withValues(alpha: 0.15),
        child: Icon(widget.icon, size: 48, color: widget.color),
      );
    }
    return ScaleTransition(
      scale: Tween(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: widget.color.withValues(alpha: 0.2),
        child: Icon(widget.icon, size: 48, color: widget.color),
      ),
    );
  }
}
