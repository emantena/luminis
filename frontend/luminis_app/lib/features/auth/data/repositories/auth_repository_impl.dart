import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/auth_mapper.dart';

/// Implementação de [AuthRepository] sobre [ApiClient], consumindo as rotas
/// de `auth`/`me` do módulo Identity (`docs/architecture/backend-contracts.md`).
///
/// [ApiClient] já converte falhas de rede/HTTP em `ApiFailure`
/// (`shared/infrastructure/api_exception.dart`); este repository apenas
/// monta request/response e não captura/rewrap essas exceções, para não
/// perder informação (`code`, `traceId`, `fieldErrors`) que os controllers
/// precisam.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final Object? response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthMapper.sessionFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Session> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final Object? response = await _apiClient.post(
      '/auth/register',
      body: {'displayName': displayName, 'email': email, 'password': password},
    );
    return AuthMapper.sessionFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Session> loginWithGoogle({required String idToken}) async {
    final Object? response = await _apiClient.post(
      '/auth/google',
      body: {'idToken': idToken},
    );
    return AuthMapper.sessionFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _apiClient.post(
      '/auth/logout',
      body: {'refreshToken': refreshToken},
      bearerToken: accessToken,
    );
  }

  @override
  Future<User> getCurrentUser({required String accessToken}) async {
    final Object? response = await _apiClient.get(
      '/me',
      bearerToken: accessToken,
    );
    return AuthMapper.userFromMeJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _apiClient.post('/auth/forgot-password', body: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {'token': token, 'newPassword': newPassword},
    );
  }
}
