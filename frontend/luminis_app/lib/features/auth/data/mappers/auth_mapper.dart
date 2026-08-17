import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';

/// Converte o envelope JSON decodificado pelo `ApiClient` para as entidades
/// de domínio da feature `auth`.
///
/// Isolado em `data/` para que nenhuma outra camada precise conhecer o
/// formato bruto de `docs/architecture/backend-contracts.md`.
abstract final class AuthMapper {
  /// Formato comum de `POST /api/auth/login|register|google`.
  static Session sessionFromJson(Map<String, dynamic> json) {
    return Session(
      user: userFromAuthJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// Usuário resumido embutido na resposta de login/registro/google
  /// (sem `bio`).
  static User userFromAuthJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      status: json['status'] as String,
    );
  }

  /// Usuário completo de `GET /api/me` (com `bio`).
  static User userFromMeJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      status: json['status'] as String,
    );
  }
}
