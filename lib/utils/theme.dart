import 'package:flutter/material.dart';
import 'constants.dart';

/// Tema visual do SIAS Mobile e helpers de cor/ícone por status de fila
/// (ver §4.2 da especificação: cada status tem uma cor de interface própria).
class AppTheme {
  AppTheme._();

  static const Color azulPrimario = Color(0xFF1A3A6B);
  static const Color laranjaDestaque = Color(0xFFF59E0B);
  static const Color fundoEscuro = Color(0xFF0F172A);

  /// Cores específicas da tela de login (mockup SIAS Mobile).
  static const Color azulLogin = Color(0xFF16294D);
  static const Color azulBotaoEntrar = Color(0xFF1B76D1);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azulPrimario,
        primary: azulPrimario,
        secondary: laranjaDestaque,
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: azulPrimario,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Cor de interface para cada status de fila (§4.2 da especificação).
  static Color corDoStatus(String status) {
    switch (status) {
      case StatusFila.agendado:
        return Colors.blue.shade600;
      case StatusFila.aguardandoTriagemInicial:
      case StatusFila.aguardandoTriagemIntermediaria:
        return Colors.amber.shade700;
      case StatusFila.aguardando:
        return Colors.orange.shade700;
      case StatusFila.emAtendimento:
        return Colors.green.shade600;
      case StatusFila.concluido:
        return Colors.grey.shade600;
      case StatusFila.ausente:
      case StatusFila.cancelado:
        return Colors.red.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  static IconData iconeDoStatus(String status) {
    switch (status) {
      case StatusFila.agendado:
        return Icons.event_available_outlined;
      case StatusFila.aguardandoTriagemInicial:
      case StatusFila.aguardandoTriagemIntermediaria:
        return Icons.badge_outlined;
      case StatusFila.aguardando:
        return Icons.hourglass_top_outlined;
      case StatusFila.emAtendimento:
        return Icons.meeting_room_outlined;
      case StatusFila.concluido:
        return Icons.check_circle_outline;
      case StatusFila.ausente:
        return Icons.person_off_outlined;
      case StatusFila.cancelado:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  static String rotuloDoStatus(String status) {
    switch (status) {
      case StatusFila.agendado:
        return 'Agendado';
      case StatusFila.aguardandoTriagemInicial:
        return 'Dirija-se à triagem';
      case StatusFila.aguardandoTriagemIntermediaria:
        return 'Triagem intermediária';
      case StatusFila.aguardando:
        return 'Aguardando na fila';
      case StatusFila.emAtendimento:
        return 'Em atendimento';
      case StatusFila.concluido:
        return 'Concluído';
      case StatusFila.ausente:
        return 'Ausente';
      case StatusFila.encaminhado:
        return 'Encaminhado';
      case StatusFila.cancelado:
        return 'Cancelado';
      default:
        return status;
    }
  }
}
