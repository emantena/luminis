import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/logout_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('LogoutController', () {
    test('submit limpa a sessão autenticada e marca status success', () async {
      final session = buildSampleSession();
      final repository = FakeAuthRepository(
        onLogin: ({required email, required password}) async => session,
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      await container
          .read(sessionControllerProvider.notifier)
          .loginWithPassword(email: 'ana@email.com', password: 'senha-forte');

      await container.read(logoutControllerProvider.notifier).submit();

      expect(
        container.read(logoutControllerProvider).status,
        FormSubmissionStatus.success,
      );
      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
      expect(repository.logoutCallCount, 1);
    });

    test(
      'submit expõe erro quando a revogação falha, mas sessão local já foi limpa',
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
        await container
            .read(sessionControllerProvider.notifier)
            .loginWithPassword(email: 'ana@email.com', password: 'senha-forte');

        await container.read(logoutControllerProvider.notifier).submit();

        expect(
          container.read(logoutControllerProvider).status,
          FormSubmissionStatus.error,
        );
        expect(
          container.read(sessionControllerProvider),
          isA<SessionUnauthenticated>(),
        );
      },
    );
  });
}
