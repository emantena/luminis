import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import 'session_controller.dart';

/// Estado de tela do formulário de login (`/auth/login`).
///
/// Não guarda a sessão em si — apenas o resultado da submissão do
/// formulário. A sessão fica em `sessionControllerProvider`.
class LoginFormState {
  const LoginFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final FormSubmissionStatus status;

  /// Mensagem para erro não associado a um campo específico (ex.:
  /// `auth.invalid_credentials`, `auth.account_locked`, falha de rede).
  final String? errorMessage;

  /// Erros de campo (`email`, `password`) vindos de `validation.failed`.
  final Map<String, List<String>> fieldErrors;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;

  LoginFormState copyWith({
    FormSubmissionStatus? status,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return LoginFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `NotifierProvider<LoginController, LoginFormState>` com
///   `autoDispose` (estado descartado ao sair de `/auth/login`).
/// - Comando: `submit(email: ..., password: ...)`.
/// - Ler `LoginFormState.status`/`fieldErrors`/`errorMessage` para renderizar
///   loading, erro de campo e erro geral.
/// - Em sucesso (`status == success`), a navegação para o shell autenticado
///   deve reagir a `sessionControllerProvider`, não a este provider.
final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginFormState>(
      LoginController.new,
    );

class LoginController extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  /// Delega autenticação a [SessionController] e traduz a falha em estado
  /// de formulário. Não repete a lógica de criar/guardar a sessão.
  Future<void> submit({required String email, required String password}) async {
    state = const LoginFormState(status: FormSubmissionStatus.submitting);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .loginWithPassword(email: email, password: password);
      state = const LoginFormState(status: FormSubmissionStatus.success);
    } on ApiValidationFailure catch (failure) {
      state = LoginFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        fieldErrors: failure.fieldErrors,
      );
    } on ApiFailure catch (failure) {
      state = LoginFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const LoginFormState();
}
