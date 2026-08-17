import '../../../../shared/infrastructure/api_exception.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/entities/book_search_item.dart';
import '../../domain/repositories/book_catalog_repository.dart';
import '../../domain/value_objects/book_search_type.dart';
import '../fixtures/book_catalog_fixtures.dart';

/// Implementação em memória de [BookCatalogRepository].
///
/// Usada apenas como double determinístico em testes unitários. O runtime
/// consome [BookCatalogRepositoryImpl] pela fronteira HTTP do Luminis.
class MockBookCatalogRepository implements BookCatalogRepository {
  MockBookCatalogRepository({List<BookSearchItem>? catalog})
    : _catalog = catalog ?? BookCatalogFixtures.all;

  final List<BookSearchItem> _catalog;

  @override
  Future<BookCatalogSearchResult> search({
    required String query,
    BookSearchType type = BookSearchType.all,
    int page = 1,
    int limit = 20,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery == BookCatalogFixtures.providerUnavailableQuery) {
      throw const ApiServiceUnavailableFailure(
        code: 'catalog.provider_unavailable',
        message: 'O catálogo está temporariamente indisponível.',
        statusCode: 503,
      );
    }

    final matches = _catalog
        .where((item) => _matches(item, normalizedQuery, type))
        .toList(growable: false);

    final start = (page - 1) * limit;
    final pageItems = start >= matches.length
        ? const <BookSearchItem>[]
        : matches.skip(start).take(limit).toList(growable: false);

    return BookCatalogSearchResult(
      items: pageItems,
      page: page,
      limit: limit,
      hasNextPage: start + pageItems.length < matches.length,
    );
  }

  bool _matches(BookSearchItem item, String query, BookSearchType type) {
    if (query.isEmpty) return true;
    final needle = query.toLowerCase();

    return switch (type) {
      BookSearchType.all =>
        item.book.title.toLowerCase().contains(needle) ||
            item.book.authors.any(
              (author) => author.name.toLowerCase().contains(needle),
            ) ||
            item.edition.publisher.name.toLowerCase().contains(needle),
      BookSearchType.title =>
        item.book.title.toLowerCase().contains(needle) ||
            (item.edition.subtitle?.toLowerCase().contains(needle) ?? false),
      BookSearchType.author => item.book.authors.any(
        (author) => author.name.toLowerCase().contains(needle),
      ),
      BookSearchType.publisher =>
        item.edition.publisher.name.toLowerCase().contains(needle),
      BookSearchType.subject => item.book.subjects.any(
        (subject) => subject.name.toLowerCase().contains(needle),
      ),
      BookSearchType.isbn =>
        item.edition.isbn10 == query || item.edition.isbn13 == query,
    };
  }

  @override
  Future<BookDetail> getBookDetail({required String bookId}) async {
    final editions = _catalog
        .where((item) => item.book.id == bookId)
        .toList(growable: false);

    if (editions.isEmpty) {
      throw const ApiNotFoundFailure(
        code: 'catalog.book_not_found',
        message: 'Livro não encontrado.',
        statusCode: 404,
      );
    }

    return BookDetail(
      book: editions.first.book,
      editions: editions.map((item) => item.edition).toList(growable: false),
    );
  }

  @override
  Future<BookSearchItem> searchByIsbn({required String isbn}) async {
    if (isbn == BookCatalogFixtures.providerUnavailableQuery) {
      throw const ApiServiceUnavailableFailure(
        code: 'catalog.provider_unavailable',
        message: 'O catálogo está temporariamente indisponível.',
        statusCode: 503,
      );
    }

    for (final item in _catalog) {
      if (item.edition.isbn10 == isbn || item.edition.isbn13 == isbn) {
        return item;
      }
    }

    throw const ApiNotFoundFailure(
      code: 'catalog.isbn_not_found',
      message: 'Nenhuma edição encontrada para este ISBN.',
      statusCode: 404,
    );
  }
}
