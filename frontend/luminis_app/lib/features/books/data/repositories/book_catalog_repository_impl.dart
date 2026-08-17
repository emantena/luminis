import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/entities/book_search_item.dart';
import '../../domain/repositories/book_catalog_repository.dart';
import '../../domain/value_objects/book_search_type.dart';
import '../mappers/book_mapper.dart';

/// Implementação HTTP do Catalog na fronteira própria do Luminis.
class BookCatalogRepositoryImpl implements BookCatalogRepository {
  BookCatalogRepositoryImpl(this._apiClient, {this.bearerToken});

  final ApiClient _apiClient;
  final String? bearerToken;

  @override
  Future<BookCatalogSearchResult> search({
    required String query,
    BookSearchType type = BookSearchType.all,
    int page = 1,
    int limit = 20,
  }) async {
    final parameters = Uri(
      queryParameters: {
        'q': query,
        'type': type.wireValue,
        'page': '$page',
        'limit': '$limit',
      },
    ).query;
    final response = await _apiClient.get(
      '/books/search?$parameters',
      bearerToken: bearerToken,
    );
    return BookMapper.searchResultFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookDetail> getBookDetail({required String bookId}) async {
    final response = await _apiClient.get(
      '/books/${Uri.encodeComponent(bookId)}',
      bearerToken: bearerToken,
    );
    return BookMapper.detailFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookSearchItem> searchByIsbn({required String isbn}) async {
    final response = await _apiClient.get(
      '/books/isbn/${Uri.encodeComponent(isbn)}',
      bearerToken: bearerToken,
    );
    return BookMapper.searchItemFromJson(response as Map<String, dynamic>);
  }
}
