import '../entities/book_detail.dart';
import '../entities/book_search_item.dart';
import '../value_objects/book_search_type.dart';

/// Contrato do módulo Catalog consumido pela feature `books`
/// (`docs/architecture/backend-contracts.md`).
///
/// Implementações HTTP e doubles em memória para teste devem respeitar
/// exatamente esta interface. Widgets nunca devem instanciar uma implementação diretamente — apenas via
/// `bookCatalogRepositoryProvider` (`data/providers/book_providers.dart`).
///
/// Todos os métodos lançam `ApiFailure`
/// (`shared/infrastructure/api_exception.dart`) em caso de erro, mesmo na
/// implementação mock em memória — isso mantém o mesmo tratamento de erro
/// em controllers independente de qual implementação está injetada.
abstract interface class BookCatalogRepository {
  /// `GET /api/books/search`.
  ///
  /// `q` (aqui `query`) é obrigatório e não vazio; `type` assume `all`
  /// quando omitido, conforme "Decisão sobre tipo de busca".
  ///
  /// Lança `ApiServiceUnavailableFailure` (`catalog.provider_unavailable`)
  /// quando não houver resultado interno e provedores externos falharem, ou
  /// `ApiValidationFailure` (`validation.failed`) para parâmetros inválidos.
  Future<BookCatalogSearchResult> search({
    required String query,
    BookSearchType type = BookSearchType.all,
    int page = 1,
    int limit = 20,
  });

  /// `GET /api/books/{bookId}`.
  ///
  /// Lança `ApiNotFoundFailure` (`catalog.book_not_found`) quando a obra não
  /// existir, ou `ApiValidationFailure` (`validation.failed`) para
  /// `bookId` malformado.
  Future<BookDetail> getBookDetail({required String bookId});

  /// `GET /api/books/isbn/{isbn}`.
  ///
  /// Lança `ApiNotFoundFailure` (`catalog.isbn_not_found`) quando a consulta
  /// for concluída sem correspondência, `ApiServiceUnavailableFailure`
  /// (`catalog.provider_unavailable`) quando não houver resultado interno e
  /// todos os provedores aplicáveis falharem, ou `ApiValidationFailure`
  /// (`validation.failed`) para ISBN inválido.
  Future<BookSearchItem> searchByIsbn({required String isbn});
}
