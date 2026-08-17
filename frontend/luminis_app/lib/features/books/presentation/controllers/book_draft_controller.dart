import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import '../../data/providers/book_providers.dart';
import '../../domain/entities/user_book_draft.dart';

/// Estado de tela do formulário de cadastro local (`/book-drafts/new`).
class BookDraftFormState {
  const BookDraftFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
    this.createdDraft,
  });

  final FormSubmissionStatus status;

  /// Mensagem para erro não associado a campo (ex.: falha de rede).
  final String? errorMessage;

  /// Erros de campo (`title`) vindos de `validation.failed`.
  final Map<String, List<String>> fieldErrors;

  /// Draft criado quando `status == success`. A tela deve usar `id` para
  /// oferecer "adicionar à estante" via
  /// `addToBookshelfControllerProvider.addFromDraft`
  /// (`features/bookshelf/presentation/controllers/add_to_bookshelf_controller.dart`).
  final UserBookDraft? createdDraft;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `NotifierProvider<BookDraftController, BookDraftFormState>` com
///   `autoDispose`.
/// - Comando: `submit(title: ..., authors: ..., edition: ...)`. Título e ao
///   menos um autor são obrigatórios; `edition` é opcional.
/// - Em sucesso (`status == success`), `createdDraft` traz o `id` a ser
///   usado por `AddToBookshelfController.addFromDraft`.
final bookDraftControllerProvider =
    NotifierProvider.autoDispose<BookDraftController, BookDraftFormState>(
      BookDraftController.new,
    );

class BookDraftController extends Notifier<BookDraftFormState> {
  @override
  BookDraftFormState build() => const BookDraftFormState();

  Future<void> submit({
    required String title,
    List<String> authors = const [],
    UserBookDraftEdition? edition,
  }) async {
    final normalizedAuthors = authors
        .map((author) => author.trim())
        .where((author) => author.isNotEmpty)
        .toList(growable: false);
    final fieldErrors = <String, List<String>>{
      if (title.trim().isEmpty) 'title': ['Informe um título.'],
      if (normalizedAuthors.isEmpty) 'authors': ['Informe ao menos um autor.'],
    };
    if (fieldErrors.isNotEmpty) {
      state = BookDraftFormState(
        status: FormSubmissionStatus.error,
        errorMessage: 'Existem campos inválidos.',
        fieldErrors: fieldErrors,
      );
      return;
    }

    state = const BookDraftFormState(status: FormSubmissionStatus.submitting);
    try {
      final draft = await ref
          .read(bookDraftRepositoryProvider)
          .createDraft(
            title: title.trim(),
            authors: normalizedAuthors,
            edition: edition,
          );
      state = BookDraftFormState(
        status: FormSubmissionStatus.success,
        createdDraft: draft,
      );
    } on ApiValidationFailure catch (failure) {
      state = BookDraftFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        fieldErrors: failure.fieldErrors,
      );
    } on ApiFailure catch (failure) {
      state = BookDraftFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const BookDraftFormState();
}
