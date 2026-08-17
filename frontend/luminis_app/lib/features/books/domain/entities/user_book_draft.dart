/// Dados de edição de um cadastro local (`user_book_drafts.edition_data`),
/// conforme o payload de `POST /api/book-drafts`.
///
/// Distinto de [Edition][edition] (obra global do Catalog): aqui `publisher`
/// é apenas o nome digitado pelo usuário (`String?`), não uma entidade
/// `Publisher` normalizada — o draft não passa por curadoria/normalização.
///
/// [edition]: ../entities/edition.dart
class UserBookDraftEdition {
  const UserBookDraftEdition({
    this.publisher,
    this.publishedYear,
    this.language,
    this.format,
    this.pageCount,
    this.isbn10,
    this.isbn13,
    this.coverUrl,
  });

  final String? publisher;
  final int? publishedYear;
  final String? language;
  final String? format;
  final int? pageCount;
  final String? isbn10;
  final String? isbn13;
  final String? coverUrl;

  @override
  bool operator ==(Object other) {
    return other is UserBookDraftEdition &&
        other.publisher == publisher &&
        other.publishedYear == publishedYear &&
        other.language == language &&
        other.format == format &&
        other.pageCount == pageCount &&
        other.isbn10 == isbn10 &&
        other.isbn13 == isbn13 &&
        other.coverUrl == coverUrl;
  }

  @override
  int get hashCode => Object.hash(
    publisher,
    publishedYear,
    language,
    format,
    pageCount,
    isbn10,
    isbn13,
    coverUrl,
  );
}

/// Cadastro local privado (`docs/architecture/domain-model.md` ->
/// `UserBookDraft`), criado por `POST /api/book-drafts`.
///
/// Pertence ao usuário que o criou; não é promovido a `Book`/`Edition`
/// globais sem curadoria (`docs/architecture/backend-contracts.md` —
/// "Decisão sobre cadastro local e curadoria").
class UserBookDraft {
  const UserBookDraft({
    required this.id,
    required this.title,
    required this.createdAt,
    this.authors = const [],
    this.edition,
    this.status = 'local',
  });

  final String id;
  final String title;
  final List<String> authors;
  final UserBookDraftEdition? edition;

  /// Valor bruto vindo do backend (`local` no MVP). Mantido como `String`
  /// em vez de enum de um único valor, na mesma linha de `User.status`.
  final String status;

  final DateTime createdAt;

  @override
  String toString() => 'UserBookDraft(id: $id, title: $title)';
}
