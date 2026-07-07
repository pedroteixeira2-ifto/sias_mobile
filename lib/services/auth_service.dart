import '../models/usuario.dart';
import 'api_client.dart';

/// Endpoints de login e sessão — espelha POST /api/auth/* em
/// app/routes/api.py.
class AuthService {
  final ApiClient _client = ApiClient.instance;

  /// Retorna true se o backend exige 2FA (sempre true no fluxo atual).
  Future<bool> login(String email, String senha) async {
    final resp = await _client.post('/auth/login', body: {
      'email': email,
      'senha': senha,
    });
    return resp['requer_2fa'] == true;
  }

  Future<Usuario> verify2FA(String token) async {
    final resp = await _client.post('/auth/verificar-2fa', body: {
      'token': token,
    });
    return Usuario.fromJson(resp['usuario'] as Map<String, dynamic>);
  }

  Future<void> resend2FA() async {
    await _client.post('/auth/reenviar-2fa');
  }

  Future<bool> registrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmaSenha,
  }) async {
    final resp = await _client.post('/auth/registro', body: {
      'nome': nome,
      'email': email,
      'senha': senha,
      'confirma_senha': confirmaSenha,
    });
    return resp['requer_2fa'] == true;
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
    await _client.limparSessao();
  }

  Future<Usuario> me() async {
    final resp = await _client.get('/auth/me');
    return Usuario.fromJson(resp['usuario'] as Map<String, dynamic>);
  }
}
