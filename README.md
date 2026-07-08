# SIAS Mobile

Aplicativo Flutter/Dart para a jornada do cliente/cidadão do SIAS
(Sistema Integrado de Agendamento Seguro), consumindo a API do backend
Flask localizado em `C:\projeto-uab`.

Especificação completa: `SIAS_Mobile_Especificacao.md` (anexado no chat
que gerou este projeto).

## Estado atual (esqueleto navegável)

Este é um **esqueleto completo e navegável**, com dados de exemplo
(mock), pronto para você preencher a lógica de integração real aos
poucos. Todas as telas principais existem e navegam entre si:

- **Auth**: Login → 2FA → (Cadastro)
- **Home**: tela inicial pós-login, com atalhos para "Agendar consulta" e
  "Histórico de agendamentos", além de um resumo dos agendamentos de hoje
- **Booking**: Departamento → Carrinho de Serviços → Calendário/Horários
- **History**: lista completa de agendamentos do cliente (passados,
  futuros e cancelados), com opção de cancelar
- **Tracker**: Dashboard (agendamentos de hoje) → Fila em tempo real →
  QR Code de check-in

`lib/utils/constants.dart` já está configurado para conversar com o
backend real (`AppConfig.useMockData = false`, `apiBaseUrl` apontando
para `localhost:5200`/`10.0.2.2:5200`, conforme o SIAS web em
`C:\projeto-uab`). Para navegar com dados fictícios sem o backend
rodando, mude `AppConfig.useMockData` para `true`.

## Como ligar a integração real com o backend

1. Rode o backend (a partir de `C:\projeto-uab`):
   ```
   docker compose up --build
   ```
   ou, para desenvolvimento local sem Docker:
   ```
   flask --app app run --debug
   ```

2. Confirme que o blueprint `/api/*` foi registrado — recém-criado em
   `app/routes/api.py` e registrado em `app/__init__.py`. Ele reaproveita
   os mesmos modelos e regras do app web (sessão via cookie, 2FA por
   e-mail), mas devolve JSON. Rotas principais:

   | Método | Rota                                              | Descrição |
   |--------|----------------------------------------------------|-----------|
   | POST   | `/api/auth/login`                                   | 1ª etapa do login |
   | POST   | `/api/auth/verificar-2fa`                           | 2ª etapa (código por e-mail) |
   | POST   | `/api/auth/reenviar-2fa`                            | Reenvia o código |
   | POST   | `/api/auth/registro`                                | Cadastro de novo cliente |
   | POST   | `/api/auth/logout`                                  | Encerra a sessão |
   | GET    | `/api/auth/me`                                      | Usuário logado |
   | GET    | `/api/departamentos`                                | Departamentos (especialidades) |
   | GET    | `/api/departamentos/<id>/servicos`                  | Serviços do departamento |
   | POST   | `/api/agendamento/disponibilidade`                  | Horários disponíveis |
   | POST   | `/api/agendamento/confirmar`                        | Confirma a reserva de um slot |
   | POST   | `/api/agendamento/<id>/cancelar`                    | Cancela um agendamento |
   | GET    | `/api/cliente/meus-agendamentos`                    | Lista de agendamentos |
   | GET    | `/api/cliente/meus-agendamentos/status`             | Status em tempo real (polling) |

3. Em `lib/utils/constants.dart`, ajuste `AppConfig.apiBaseUrl` conforme o
   dispositivo/emulador usado (o SIAS web escuta na porta 5200, não 5000):
   - Emulador Android → `http://10.0.2.2:5200/api` (já é o padrão)
   - iOS Simulator → `http://localhost:5200/api`
   - Dispositivo físico na mesma rede Wi-Fi → IP da máquina rodando o
     Flask, ex.: `http://192.168.0.10:5200/api` (lembre de liberar esse
     host em `android/app/src/main/res/xml/network_security_config.xml`
     também)

4. Rode:
   ```
   flutter pub get
   flutter run
   ```

## Observações importantes / pendências conhecidas

- **CSRF**: as rotas `/api/*` são isentas de proteção CSRF
  (`csrf.exempt(api.bp)` em `app/__init__.py`), pois o app mobile não tem
  acesso a um token de formulário HTML. A sessão continua protegida por
  cookie `HttpOnly` + 2FA.
- **HTTPS**: em produção, sirva a API sob HTTPS e configure Certificate
  Pinning (§6 da especificação) — o `ApiClient` atual não faz pinning.
  Em desenvolvimento, o HTTP puro para `10.0.2.2`/`localhost` é liberado
  via `network_security_config.xml` (Android); restrinja isso antes de
  ir para produção.
- **QR Code**: hoje o QR contém apenas o `agendamento_id` em texto puro
  (ver TODO em `lib/screens/tracker/qr_code_screen.dart`). Antes de ir
  para produção, prefira um payload assinado/temporário gerado pelo
  backend para o check-in expresso.
- **Biometria (`local_auth`)** e **certificate pinning** estão listados
  como dependência/expansão futura na especificação (§2.2 e §6), ainda
  não implementados aqui.
- **Estrutura Android/iOS**: este esqueleto contém apenas `pubspec.yaml`
  e `lib/`. Se a pasta ainda não tiver as pastas `android/` e `ios/`
  geradas pelo Flutter, rode `flutter create .` dentro de
  `C:\Users\Pedro James\AndroidStudioProjects\SIAS Mobile` para gerá-las
  (isso não sobrescreve o conteúdo de `lib/`).

## Estrutura de pastas

```
lib/
├── main.dart
├── models/        # DTOs a partir do JSON da API
├── screens/
│   ├── auth/      # LoginScreen, TwoFactorScreen, RegisterScreen
│   ├── home/      # HomeScreen (hub pós-login)
│   ├── booking/   # DepartmentScreen, ServiceCartScreen, CalendarScreen
│   ├── history/   # HistoryScreen (histórico de agendamentos)
│   └── tracker/   # DashboardScreen, LiveQueueScreen, QrCodeScreen
├── services/      # ApiClient, AuthService, BookingService
├── providers/     # AuthProvider, BookingProvider, QueueProvider, HistoryProvider
└── utils/         # constants (config/AppConfig), theme, formatters
```
