import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import 'session_controller.dart';

/// Estado de tela da ação de logout (ex.: item de menu em `/profile`).
///
/// Não tem `fieldErrors` — logout não é um formulário com campos, mas
/// segue o mesmo status compartilhado (`idle/submitting/success/erro`) para
/// consistência com os demais controllers de `auth`.
class LogoutFormState {
  const LogoutFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
  });

  final FormSubmissionStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `NotifierProvider<LogoutController, LogoutFormState>` com
///   `autoDispose`.
/// - Comando: `submit()`.
/// - A navegação de volta para `/auth/welcome` deve reagir a
///   `sessionControllerProvider` (que este controller sempre deixa em
///   `SessionUnauthenticated` ao final, mesmo em erro de rede — ver
///   `SessionController.logout`), não ao `status` deste provider.
/// - `status == error` serve apenas para a UI avisar que a revogação no
///   servidor pode não ter sido confirmada; a sessão local já foi encerrada.
final logoutControllerProvider =
    NotifierProvider.autoDispose<LogoutController, LogoutFormState>(
      LogoutController.new,
    );

class LogoutController extends Notifier<LogoutFormState> {
  @override
  LogoutFormState build() => const LogoutFormState();

  Future<void> submit() async {
    state = const LogoutFormState(status: FormSubmissionStatus.submitting);
    try {
      await ref.read(sessionControllerProvider.notifier).logout();
      state = const LogoutFormState(status: FormSubmissionStatus.success);
    } on ApiFailure catch (failure) {
      state = LogoutFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }
}
