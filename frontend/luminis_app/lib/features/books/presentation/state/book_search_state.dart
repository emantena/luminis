import '../../domain/entities/book_search_item.dart';

/// Estado de tela da busca de livros (`/search`), exposto por
/// `bookSearchControllerProvider`.
///
/// `sealed` para permitir `switch` exaustivo na tela, seguindo o mesmo
/// padrão de `SessionState` (`features/auth/presentation/controllers/session_state.dart`).
/// Distinto de `AsyncValue` porque a tela precisa de um estado "idle"
/// anterior à primeira busca (antes do usuário digitar/confirmar algo),
/// que `AsyncValue` não representa nativamente.
sealed class BookSearchState {
  const BookSearchState();
}

/// Nenhuma busca foi disparada ainda (tela recém-aberta ou campo limpo).
final class BookSearchIdle extends BookSearchState {
  const BookSearchIdle();
}

final class BookSearchLoading extends BookSearchState {
  const BookSearchLoading();
}

/// Busca concluída com ao menos um resultado.
final class BookSearchData extends BookSearchState {
  const BookSearchData({
    required this.items,
    required this.page,
    required this.hasNextPage,
  });

  final List<BookSearchItem> items;
  final int page;
  final bool hasNextPage;
}

/// Busca concluída sem resultados (`items: []`), distinto de [BookSearchIdle]
/// para a tela poder mostrar uma mensagem de "nenhum resultado" em vez do
/// estado inicial.
final class BookSearchEmpty extends BookSearchState {
  const BookSearchEmpty();
}

final class BookSearchError extends BookSearchState {
  const BookSearchError(this.message);

  final String message;
}
