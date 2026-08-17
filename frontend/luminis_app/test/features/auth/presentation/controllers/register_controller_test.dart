import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/register_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('RegisterController', () {
    test(
      'submit com sucesso autentica a sessão e marca status success',
      () async {
        final session = buildSampleSession();
        final repository = FakeAuthRepository(
          onRegister:
              ({
                required displayName,
                required email,
                required password,
              }) async => session,
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await container
            .read(registerControllerProvider.notifier)
            .submit(
              displayName: 'Ana Leitora',
              email: 'ana@email.com',
              password: 'senha-forte',
            );

        expect(
          container.read(registerControllerProvider).status,
          FormSubmissionStatus.success,
        );
        expect(
          container.read(sessionControllerProvider),
          isA<SessionAuthenticated>(),
        );
      },
    );

    test('submit com email já usado expõe errorMessage do conflito', () async {
      final repository = FakeAuthRepository(
        onRegister:
            ({required displayName, required email, required password}) async {
              throw emailAlreadyUsedFailure;
            },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(registerControllerProvider.notifier)
          .submit(
            displayName: 'Ana Leitora',
            email: 'ana@email.com',
            password: 'senha-forte',
          );

      final state = container.read(registerControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.errorMessage, emailAlreadyUsedFailure.message);
      expect(
        container.read(sessionControllerProvider),
        isNot(isA<SessionAuthenticated>()),
      );
    });

    test('submit com validation.failed expõe fieldErrors por campo', () async {
      final repository = FakeAuthRepository(
        onRegister:
            ({required displayName, required email, required password}) async {
              throw validationFailure;
            },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(registerControllerProvider.notifier)
          .submit(displayName: '', email: 'invalido', password: '123');

      final state = container.read(registerControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.fieldErrors, validationFailure.fieldErrors);
    });
  });
}
