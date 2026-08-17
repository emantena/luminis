import 'user.dart';

/// Sessão autenticada emitida por `/api/auth/login`, `/api/auth/register` ou
/// `/api/auth/google` (mesmo formato de resposta nos três, conforme
/// `docs/architecture/backend-contracts.md`).
///
/// Mantida apenas em memória pelo controller de sessão (`SessionController`)
/// — não há armazenamento seguro no escopo atual
/// (`docs/architecture/security.md`).
class Session {
  const Session({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) {
    return other is Session &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(user, accessToken, refreshToken, expiresAt);

  @override
  String toString() => 'Session(user: ${user.id})';
}
