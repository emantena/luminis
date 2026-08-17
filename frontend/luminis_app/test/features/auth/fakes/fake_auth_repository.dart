import 'package:luminis_app/features/auth/domain/entities/session.dart';
import 'package:luminis_app/features/auth/domain/entities/user.dart';
import 'package:luminis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

/// Fake de [AuthRepository] para testes de controllers/providers, seguindo
/// `references/riverpod-3.md` ("usar overrides para isolar repositories e
/// cenários de erro"). Nenhum teste desta feature deve bater no
/// `backend/mock-api` real.
///
/// Cada método consulta uma função configurável (`onLogin`, `onRegister`
/// etc.); quando `null`, lança [StateError] para deixar claro que o teste
/// não configurou o cenário esperado.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.onLogin,
    this.onRegister,
    this.onLoginWithGoogle,
    this.onLogout,
    this.onGetCurrentUser,
    this.onRequestPasswordReset,
    this.onResetPassword,
  });

  final Future<Session> Function({
    required String email,
    required String password,
  })?
  onLogin;
  final Future<Session> Function({
    required String displayName,
    required String email,
    required String password,
  })?
  onRegister;
  final Future<Session> Function({required String idToken})? onLoginWithGoogle;
  final Future<void> Function({
    required String accessToken,
    required String refreshToken,
  })?
  onLogout;
  final Future<User> Function({required String accessToken})? onGetCurrentUser;
  final Future<void> Function({required String email})? onRequestPasswordReset;
  final Future<void> Function({
    required String token,
    required String newPassword,
  })?
  onResetPassword;

  int loginCallCount = 0;
  int logoutCallCount = 0;

  @override
  Future<Session> login({required String email, required String password}) {
    loginCallCount++;
    final callback = onLogin;
    if (callback == null) {
      throw StateError('FakeAuthRepository.login não configurado neste teste.');
    }
    return callback(email: email, password: password);
  }

  @override
  Future<Session> register({
    required String displayName,
    required String email,
    required String password,
  }) {
    final callback = onRegister;
    if (callback == null) {
      throw StateError(
        'FakeAuthRepository.register não configurado neste teste.',
      );
    }
    return callback(displayName: displayName, email: email, password: password);
  }

  @override
  Future<Session> loginWithGoogle({required String idToken}) {
    final callback = onLoginWithGoogle;
    if (callback == null) {
      throw StateError(
        'FakeAuthRepository.loginWithGoogle não configurado neste teste.',
      );
    }
    return callback(idToken: idToken);
  }

  @override
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) {
    logoutCallCount++;
    final callback = onLogout;
    if (callback == null) {
      return Future<void>.value();
    }
    return callback(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<User> getCurrentUser({required String accessToken}) {
    final callback = onGetCurrentUser;
    if (callback == null) {
      throw StateError(
        'FakeAuthRepository.getCurrentUser não configurado neste teste.',
      );
    }
    return callback(accessToken: accessToken);
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    final callback = onRequestPasswordReset;
    if (callback == null) {
      throw StateError(
        'FakeAuthRepository.requestPasswordReset não configurado neste teste.',
      );
    }
    return callback(email: email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    final callback = onResetPassword;
    if (callback == null) {
      throw StateError(
        'FakeAuthRepository.resetPassword não configurado neste teste.',
      );
    }
    return callback(token: token, newPassword: newPassword);
  }
}

/// Fábrica de [Session]/[User] de exemplo para testes.
Session buildSampleSession({String userId = 'usr_1'}) {
  return Session(
    user: User(id: userId, displayName: 'Ana Leitora', status: 'active'),
    accessToken: 'access-$userId',
    refreshToken: 'refresh-$userId',
    expiresAt: DateTime.utc(2026, 1, 1),
  );
}

const invalidCredentialsFailure = ApiUnauthorizedFailure(
  code: 'auth.invalid_credentials',
  message: 'Email ou senha inválidos.',
  statusCode: 401,
);

const accountLockedFailure = ApiUnauthorizedFailure(
  code: 'auth.account_locked',
  message:
      'Conta temporariamente bloqueada por excesso de tentativas inválidas.',
  statusCode: 401,
);

const emailAlreadyUsedFailure = ApiConflictFailure(
  code: 'auth.email_already_used',
  message: 'Este email já está em uso.',
  statusCode: 409,
);

const validationFailure = ApiValidationFailure(
  code: 'validation.failed',
  message: 'Existem campos inválidos.',
  statusCode: 400,
  fieldErrors: {
    'email': ['Informe um email válido.'],
  },
);
