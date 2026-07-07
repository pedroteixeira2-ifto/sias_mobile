import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/agendamento_status.dart';
import '../../utils/formatters.dart';

/// QR Code do agendamento para "Check-in Expresso" na triagem (§4.1 da
/// especificação). O conteúdo do QR deve corresponder ao ID do
/// agendamento — em produção, considere assiná-lo/encriptá-lo no backend
/// em vez de expor o ID puro.
class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key, required this.agendamento});

  final AgendamentoStatus agendamento;

  @override
  Widget build(BuildContext context) {
    // TODO: substituir por um payload assinado pelo backend
    // (ex.: JWT curto com agendamento_id + expiração), em vez do ID puro.
    final conteudoQr = 'SIAS-AGENDAMENTO:${agendamento.agendamentoId}';

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in expresso')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: conteudoQr,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    agendamento.servicoNome ?? 'Atendimento',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(Formatters.hora(agendamento.inicio)),
                  const SizedBox(height: 16),
                  const Text(
                    'Apresente este código ao atendente da triagem '
                    'para agilizar seu check-in.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
