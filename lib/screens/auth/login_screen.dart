import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'two_factor_screen.dart';
import 'register_screen.dart';

/// Tela de login — visual alinhado ao mockup SIAS Mobile: fundo azul-marinho,
/// ícone de calendário com check, campos com ícone lateral em caixa cinza,
/// botão "Entrar" azul e botão secundário "Continuar com o Google".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailController.text, _senhaController.text);
    if (ok && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TwoFactorScreen()),
      );
    } else if (mounted && auth.erro != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.erro!)));
    }
  }

  void _continuarComGoogle() {
    // TODO: integrar com um provedor OAuth real (ex.: google_sign_in) e
    // um endpoint /api/auth/google no backend. Por enquanto, apenas
    // sinaliza que o recurso ainda não está disponível.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login com Google ainda não disponível.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.azulLogin,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 56),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SIAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistema Integrado de Agendamento Seguro',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 48),
                _CampoComIcone(
                  label: 'E-mail',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  dica: 'seu@email.com',
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 24),
                _CampoComIcone(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  controller: _senhaController,
                  dica: 'Insira sua Senha',
                  obscureText: !_senhaVisivel,
                  sufixo: IconButton(
                    icon: Icon(
                      _senhaVisivel
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black45,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe sua senha' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.azulBotaoEntrar,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: auth.carregando ? null : _entrar,
                    child: auth.carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Entrar',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _continuarComGoogle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _LogoGoogle(),
                        const SizedBox(width: 10),
                        Text(
                          'Continuar com o Google',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15),
                        children: const [
                          TextSpan(text: 'Não tem conta? '),
                          TextSpan(
                            text: 'Registre-se',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de texto com rótulo em negrito acima e ícone em caixa cinza à
/// esquerda, conforme o mockup (campos "E-mail" e "Senha").
class _CampoComIcone extends StatelessWidget {
  const _CampoComIcone({
    required this.label,
    required this.icon,
    required this.controller,
    required this.dica,
    this.keyboardType,
    this.obscureText = false,
    this.sufixo,
    this.validator,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String dica;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? sufixo;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.black54),
              ),
              Expanded(
                child: Container(
                  height: 56,
                  color: Colors.white,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    validator: validator,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: dica,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      suffixIcon: sufixo,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "G" colorido simplificado para o botão "Continuar com o Google" —
/// evita depender de um asset de imagem/logo oficial.
class _LogoGoogle extends StatelessWidget {
  const _LogoGoogle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const SweepGradient(
              colors: [
                Color(0xFF4285F4),
                Color(0xFF34A853),
                Color(0xFFFBBC05),
                Color(0xFFEA4335),
                Color(0xFF4285F4),
              ],
            ).createShader(bounds),
            child: const Text(
              'G',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
