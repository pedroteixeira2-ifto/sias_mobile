import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import 'calendar_screen.dart';

/// Tela do "carrinho de serviços" — o usuário escolhe um ou mais serviços
/// do departamento selecionado antes de consultar a disponibilidade
/// (§3.1 da especificação).
class ServiceCartScreen extends StatelessWidget {
  const ServiceCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.departamentoSelecionado?.nome ?? 'Serviços'),
      ),
      body: provider.carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Selecione os serviços desejados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...provider.servicosDisponiveis.map((s) {
                        final selecionado = provider.estaNoCarrinho(s);
                        return Card(
                          color: selecionado
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08)
                              : null,
                          child: CheckboxListTile(
                            value: selecionado,
                            onChanged: (_) =>
                                context.read<BookingProvider>().alternarNoCarrinho(s),
                            title: Text(s.nome),
                            subtitle: s.descricao != null ? Text(s.descricao!) : null,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        provider.carrinho.isEmpty
                            ? 'Escolha ao menos um serviço'
                            : 'Ver horários (${provider.carrinho.length} selecionado(s))',
                      ),
                      onPressed: provider.carrinho.isEmpty
                          ? null
                          : () {
                              context.read<BookingProvider>().carregarDisponibilidade();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const CalendarScreen()),
                              );
                            },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
