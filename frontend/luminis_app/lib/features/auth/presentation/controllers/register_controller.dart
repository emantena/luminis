import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import 'session_controller.dart';

/// Estado de tela do formulário de cadastro (`/auth/register`).
class RegisterFormState {
  const RegisterFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final FormSubmissionStatus status;

  /// Mensagem para erro não associado a campo (ex.:
  /// `auth.email_already_used`, falha de rede).
  final String? errorMessage;

  /// Erros de campo (`displayName`, `email`, `password`) vindos de
  /// `validation.failed`.
  final Map<String, List<String>> fieldErrors;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `NotifierProvider<RegisterController, RegisterFormState>` com
///   `autoDispose`.
/// - Comando: `submit(displayName: ..., email: ..., password: ...)`.
/// - `auth.email_already_used` chega como `errorMessage` (não como erro de
///   campo `email`), pois o backend retorna `409 Conflict`, não
///   `validation.failed`. A UI deve exibi-lo perto do campo `email` mesmo
///   assim, se preferir — a decisão de layout é da presentation.
final registerControllerProvider =
    NotifierProvider.autoDispose<RegisterController, RegisterFormState>(
      RegisterController.new,
    );

class RegisterController extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  Future<void> submit({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = const RegisterFormState(status: FormSubmissionStatus.submitting);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .register(displayName: displayName, email: email, password: password);
      state = const RegisterFormState(status: FormSubmissionStatus.success);
    } on ApiValidationFailure catch (failure) {
      state = RegisterFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        fieldErrors: failure.fieldErrors,
      );
    } on ApiFailure catch (failure) {
      state = RegisterFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const RegisterFormState();
}
