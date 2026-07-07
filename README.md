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
- **Booking**: Departamento → Carrinho de Serviços → Calendário/Horários
- **Tracker**: Dashboard → Fila em tempo real → QR Code de check-in

Por padrão, `lib/utils/constants.dart` tem `AppConfig.useMockData = true`,
então o app roda e navega **sem precisar do backend rodando**, com dados
fictícios (`Maria da Silva`, departamentos/serviços de exemplo, um
agendamento "em atendimento" e outro "aguardando").

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

3. Em `lib/utils/constants.dart`:
   - Ajuste `AppConfig.apiBaseUrl`:
     - Emulador Android → `http://10.0.2.2:5000/api` (já é o padrão)
     - iOS Simulator / dispositivo físico → IP da máquina rodando o Flask
       na mesma rede, ex.: `http://192.168.0.10:5000/api`
   - Mude `AppConfig.useMockData` para `false`.

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
│   ├── booking/   # DepartmentScreen, ServiceCartScreen, CalendarScreen
│   └── tracker/   # DashboardScreen, LiveQueueScreen, QrCodeScreen
├── services/      # ApiClient, AuthService, BookingService
├── providers/     # AuthProvider, BookingProvider, QueueProvider
└── utils/         # constants (config/AppConfig), theme, formatters
```
