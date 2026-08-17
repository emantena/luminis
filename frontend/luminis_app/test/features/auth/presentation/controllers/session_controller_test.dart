import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('SessionController', () {
    test('inicia desautenticado', () {
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );

      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
    });

    test('login com sucesso autentica e guarda a sessão em memória', () async {
      final session = buildSampleSession();
      final repository = FakeAuthRepository(
        onLogin: ({required email, required password}) async => session,
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      final result = await container
          .read(sessionControllerProvider.notifier)
          .loginWithPassword(email: 'ana@email.com', password: 'senha-forte');

      expect(result, session);
      final state = container.read(sessionControllerProvider);
      expect(state, isA<SessionAuthenticated>());
      expect((state as SessionAuthenticated).session, session);
    });

    test(
      'login com credenciais inválidas termina em SessionError e relança ApiFailure',
      () async {
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            throw invalidCredentialsFailure;
          },
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await expectLater(
          container
              .read(sessionControllerProvider.notifier)
              .loginWithPassword(email: 'ana@email.com', password: 'errada'),
          throwsA(isA<ApiUnauthorizedFailure>()),
        );

        final state = container.read(sessionControllerProvider);
        expect(state, isA<SessionError>());
        expect(
          (state as SessionError).message,
          invalidCredentialsFailure.message,
        );
      },
    );

    test(
      'login com conta bloqueada termina em SessionError com o código correto',
      () async {
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            throw accountLockedFailure;
          },
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await expectLater(
          container
              .read(sessionControllerProvider.notifier)
              .loginWithPassword(email: 'ana@email.com', password: 'x'),
          throwsA(
            isA<ApiUnauthorizedFailure>().having(
              (failure) => failure.code,
              'code',
              'auth.account_locked',
            ),
          ),
        );

        expect(container.read(sessionControllerProvider), isA<SessionError>());
      },
    );

    test(
      'logout limpa a sessão e chama o repository com o token atual',
      () async {
        final session = buildSampleSession();
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async => session,
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        final controller = container.read(sessionControllerProvider.notifier);
        await controller.loginWithPassword(
          email: 'ana@email.com',
          password: 'senha-forte',
        );
        expect(
          container.read(sessionControllerProvider),
          isA<SessionAuthenticated>(),
        );

        await controller.logout();

        expect(
          container.read(sessionControllerProvider),
          isA<SessionUnauthenticated>(),
        );
        expect(repository.logoutCallCount, 1);
      },
    );

    test('logout sem sessão ativa é seguro e não chama o repository', () async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container.read(sessionControllerProvider.notifier).logout();

      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
      expect(repository.logoutCallCount, 0);
    });

    test(
      'logout desautentica localmente mesmo quando a revogação falha no backend',
      () async {
        final session = buildSampleSession();
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async => session,
          onLogout: ({required accessToken, required refreshToken}) async {
            throw const ApiNetworkFailure('Sem conexão.');
          },
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        final controller = container.read(sessionControllerProvider.notifier);
        await controller.loginWithPassword(
          email: 'ana@email.com',
          password: 'senha-forte',
        );

        await expectLater(
          controller.logout(),
          throwsA(isA<ApiNetworkFailure>()),
        );

        expect(
          container.read(sessionControllerProvider),
          isA<SessionUnauthenticated>(),
        );
      },
    );
  });
}
