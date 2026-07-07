/// Constantes globais do aplicativo.
///
/// [useMockData] controla se as telas usam dados de exemplo (padrão nesta
/// primeira entrega, para permitir navegação completa sem o backend rodando)
/// ou se chamam de fato a API Flask em [apiBaseUrl].
///
/// Para ligar a integração real:
///   1. Rode o backend Flask (docker compose up --build, ou flask run).
///   2. Ajuste [apiBaseUrl] conforme o ambiente (ver comentários abaixo).
///   3. Mude [useMockData] para false.
class AppConfig {
  AppConfig._();

  /// Enquanto true, os Providers usam dados mockados em vez de chamar a API.
  static const bool useMockData = true;

  /// Base URL da API (blueprint /api/* em app/routes/api.py).
  ///
  /// - Emulador Android: o host da máquina é acessível em 10.0.2.2.
  /// - iOS Simulator / dispositivo físico na mesma rede: use o IP da
  ///   máquina rodando o Flask (ex.: http://192.168.0.10:5000).
  /// - Nunca use HTTP puro em produção (ver §6 da especificação —
  ///   Certificate Pinning / HTTPS Strict).
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';

  static const Duration pollingInterval = Duration(seconds: 10);
  static const Duration httpTimeout = Duration(seconds: 15);

  static const String secureStorageCookieKey = 'sias_session_cookie';
  static const String secureStorageUserKey = 'sias_usuario_json';
}

/// Status possíveis de uma entrada na fila, espelhando o backend
/// (fila_atendimento.status_fila) já traduzido pela API — ver
/// _mapear_status_app em app/routes/api.py.
class StatusFila {
  static const String agendado = 'agendado';
  static const String aguardandoTriagemInicial = 'aguardando_triagem_inicial';
  static const String aguardandoTriagemIntermediaria =
      'aguardando_triagem_intermediaria';
  static const String aguardando = 'aguardando';
  static const String emAtendimento = 'em_atendimento';
  static const String concluido = 'concluido';
  static const String ausente = 'ausente';
  static const String encaminhado = 'encaminhado';
  static const String cancelado = 'cancelado';
}
