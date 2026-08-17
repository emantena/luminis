import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/bookshelf_item_summary.dart';
import '../../domain/entities/bookshelf_tags.dart';
import '../../domain/entities/bookshelf_target.dart';
import '../../domain/entities/reading_status.dart';

/// Conversões wire -> domínio das rotas do Bookshelf.
abstract final class BookshelfMapper {
  static BookshelfListResult listResultFromJson(Map<String, dynamic> json) {
    return BookshelfListResult(
      items: (json['items'] as List<dynamic>)
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }

  static BookshelfItem itemFromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? const {};
    return BookshelfItem(
      id: json['id'] as String,
      target: targetFromJson(json['target'] as Map<String, dynamic>),
      readingStatus: ReadingStatusWire.fromWire(
        json['readingStatus'] as String,
      ),
      tags: BookshelfTags(
        isFavorite: tags['isFavorite'] as bool? ?? false,
        isOwned: tags['isOwned'] as bool? ?? false,
        isWished: tags['isWished'] as bool? ?? false,
        isBorrowed: tags['isBorrowed'] as bool? ?? false,
        isLent: tags['isLent'] as bool? ?? false,
        isEbook: tags['isEbook'] as bool? ?? false,
        isAudiobook: tags['isAudiobook'] as bool? ?? false,
      ),
      summary: _summaryFromJson(json),
      addedAt: DateTime.parse(json['addedAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
      startedAt: _dateTimeOrNull(json['startedAt']),
      finishedAt: _dateTimeOrNull(json['finishedAt']),
    );
  }

  static BookshelfItemSummary? _summaryFromJson(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>?;
    final edition = json['edition'] as Map<String, dynamic>?;
    if (book != null && edition != null) {
      return BookshelfItemSummary(
        title: book['title'] as String,
        authors: (book['authors'] as List<dynamic>)
            .map((author) => (author as Map<String, dynamic>)['name'] as String)
            .toList(growable: false),
        coverUrl: edition['coverUrl'] as String?,
        language: edition['language'] as String?,
        format: edition['format'] as String?,
        pageCount: edition['pageCount'] as int?,
      );
    }

    final draft = json['draft'] as Map<String, dynamic>?;
    if (draft == null) return null;
    final draftEdition = draft['edition'] as Map<String, dynamic>?;
    return BookshelfItemSummary(
      title: draft['title'] as String,
      authors: (draft['authors'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      coverUrl: draftEdition?['coverUrl'] as String?,
      language: draftEdition?['language'] as String?,
      format: draftEdition?['format'] as String?,
      pageCount: draftEdition?['pageCount'] as int?,
    );
  }

  static BookshelfTarget targetFromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'book' => BookshelfBookTarget(
        bookId: json['bookId'] as String,
        editionId: json['editionId'] as String,
      ),
      'draft' => BookshelfDraftTarget(
        userBookDraftId: json['userBookDraftId'] as String,
      ),
      final String type => throw FormatException(
        'target.type desconhecido: $type',
      ),
    };
  }

  static DateTime? _dateTimeOrNull(Object? value) =>
      value is String ? DateTime.parse(value).toUtc() : null;
}
