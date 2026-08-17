import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/no_retry.dart';
import '../../data/providers/bookshelf_providers.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/value_objects/bookshelf_filter.dart';
import '../../domain/value_objects/bookshelf_tags_patch.dart';

/// Provider de estado da Estante (`/bookshelf`).
///
/// **API pública para outros agentes:**
/// - Tipo: `AsyncNotifierProvider<BookshelfController, List<BookshelfItem>>`.
/// - `ref.watch(bookshelfControllerProvider)` retorna
///   `AsyncValue<List<BookshelfItem>>` — tratar `loading`/`data` (vazio
///   quando `value.isEmpty`)/`error`.
/// - `applyFilter(BookshelfFilter)` recarrega a lista com um novo filtro;
///   `controller.filter` expõe o filtro atualmente aplicado.
/// - `refresh()` recarrega com o filtro atual (ex.: pull-to-refresh).
/// - Comandos de mutação (`addBookItem`, `addDraftItem`,
///   `updateReadingStatus`, `updateTags`, `removeItem`) atualizam o
///   repository e, em sucesso, recarregam a lista automaticamente. Eles
///   **relançam** `ApiFailure` em vez de virar `AsyncError` no estado da
///   lista — assim uma falha ao adicionar/alterar um item não substitui a
///   lista inteira por um estado de erro. Telas devem chamar estes métodos
///   através dos controllers de comando desta feature
///   (`AddToBookshelfController`, `BookshelfItemActionsController`), que
///   capturam a falha e expõem estado de formulário
///   `idle/submitting/success/erro`, no mesmo padrão de `LoginController`
///   em `features/auth`.
///
/// `keepAlive` (não é `autoDispose`): a estante deve sobreviver à navegação
/// entre abas do shell autenticado, conforme `references/riverpod-3.md`.
///
/// `retry: noRetry` desliga o retry automático do Riverpod 3.x para erros
/// de `build()` — ver `shared/infrastructure/no_retry.dart`. Sem isso, um
/// `ApiFailure` do repository seria retentado silenciosamente em vez de
/// virar `AsyncError` imediatamente.
final bookshelfControllerProvider =
    AsyncNotifierProvider<BookshelfController, List<BookshelfItem>>(
      BookshelfController.new,
      retry: noRetry,
    );

class BookshelfController extends AsyncNotifier<List<BookshelfItem>> {
  BookshelfFilter _filter = const BookshelfFilter();

  BookshelfFilter get filter => _filter;

  @override
  Future<List<BookshelfItem>> build() => _fetch();

  Future<List<BookshelfItem>> _fetch() async {
    final repository = ref.watch(bookshelfRepositoryProvider);
    final result = await repository.listItems(filter: _filter);
    return result.items;
  }

  Future<void> applyFilter(BookshelfFilter filter) async {
    _filter = filter;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<BookshelfItem>>();
    state = await AsyncValue.guard(_fetch);
  }

  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) async {
    final item = await ref
        .read(bookshelfRepositoryProvider)
        .addBookItem(
          bookId: bookId,
          editionId: editionId,
          readingStatus: readingStatus,
        );
    await refresh();
    return item;
  }

  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) async {
    final item = await ref
        .read(bookshelfRepositoryProvider)
        .addDraftItem(
          userBookDraftId: userBookDraftId,
          readingStatus: readingStatus,
        );
    await refresh();
    return item;
  }

  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  }) async {
    final item = await ref
        .read(bookshelfRepositoryProvider)
        .updateReadingStatus(
          bookshelfItemId: bookshelfItemId,
          readingStatus: readingStatus,
        );
    await refresh();
    return item;
  }

  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  }) async {
    final item = await ref
        .read(bookshelfRepositoryProvider)
        .updateTags(bookshelfItemId: bookshelfItemId, tags: tags);
    await refresh();
    return item;
  }

  Future<void> removeItem({required String bookshelfItemId}) async {
    await ref
        .read(bookshelfRepositoryProvider)
        .removeItem(bookshelfItemId: bookshelfItemId);
    await refresh();
  }
}
