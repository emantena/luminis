import 'book.dart';
import 'edition.dart';

/// Um item de `GET /api/books/search` ou o resultado de
/// `GET /api/books/isbn/{isbn}`.
///
/// Conforme a decisão "representação dos resultados"
/// (`docs/architecture/backend-contracts.md`), cada item representa uma
/// [Edition] com a [Book] associada — sem `defaultEdition`/`displayEdition`.
/// A mesma [Book] pode aparecer em mais de um item quando houver edições
/// distintas relevantes para a busca.
class BookSearchItem {
  const BookSearchItem({required this.book, required this.edition});

  final Book book;
  final Edition edition;

  @override
  bool operator ==(Object other) =>
      other is BookSearchItem && other.book == book && other.edition == edition;

  @override
  int get hashCode => Object.hash(book, edition);

  @override
  String toString() =>
      'BookSearchItem(book: ${book.id}, edition: ${edition.id})';
}

/// Envelope paginado de `GET /api/books/search`.
///
/// Sem `total`, conforme "Decisão sobre paginação na resposta" — a
/// combinação de resultados internos/externos pode tornar esse valor caro
/// ou pouco confiável.
class BookCatalogSearchResult {
  const BookCatalogSearchResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasNextPage,
  });

  final List<BookSearchItem> items;
  final int page;
  final int limit;
  final bool hasNextPage;
}
