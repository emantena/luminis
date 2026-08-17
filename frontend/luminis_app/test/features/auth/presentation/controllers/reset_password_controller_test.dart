import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:luminis_app/features/auth/presentation/controllers/session_state.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('ResetPasswordController', () {
    test('submit com sucesso marca status success sem autenticar', () async {
      final repository = FakeAuthRepository(
        onResetPassword: ({required token, required newPassword}) async {},
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(resetPasswordControllerProvider.notifier)
          .submit(token: 'reset-token', newPassword: 'nova-senha-forte');

      expect(
        container.read(resetPasswordControllerProvider).status,
        FormSubmissionStatus.success,
      );
      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
    });

    test('submit com token inválido expõe errorMessage', () async {
      const failure = ApiUnauthorizedFailure(
        code: 'auth.password_reset_token_invalid',
        message: 'Token de redefinição inválido ou expirado.',
        statusCode: 401,
      );
      final repository = FakeAuthRepository(
        onResetPassword: ({required token, required newPassword}) async {
          throw failure;
        },
      );
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(resetPasswordControllerProvider.notifier)
          .submit(token: 'token-expirado', newPassword: 'nova-senha-forte');

      final state = container.read(resetPasswordControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.errorMessage, failure.message);
    });
  });
}
