import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../data/providers/book_providers.dart';
import '../../domain/value_objects/book_search_type.dart';
import '../state/book_search_state.dart';

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `NotifierProvider<BookSearchController, BookSearchState>` com
///   `autoDispose` (estado descartado ao sair de `/search`).
/// - Comando: `search(query: ..., type: ...)`. `type` é opcional
///   (`BookSearchType.all` por padrão).
/// - Comando: `loadMore()` — busca a próxima página e concatena aos itens já
///   carregados; sem efeito quando o estado atual não é `BookSearchData`
///   com `hasNextPage == true`.
/// - Comando: `reset()` — volta para `BookSearchIdle` (ex.: ao limpar o
///   campo de busca).
/// - Ler `BookSearchState` (`presentation/state/book_search_state.dart`)
///   para renderizar idle/loading/dados/vazio/erro.
final bookSearchControllerProvider =
    NotifierProvider.autoDispose<BookSearchController, BookSearchState>(
      BookSearchController.new,
    );

class BookSearchController extends Notifier<BookSearchState> {
  String _lastQuery = '';
  BookSearchType _lastType = BookSearchType.all;

  @override
  BookSearchState build() => const BookSearchIdle();

  /// `GET /api/books/search`. Query vazia (após `trim`) volta para
  /// [BookSearchIdle] em vez de chamar o repository, pois `q` é obrigatório
  /// no contrato do Catalog.
  Future<void> search({
    required String query,
    BookSearchType type = BookSearchType.all,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      state = const BookSearchIdle();
      return;
    }

    _lastQuery = trimmedQuery;
    _lastType = type;
    state = const BookSearchLoading();

    try {
      final repository = ref.read(bookCatalogRepositoryProvider);
      final result = await repository.search(query: trimmedQuery, type: type);
      state = result.items.isEmpty
          ? const BookSearchEmpty()
          : BookSearchData(
              items: result.items,
              page: result.page,
              hasNextPage: result.hasNextPage,
            );
    } on ApiFailure catch (failure) {
      state = BookSearchError(failure.message);
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! BookSearchData || !current.hasNextPage) return;

    try {
      final repository = ref.read(bookCatalogRepositoryProvider);
      final result = await repository.search(
        query: _lastQuery,
        type: _lastType,
        page: current.page + 1,
      );
      state = BookSearchData(
        items: [...current.items, ...result.items],
        page: result.page,
        hasNextPage: result.hasNextPage,
      );
    } on ApiFailure catch (failure) {
      state = BookSearchError(failure.message);
    }
  }

  void reset() => state = const BookSearchIdle();
}
