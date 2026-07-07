import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../utils/constants.dart';

enum AuthStatus { desconhecido, deslogado, aguardando2fa, autenticado }

/// Mantém a instância do usuário logado e o status do fluxo de
/// autenticação (login -> 2FA -> autenticado) — ver §2.1 da especificação.
///
/// Nesta primeira entrega, quando [AppConfig.useMockData] é true, o
/// provider simula os passos do fluxo sem chamar a API de fato, para que
/// as telas fiquem navegáveis sem o backend rodando.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.desconhecido;
  Usuario? usuarioAtual;
  String? erro;
  bool carregando = false;

  Future<void> restaurarSessao() async {
    if (AppConfig.useMockData) {
      status = AuthStatus.deslogado;
      notifyListeners();
      return;
    }
    await ApiClient.instance.carregarCookieSalvo();
    try {
      usuarioAtual = await _authService.me();
      status = AuthStatus.autenticado;
    } catch (_) {
      status = AuthStatus.deslogado;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      if (AppConfig.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        status = AuthStatus.aguardando2fa;
        return true;
      }
      await _authService.login(email, senha);
      status = AuthStatus.aguardando2fa;
      return true;
    } catch (e) {
      erro = _mensagemDeErro(e);
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> verificarCodigo(String token) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      if (AppConfig.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        usuarioAtual = const Usuario(
          id: 1,
          nome: 'Maria da Silva',
          email: 'maria.silva@example.com',
          papel: 'cliente',
          emailVerificado: true,
        );
        status = AuthStatus.autenticado;
        return true;
      }
      usuarioAtual = await _authService.verify2FA(token);
      status = AuthStatus.autenticado;
      return true;
    } catch (e) {
      erro = _mensagemDeErro(e);
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> reenviarCodigo() async {
    if (AppConfig.useMockData) return;
    try {
      await _authService.resend2FA();
    } catch (_) {
      // Falha silenciosa aqui é aceitável — o usuário pode tentar de novo.
    }
  }

  Future<void> logout() async {
    if (!AppConfig.useMockData) {
      try {
        await _authService.logout();
      } catch (_) {}
    }
    usuarioAtual = null;
    status = AuthStatus.deslogado;
    notifyListeners();
  }

  String _mensagemDeErro(Object e) {
    if (e is ApiException) return e.mensagem;
    return 'Não foi possível conectar ao servidor. Verifique sua internet.';
  }
}
