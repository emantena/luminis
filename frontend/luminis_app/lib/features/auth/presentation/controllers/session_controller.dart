import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../data/providers/auth_providers.dart';
import '../../domain/entities/session.dart';
import 'session_state.dart';

/// Provider de sessão do app.
///
/// **API pública para outros agentes:**
/// - Tipo: `NotifierProvider<SessionController, SessionState>`.
/// - `luminis-go-router-agent` deve ler `ref.read(sessionControllerProvider)`
///   (ou observar via `ProviderContainer`/ponte `Listenable`, ver
///   `references/riverpod-3.md`) para decidir redirect entre fluxo público
///   (`/auth/*`) e shell autenticado.
/// - `SessionAuthenticated` é o único estado com sessão válida; qualquer
///   outro estado deve ser tratado como "não autenticado" para efeito de
///   guard de rota.
///
/// `keepAlive` (não é `autoDispose`): sessão deve sobreviver à navegação
/// entre todas as telas do app, conforme `references/riverpod-3.md`.
final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Token bearer da sessão atual para a composição de repositories protegidos.
///
/// Este provider expõe apenas o token em memória à camada de injeção de
/// dependências; widgets e controllers de features nunca o leem diretamente.
/// `null` deixa a API responder com o erro padronizado `auth.unauthorized`.
final currentAccessTokenProvider = Provider<String?>((ref) {
  final sessionState = ref.watch(sessionControllerProvider);
  return switch (sessionState) {
    SessionAuthenticated(:final session) => session.accessToken,
    _ => null,
  };
});

/// Dono único do estado de sessão autenticada (token em memória).
///
/// Controllers de formulário (`LoginController`, `RegisterController`,
/// `LogoutController`) delegam a este controller a autenticação e a troca
/// de estado de sessão — eles não duplicam essa lógica, apenas coordenam o
/// estado de UI do próprio formulário (`idle/submitting/success/erro`) e
/// traduzem [ApiFailure] em mensagem/erro de campo.
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionUnauthenticated();

  /// `POST /api/auth/login`.
  Future<Session> loginWithPassword({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => ref
          .read(authRepositoryProvider)
          .login(email: email, password: password),
    );
  }

  /// `POST /api/auth/register`.
  Future<Session> register({
    required String displayName,
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => ref
          .read(authRepositoryProvider)
          .register(displayName: displayName, email: email, password: password),
    );
  }

  /// `POST /api/auth/google`.
  Future<Session> loginWithGoogle({required String idToken}) {
    return _authenticate(
      () => ref.read(authRepositoryProvider).loginWithGoogle(idToken: idToken),
    );
  }

  Future<Session> _authenticate(Future<Session> Function() action) async {
    state = const SessionAuthenticating();
    try {
      final session = await action();
      state = SessionAuthenticated(session);
      return session;
    } on ApiFailure catch (failure) {
      state = SessionError(failure.message);
      rethrow;
    }
  }

  /// `POST /api/auth/logout`. Sempre termina em [SessionUnauthenticated],
  /// mesmo quando a revogação falha no backend (ex.: rede indisponível) —
  /// manter um token "pendurado" localmente seria pior do que uma revogação
  /// de servidor não confirmada. Quem chamar pode capturar [ApiFailure]
  /// relançado para avisar o usuário, sem que isso desfaça o logout local.
  Future<void> logout() async {
    final current = state;
    if (current is! SessionAuthenticated) {
      state = const SessionUnauthenticated();
      return;
    }

    try {
      await ref
          .read(authRepositoryProvider)
          .logout(
            accessToken: current.session.accessToken,
            refreshToken: current.session.refreshToken,
          );
    } on ApiFailure {
      state = const SessionUnauthenticated();
      rethrow;
    }
    state = const SessionUnauthenticated();
  }

  /// Permite que a UI reconheça um [SessionError] e volte a um estado
  /// neutro (ex.: antes de o usuário tentar autenticar de novo).
  void acknowledgeError() {
    if (state is SessionError) {
      state = const SessionUnauthenticated();
    }
  }
}
