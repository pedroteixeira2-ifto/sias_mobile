import 'package:intl/intl.dart';

/// Formatadores de data/hora em pt-BR usados em toda a interface.
class Formatters {
  Formatters._();

  static final DateFormat _dataCompleta = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _hora = DateFormat('HH:mm', 'pt_BR');
  static final DateFormat _diaSemanaCurto = DateFormat('EEE', 'pt_BR');
  static final DateFormat _diaMes = DateFormat('dd/MM', 'pt_BR');

  /// Espera um timestamp ISO vindo do backend, ex.: "2026-07-06T14:30".
  static String hora(String isoTimestamp) {
    try {
      return _hora.format(DateTime.parse(isoTimestamp));
    } catch (_) {
      return isoTimestamp.length >= 16
          ? isoTimestamp.substring(11, 16)
          : isoTimestamp;
    }
  }

  static String dataCompleta(DateTime data) => _dataCompleta.format(data);

  static String diaSemanaCurto(DateTime data) =>
      _diaSemanaCurto.format(data).replaceAll('.', '');

  static String diaMes(DateTime data) => _diaMes.format(data);

  static String dataIso(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';
}
