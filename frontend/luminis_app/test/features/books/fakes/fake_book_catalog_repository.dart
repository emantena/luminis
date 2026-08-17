import 'package:luminis_app/features/books/domain/entities/book_detail.dart';
import 'package:luminis_app/features/books/domain/entities/book_search_item.dart';
import 'package:luminis_app/features/books/domain/repositories/book_catalog_repository.dart';
import 'package:luminis_app/features/books/domain/value_objects/book_search_type.dart';

/// Fake de [BookCatalogRepository] para testes de controllers/providers,
/// seguindo o mesmo padrão de `test/features/auth/fakes/fake_auth_repository.dart`.
class FakeBookCatalogRepository implements BookCatalogRepository {
  FakeBookCatalogRepository({
    this.onSearch,
    this.onGetBookDetail,
    this.onSearchByIsbn,
  });

  final Future<BookCatalogSearchResult> Function({
    required String query,
    BookSearchType type,
    int page,
    int limit,
  })?
  onSearch;
  final Future<BookDetail> Function({required String bookId})? onGetBookDetail;
  final Future<BookSearchItem> Function({required String isbn})? onSearchByIsbn;

  int searchCallCount = 0;

  @override
  Future<BookCatalogSearchResult> search({
    required String query,
    BookSearchType type = BookSearchType.all,
    int page = 1,
    int limit = 20,
  }) {
    searchCallCount++;
    final callback = onSearch;
    if (callback == null) {
      throw StateError('FakeBookCatalogRepository.search não configurado.');
    }
    return callback(query: query, type: type, page: page, limit: limit);
  }

  @override
  Future<BookDetail> getBookDetail({required String bookId}) {
    final callback = onGetBookDetail;
    if (callback == null) {
      throw StateError(
        'FakeBookCatalogRepository.getBookDetail não configurado.',
      );
    }
    return callback(bookId: bookId);
  }

  @override
  Future<BookSearchItem> searchByIsbn({required String isbn}) {
    final callback = onSearchByIsbn;
    if (callback == null) {
      throw StateError(
        'FakeBookCatalogRepository.searchByIsbn não configurado.',
      );
    }
    return callback(isbn: isbn);
  }
}
