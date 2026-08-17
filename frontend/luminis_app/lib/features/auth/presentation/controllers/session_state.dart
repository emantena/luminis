import '../../domain/entities/session.dart';

/// Estado da sessão autenticada do app, exposto por
/// `sessionControllerProvider`.
///
/// `sealed` para permitir `switch` exaustivo tanto no guard de rota
/// (`luminis-go-router-agent`) quanto em widgets que precisem reagir à
/// sessão (ex.: avatar no shell autenticado).
sealed class SessionState {
  const SessionState();
}

/// Estado inicial e estado após logout. Nenhuma sessão válida em memória.
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// Uma operação de login/registro/logout está em andamento. O router não
/// deve redirecionar com base neste estado sozinho — apenas aguardar a
/// transição para `SessionAuthenticated`/`SessionUnauthenticated`.
final class SessionAuthenticating extends SessionState {
  const SessionAuthenticating();
}

/// Sessão válida em memória, com token pronto para ser usado como bearer
/// token pelos demais repositories do app.
final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.session);

  final Session session;
}

/// Uma tentativa de autenticar/registrar falhou e nenhuma sessão está ativa.
/// Distinto de `SessionUnauthenticated` para que a UI possa exibir a última
/// falha quando fizer sentido; controllers de formulário (`LoginController`
/// etc.) não dependem deste estado para exibir erro de campo — eles mantêm
/// seu próprio estado de formulário.
final class SessionError extends SessionState {
  const SessionError(this.message);

  final String message;
}
