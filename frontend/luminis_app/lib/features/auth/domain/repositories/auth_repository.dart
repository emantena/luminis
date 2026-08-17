import '../entities/session.dart';
import '../entities/user.dart';

/// Contrato do módulo Identity consumido pela feature `auth`.
///
/// Implementações (mock em memória, `AuthRepositoryImpl` sobre `ApiClient`,
/// futura API real) devem respeitar exatamente esta interface. Widgets nunca
/// devem instanciar uma implementação diretamente — apenas via
/// `authRepositoryProvider` (`data/providers/auth_providers.dart`).
///
/// Todos os métodos lançam `ApiFailure` (`shared/infrastructure/api_exception.dart`)
/// em caso de erro. `ApiFailure` já é um tipo seguro de domínio — não expõe
/// `http.Response` nem detalhes de transporte — por isso este contrato não
/// precisa declarar seu próprio tipo de exceção paralelo.
abstract interface class AuthRepository {
  /// `POST /api/auth/login`.
  ///
  /// Lança `ApiUnauthorizedFailure` com `code` `auth.invalid_credentials` ou
  /// `auth.account_locked`, ou `ApiValidationFailure` (`validation.failed`).
  Future<Session> login({required String email, required String password});

  /// `POST /api/auth/register`.
  ///
  /// Lança `ApiConflictFailure` (`auth.email_already_used`) ou
  /// `ApiValidationFailure` (`validation.failed`).
  Future<Session> register({
    required String displayName,
    required String email,
    required String password,
  });

  /// `POST /api/auth/google`.
  ///
  /// Lança `ApiUnauthorizedFailure` (`auth.google_token_invalid`) ou
  /// `ApiValidationFailure` (`validation.failed`).
  Future<Session> loginWithGoogle({required String idToken});

  /// `POST /api/auth/logout`. Revoga `refreshToken` no backend.
  ///
  /// Requer `accessToken` da sessão atual como bearer token.
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  });

  /// `GET /api/me`. Retorna o usuário autenticado completo (com `bio`).
  ///
  /// Lança `ApiUnauthorizedFailure` (`auth.unauthorized`) quando o
  /// `accessToken` estiver ausente, inválido ou expirado.
  Future<User> getCurrentUser({required String accessToken});

  /// `POST /api/auth/forgot-password`. Sempre "sucede" quando a chamada HTTP
  /// completa — o backend não revela se o email existe.
  ///
  /// Lança `ApiValidationFailure` (`validation.failed`) para email inválido.
  ///
  /// NOTA (gap conhecido, ver relatório desta fatia): `backend/mock-api`
  /// ainda não implementa esta rota (`docs/architecture/backend-contracts.md`
  /// já a documenta como aprovada). Até o mock expor a rota, chamadas reais
  /// resultam em `ApiFailure` de erro (tipicamente `ApiNotFoundFailure`).
  Future<void> requestPasswordReset({required String email});

  /// `POST /api/auth/reset-password`.
  ///
  /// Lança `ApiResponseFailure` com `code` `auth.password_reset_token_invalid`
  /// para token inválido/expirado, ou `ApiValidationFailure`
  /// (`validation.failed`). O contrato não fixa o status HTTP exato do
  /// primeiro caso; controllers devem tratar por `code`, não por subtipo.
  ///
  /// NOTA (gap conhecido, ver relatório desta fatia): `backend/mock-api`
  /// ainda não implementa esta rota. Até o mock expor a rota, chamadas reais
  /// resultam em `ApiFailure` de erro (tipicamente `ApiNotFoundFailure`).
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
}
