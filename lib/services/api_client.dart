import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Exceção lançada quando a API retorna um erro estruturado
/// (ver o padrão {'erro': ..., 'mensagem': ...} em app/routes/api.py).
class ApiException implements Exception {
  final int statusCode;
  final String codigo;
  final String mensagem;

  ApiException(this.statusCode, this.codigo, this.mensagem);

  @override
  String toString() => 'ApiException($statusCode, $codigo): $mensagem';
}

/// Cliente HTTP central para o backend Flask.
///
/// O backend usa sessão via cookie (Flask `session`), não tokens JWT —
/// por isso este cliente guarda o cookie `Set-Cookie` recebido no login e
/// o reenvia em toda requisição subsequente, de forma análoga ao que o
/// navegador faz automaticamente no app web. O cookie é persistido em
/// `flutter_secure_storage` (Keystore/Keychain) para sobreviver ao
/// fechamento do app — ver §2.1 da especificação.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  final http.Client _http = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _cookie;

  Future<void> carregarCookieSalvo() async {
    _cookie = await _secureStorage.read(key: AppConfig.secureStorageCookieKey);
  }

  Future<void> _salvarCookie(http.Response resposta) async {
    final setCookie = resposta.headers['set-cookie'];
    if (setCookie != null) {
      // Mantém apenas o par nome=valor (descarta atributos como Path/HttpOnly).
      _cookie = setCookie.split(';').first;
      await _secureStorage.write(
        key: AppConfig.secureStorageCookieKey,
        value: _cookie,
      );
    }
  }

  Future<void> limparSessao() async {
    _cookie = null;
    await _secureStorage.delete(key: AppConfig.secureStorageCookieKey);
    await _secureStorage.delete(key: AppConfig.secureStorageUserKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_cookie != null) 'Cookie': _cookie!,
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters:
          query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    final resposta = await _http
        .get(_uri(path, query), headers: _headers)
        .timeout(AppConfig.httpTimeout);
    return _tratarResposta(resposta);
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final resposta = await _http
        .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(AppConfig.httpTimeout);
    return _tratarResposta(resposta);
  }

  Future<Map<String, dynamic>> _tratarResposta(http.Response resposta) async {
    await _salvarCookie(resposta);

    // Sessão expirada/401 em qualquer endpoint: limpa e propaga —
    // a UI deve redirecionar para a LoginScreen (ver §6 da especificação).
    Map<String, dynamic> corpo;
    try {
      corpo = resposta.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(resposta.body) as Map<String, dynamic>;
    } catch (_) {
      corpo = <String, dynamic>{};
    }

    if (resposta.statusCode == 401) {
      await limparSessao();
    }

    if (resposta.statusCode >= 400) {
      throw ApiException(
        resposta.statusCode,
        corpo['erro'] as String? ?? 'erro_desconhecido',
        corpo['mensagem'] as String? ?? 'Ocorreu um erro inesperado.',
      );
    }

    return corpo;
  }
}
