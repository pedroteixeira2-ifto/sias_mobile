import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../models/agendamento_status.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../auth/login_screen.dart';
import '../booking/department_screen.dart';
import 'live_queue_screen.dart';
import 'qr_code_screen.dart';

/// Dashboard do cliente — exibe os agendamentos do dia em destaque
/// (§4.1 da especificação). Cada card tem um QR Code para Check-in
/// Expresso na triagem.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<QueueProvider>().iniciarPolling(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Pausa o polling em background e retoma em foreground, forçando um
  // refresh imediato — ver §5 da especificação.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final queue = context.read<QueueProvider>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      queue.pausarPolling();
    } else if (state == AppLifecycleState.resumed) {
      queue.retomarPolling();
    }
  }

  Future<void> _sair() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final queue = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${auth.usuarioAtual?.nome.split(' ').first ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DepartmentScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Agendar'),
      ),
      body: RefreshIndicator(
        onRefresh: queue.carregarAgora,
        child: queue.carregando && queue.agendamentosHoje.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : queue.agendamentosHoje.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Center(child: Text('Você não tem agendamentos para hoje.')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Seus agendamentos de hoje',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...queue.agendamentosHoje.map((a) => _AgendamentoCard(agendamento: a)),
                    ],
                  ),
      ),
    );
  }
}

class _AgendamentoCard extends StatelessWidget {
  const _AgendamentoCard({required this.agendamento});

  final AgendamentoStatus agendamento;

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corDoStatus(agendamento.statusApp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveQueueScreen(agendamento: agendamento),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cor.withValues(alpha: 0.15),
                child: Icon(AppTheme.iconeDoStatus(agendamento.statusApp), color: cor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agendamento.servicoNome ?? 'Atendimento',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(agendamento.departamentoNome ?? '',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppTheme.rotuloDoStatus(agendamento.statusApp),
                            style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(Formatters.hora(agendamento.inicio),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_2_outlined),
                tooltip: 'QR Code de check-in',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QrCodeScreen(agendamento: agendamento),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
