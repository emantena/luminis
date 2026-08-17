import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../data/providers/auth_providers.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';

/// Estado de tela do formulário "esqueci minha senha" (`/auth/forgot-password`).
class ForgotPasswordFormState {
  const ForgotPasswordFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final FormSubmissionStatus status;
  final String? errorMessage;

  /// Erros de campo (`email`) vindos de `validation.failed`.
  final Map<String, List<String>> fieldErrors;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo:
///   `NotifierProvider<ForgotPasswordController, ForgotPasswordFormState>`
///   com `autoDispose`.
/// - Comando: `submit(email: ...)`.
/// - Este fluxo não toca `sessionControllerProvider`: recuperação de senha
///   nunca autentica o usuário (`docs/architecture/backend-contracts.md` —
///   backend não revela se o email existe e não emite sessão aqui).
/// - `status == success` deve levar a UI a uma mensagem neutra
///   ("se o email existir, enviaremos instruções"), nunca confirmando ou
///   negando a existência da conta.
final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<
      ForgotPasswordController,
      ForgotPasswordFormState
    >(ForgotPasswordController.new);

class ForgotPasswordController extends Notifier<ForgotPasswordFormState> {
  @override
  ForgotPasswordFormState build() => const ForgotPasswordFormState();

  Future<void> submit({required String email}) async {
    state = const ForgotPasswordFormState(
      status: FormSubmissionStatus.submitting,
    );
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email: email);
      state = const ForgotPasswordFormState(
        status: FormSubmissionStatus.success,
      );
    } on ApiValidationFailure catch (failure) {
      state = ForgotPasswordFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        fieldErrors: failure.fieldErrors,
      );
    } on ApiFailure catch (failure) {
      state = ForgotPasswordFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const ForgotPasswordFormState();
}
