import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/presentation/state/form_submission_status.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/value_objects/bookshelf_tags_patch.dart';
import 'bookshelf_controller.dart';

/// Estado de tela de uma ação pontual sobre um item da estante (alterar
/// status, alterar etiquetas ou remover).
class BookshelfItemActionState {
  const BookshelfItemActionState({
    this.status = FormSubmissionStatus.idle,
    this.errorMessage,
  });

  final FormSubmissionStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  bool get isSuccess => status == FormSubmissionStatus.success;
}

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo:
///   `NotifierProvider<BookshelfItemActionsController, BookshelfItemActionState>`
///   com `autoDispose.family<String>`, parametrizado por `bookshelfItemId`.
/// - Uso: um item por vez (ex.: bottom sheet "alterar status"/"editar
///   etiquetas" de uma linha da estante) —
///   `ref.watch(bookshelfItemActionsControllerProvider(item.id))`.
/// - Comandos: `changeReadingStatus(ReadingStatus)`,
///   `changeTags(BookshelfTagsPatch)`, `remove()`.
/// - Em sucesso, `bookshelfControllerProvider` já foi recarregado
///   internamente; a tela não precisa chamar `refresh()` manualmente.
final bookshelfItemActionsControllerProvider = NotifierProvider.autoDispose
    .family<BookshelfItemActionsController, BookshelfItemActionState, String>(
      BookshelfItemActionsController.new,
    );

class BookshelfItemActionsController
    extends Notifier<BookshelfItemActionState> {
  BookshelfItemActionsController(this.bookshelfItemId);

  final String bookshelfItemId;

  @override
  BookshelfItemActionState build() => const BookshelfItemActionState();

  Future<void> changeReadingStatus(ReadingStatus readingStatus) {
    return _run(
      () => ref
          .read(bookshelfControllerProvider.notifier)
          .updateReadingStatus(
            bookshelfItemId: bookshelfItemId,
            readingStatus: readingStatus,
          ),
    );
  }

  Future<void> changeTags(BookshelfTagsPatch tags) {
    return _run(
      () => ref
          .read(bookshelfControllerProvider.notifier)
          .updateTags(bookshelfItemId: bookshelfItemId, tags: tags),
    );
  }

  Future<void> remove() {
    return _run(
      () => ref
          .read(bookshelfControllerProvider.notifier)
          .removeItem(bookshelfItemId: bookshelfItemId),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const BookshelfItemActionState(
      status: FormSubmissionStatus.submitting,
    );
    try {
      await action();
      state = const BookshelfItemActionState(
        status: FormSubmissionStatus.success,
      );
    } on ApiFailure catch (failure) {
      state = BookshelfItemActionState(
        status: FormSubmissionStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  void reset() => state = const BookshelfItemActionState();
}
