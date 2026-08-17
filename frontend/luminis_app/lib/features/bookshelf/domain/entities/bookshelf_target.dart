/// Alvo de um [BookshelfItem][item]: uma edição global ou um cadastro local,
/// nunca ambos, conforme "Decisão sobre payload inicial de item de estante"
/// (`docs/architecture/backend-contracts.md`).
///
/// Guarda apenas identificadores — não os objetos `Book`/`Edition`/
/// `UserBookDraft` da feature `books`, para manter `bookshelf` sem duplicar
/// entidades de outra feature (ver relatório desta fatia para a decisão
/// completa sobre exibição/enriquecimento desses dados na presentation).
///
/// [item]: bookshelf_item.dart
sealed class BookshelfTarget {
  const BookshelfTarget();
}

/// Edição global do Catalog (`bookId` + `editionId`).
final class BookshelfBookTarget extends BookshelfTarget {
  const BookshelfBookTarget({required this.bookId, required this.editionId});

  final String bookId;
  final String editionId;

  @override
  bool operator ==(Object other) =>
      other is BookshelfBookTarget &&
      other.bookId == bookId &&
      other.editionId == editionId;

  @override
  int get hashCode => Object.hash(bookId, editionId);

  @override
  String toString() =>
      'BookshelfBookTarget(bookId: $bookId, editionId: $editionId)';
}

/// Cadastro local privado (`userBookDraftId`).
final class BookshelfDraftTarget extends BookshelfTarget {
  const BookshelfDraftTarget({required this.userBookDraftId});

  final String userBookDraftId;

  @override
  bool operator ==(Object other) =>
      other is BookshelfDraftTarget && other.userBookDraftId == userBookDraftId;

  @override
  int get hashCode => userBookDraftId.hashCode;

  @override
  String toString() =>
      'BookshelfDraftTarget(userBookDraftId: $userBookDraftId)';
}
