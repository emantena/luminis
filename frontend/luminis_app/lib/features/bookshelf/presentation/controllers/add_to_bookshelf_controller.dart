import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/reading_status.dart';
import 'bookshelf_controller.dart';

/// Estado de tela do bottom sheet "Adicionar à estante", usado tanto a
/// partir do resultado de busca/detalhe (catálogo) quanto do cadastro local
/// recém-criado.
class AddToBookshelfFormState {
  const AddToBookshelfFormState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
    this.isDuplicate = false,
    this.createdItem,
  });

  final FormSubmissionStatus status;

  /// Mensagem de erro, incluindo a mensagem de `bookshelf.item_already_exists`
  /// quando [isDuplicate] for `true`.
  final String? errorMessage;

  /// `true` quando o erro veio de `ApiConflictFailure`
  /// (`bookshelf.item_already_exists`) — permite a UI oferecer "ver na
  /// estante" em vez de um erro genérico.
  final bool isDuplicate;

  final BookshelfItem? createdItem;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo:
///   `NotifierProvider<AddToBookshelfController, AddToBookshelfFormState>`
///   com `autoDispose`.
/// - Comando: `addFromCatalog(bookId: ..., editionId: ..., readingStatus: ...)`
///   — usado a partir de um resultado de busca ou do detalhe do livro.
/// - Comando: `addFromDraft(userBookDraftId: ..., readingStatus: ...)` —
///   usado logo após `BookDraftController.submit` criar um cadastro local.
/// - Em sucesso, `bookshelfControllerProvider` já foi recarregado
///   internamente (via `BookshelfController.addBookItem`/`addDraftItem`);
///   a tela não precisa chamar `refresh()` manualmente.
/// - `state.isDuplicate == true` sinaliza `bookshelf.item_already_exists`.
final addToBookshelfControllerProvider =
    NotifierProvider.autoDispose<
      AddToBookshelfController,
      AddToBookshelfFormState
    >(AddToBookshelfController.new);

class AddToBookshelfController extends Notifier<AddToBookshelfFormState> {
  @override
  AddToBookshelfFormState build() => const AddToBookshelfFormState();

  Future<void> addFromCatalog({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) {
    return _submit(
      () => ref
          .read(bookshelfControllerProvider.notifier)
          .addBookItem(
            bookId: bookId,
            editionId: editionId,
            readingStatus: readingStatus,
          ),
    );
  }

  Future<void> addFromDraft({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) {
    return _submit(
      () => ref
          .read(bookshelfControllerProvider.notifier)
          .addDraftItem(
            userBookDraftId: userBookDraftId,
            readingStatus: readingStatus,
          ),
    );
  }

  Future<void> _submit(Future<BookshelfItem> Function() action) async {
    state = const AddToBookshelfFormState(
      status: FormSubmissionStatus.submitting,
    );
    try {
      final item = await action();
      state = AddToBookshelfFormState(
        status: FormSubmissionStatus.success,
        createdItem: item,
      );
    } on ApiConflictFailure catch (failure) {
      state = AddToBookshelfFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
        isDuplicate: true,
      );
    } on ApiFailure catch (failure) {
      state = AddToBookshelfFormState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const AddToBookshelfFormState();
}
