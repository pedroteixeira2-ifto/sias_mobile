import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/queue_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tracker/dashboard_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SiasMobileApp());
}

class SiasMobileApp extends StatelessWidget {
  const SiasMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: MaterialApp(
        title: 'SIAS Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RaizDoApp(),
      ),
    );
  }
}

/// Decide a primeira tela com base na sessão restaurada do armazenamento
/// seguro (cookie de sessão) — ver §2.1/§2.2 da especificação.
class _RaizDoApp extends StatefulWidget {
  const _RaizDoApp();

  @override
  State<_RaizDoApp> createState() => _RaizDoAppState();
}

class _RaizDoAppState extends State<_RaizDoApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AuthProvider>().restaurarSessao(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.autenticado:
        return const DashboardScreen();
      case AuthStatus.desconhecido:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.deslogado:
      case AuthStatus.aguardando2fa:
        return const LoginScreen();
    }
  }
}
