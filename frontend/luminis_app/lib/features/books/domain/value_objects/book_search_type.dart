/// Valores de `type` aceitos por `GET /api/books/search`, conforme
/// "Decisão sobre tipo de busca" (`docs/architecture/backend-contracts.md`).
enum BookSearchType { all, title, author, publisher, subject, isbn }

/// Conversão para/de `type` no formato usado pela fronteira HTTP. Mantida à
/// parte do enum para não acoplar o domínio ao formato de wire — uma futura
/// implementação HTTP de `BookCatalogRepository` usa esta extensão.
extension BookSearchTypeWire on BookSearchType {
  String get wireValue => switch (this) {
    BookSearchType.all => 'all',
    BookSearchType.title => 'title',
    BookSearchType.author => 'author',
    BookSearchType.publisher => 'publisher',
    BookSearchType.subject => 'subject',
    BookSearchType.isbn => 'isbn',
  };

  static BookSearchType fromWire(String value) => switch (value) {
    'all' => BookSearchType.all,
    'title' => BookSearchType.title,
    'author' => BookSearchType.author,
    'publisher' => BookSearchType.publisher,
    'subject' => BookSearchType.subject,
    'isbn' => BookSearchType.isbn,
    _ => throw ArgumentError('type de busca desconhecido: $value'),
  };
}
