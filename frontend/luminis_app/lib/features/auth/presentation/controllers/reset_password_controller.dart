import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../data/providers/auth_providers.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';

/// Estado de tela do formulário de redefinição de senha
/// (`/auth/reset-password`, aberta a partir do link/token de recuperação).
class ResetPasswordFormState {
  const ResetPasswordFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final FormSubmissionStatus status;

  /// Mensagem para erro não associado a campo, incluindo
  /// `auth.password_reset_token_invalid` (token inválido/expirado).
  final String? errorMessage;

  /// Erros de campo (`newPassword`) vindos de `validation.failed`.
  final Map<String, List<String>> fieldErrors;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo:
///   `NotifierProvider<ResetPasswordController, ResetPasswordFormState>`
///   com `autoDispose`.
/// - Comando: `submit(token: ..., newPassword: ...)`. `token` deve vir da
///   rota (`/auth/reset-password`), não é digitado pelo usuário.
/// - Este fluxo não toca `sessionControllerProvider`: redefinir senha não
///   autentica automaticamente. Após `status == success`, a UI deve levar o
///   usuário para `/auth/login` para autenticar com a nova senha.
final resetPasswordControllerProvider =
    NotifierProvider.autoDispose<
      ResetPasswordController,
      ResetPasswordFormState
    >(ResetPasswordController.new);

class ResetPasswordController extends Notifier<ResetPasswordFormState> {
  @override
  ResetPasswordFormState build() => const ResetPasswordFormState();

  Future<void> submit({
    required String token,
    required String newPassword,
  }) async {
    state = const ResetPasswordFormState(
      status: FormSubmissionStatus.submitting,
    );
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(token: token, newPassword: newPassword);
      state = const ResetPasswordFormState(
        status: FormSubmissionStatus.success,
      );
    } on ApiValidationFailure catch (failure) {
      state = ResetPasswordFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        fieldErrors: failure.fieldErrors,
      );
    } on ApiFailure catch (failure) {
      state = ResetPasswordFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const ResetPasswordFormState();
}
