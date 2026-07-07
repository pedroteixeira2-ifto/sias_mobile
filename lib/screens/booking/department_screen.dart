import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/departamento.dart';
import 'service_cart_screen.dart';

/// Tela de seleção de Departamento — primeiro passo do fluxo de
/// agendamento (§3.1 da especificação).
class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<BookingProvider>().carregarDepartamentos(),
    );
  }

  Future<void> _selecionar(Departamento departamento) async {
    final provider = context.read<BookingProvider>();
    await provider.selecionarDepartamento(departamento);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ServiceCartScreen()),
      );
    }
  }

  static const _icones = {
    1: Icons.medical_services_outlined,
    2: Icons.badge_outlined,
    3: Icons.local_hospital_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: provider.carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.carregarDepartamentos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Qual departamento você deseja agendar?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...provider.departamentos.map(
                    (d) => Card(
                      child: ListTile(
                        leading: Icon(_icones[d.id] ?? Icons.apartment_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(d.nome),
                        subtitle: d.descricao != null ? Text(d.descricao!) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selecionar(d),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
