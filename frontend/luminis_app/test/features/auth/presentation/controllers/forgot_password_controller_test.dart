import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('ForgotPasswordController', () {
    test(
      'submit com sucesso marca status success sem tocar a sessão',
      () async {
        final repository = FakeAuthRepository(
          onRequestPasswordReset: ({required email}) async {},
        );
        final container = ProviderContainer.test(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );

        await container
            .read(forgotPasswordControllerProvider.notifier)
            .submit(email: 'ana@email.com');

        expect(
          container.read(forgotPasswordControllerProvider).status,
          FormSubmissionStatus.success,
        );
        expect(
          container.read(sessionControllerProvider),
          isA<SessionUnauthenticated>(),
        );
      },
    );

    test('submit com email inválido expõe fieldErrors', () async {
      final repository = FakeAuthRepository(
        onRequestPasswordReset: ({required email}) async {
          throw validationFailure;
        },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(forgotPasswordControllerProvider.notifier)
          .submit(email: 'invalido');

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.fieldErrors, validationFailure.fieldErrors);
    });
  });
}
