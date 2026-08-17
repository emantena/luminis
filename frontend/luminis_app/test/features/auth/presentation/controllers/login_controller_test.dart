import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('LoginController', () {
    test('estado inicial é idle', () {
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );

      expect(
        container.read(loginControllerProvider).status,
        FormSubmissionStatus.idle,
      );
    });

    test(
      'submit com sucesso autentica a sessão e marca status success',
      () async {
        final session = buildSampleSession();
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async => session,
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await container
            .read(loginControllerProvider.notifier)
            .submit(email: 'ana@email.com', password: 'senha-forte');

        expect(
          container.read(loginControllerProvider).status,
          FormSubmissionStatus.success,
        );
        expect(
          container.read(sessionControllerProvider),
          isA<SessionAuthenticated>(),
        );
      },
    );

    test(
      'submit com credenciais inválidas expõe errorMessage sem derrubar o app',
      () async {
        final repository = FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            throw invalidCredentialsFailure;
          },
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await container
            .read(loginControllerProvider.notifier)
            .submit(email: 'ana@email.com', password: 'errada');

        final state = container.read(loginControllerProvider);
        expect(state.status, FormSubmissionStatus.error);
        expect(state.errorMessage, invalidCredentialsFailure.message);
        expect(state.fieldErrors, isEmpty);
      },
    );

    test('submit com validation.failed expõe fieldErrors', () async {
      final repository = FakeAuthRepository(
        onLogin: ({required email, required password}) async {
          throw validationFailure;
        },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(loginControllerProvider.notifier)
          .submit(email: 'invalido', password: '');

      final state = container.read(loginControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.fieldErrors, validationFailure.fieldErrors);
    });

    test('reset volta o formulário para idle', () async {
      final repository = FakeAuthRepository(
        onLogin: ({required email, required password}) async {
          throw invalidCredentialsFailure;
        },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      final controller = container.read(loginControllerProvider.notifier);
      await controller.submit(email: 'ana@email.com', password: 'errada');
      expect(
        container.read(loginControllerProvider).status,
        FormSubmissionStatus.error,
      );

      controller.reset();

      expect(
        container.read(loginControllerProvider).status,
        FormSubmissionStatus.idle,
      );
    });
  });
}
