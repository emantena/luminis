import 'bookshelf_tags.dart';
import 'bookshelf_item_summary.dart';
import 'bookshelf_target.dart';
import 'reading_status.dart';

/// Vínculo ativo entre o usuário autenticado e uma edição global ou um
/// cadastro local (`docs/architecture/domain-model.md` —
/// `BookshelfItem`). Referencia `Book`/`Edition`/`UserBookDraft` apenas por
/// id, via [target]; não duplica as entidades da feature `books`.
class BookshelfItem {
  const BookshelfItem({
    required this.id,
    required this.target,
    required this.readingStatus,
    required this.addedAt,
    required this.updatedAt,
    this.tags = const BookshelfTags(),
    this.summary,
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final BookshelfTarget target;
  final ReadingStatus readingStatus;
  final BookshelfTags tags;

  /// Resumo pronto para a lista retornado pelo contrato de Bookshelf.
  final BookshelfItemSummary? summary;

  final DateTime addedAt;
  final DateTime updatedAt;

  /// Preenchido quando `readingStatus` for/foi `reading` ou `rereading`.
  final DateTime? startedAt;

  /// Preenchido quando `readingStatus` for `read` ou `abandoned`.
  final DateTime? finishedAt;

  BookshelfItem copyWith({
    ReadingStatus? readingStatus,
    BookshelfTags? tags,
    BookshelfItemSummary? summary,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return BookshelfItem(
      id: id,
      target: target,
      readingStatus: readingStatus ?? this.readingStatus,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      addedAt: addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  String toString() => 'BookshelfItem(id: $id, readingStatus: $readingStatus)';
}

/// Envelope paginado de `GET /api/bookshelf-items`. Sem `total`, mesma
/// decisão do Catalog.
class BookshelfListResult {
  const BookshelfListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasNextPage,
  });

  final List<BookshelfItem> items;
  final int page;
  final int limit;
  final bool hasNextPage;
}
