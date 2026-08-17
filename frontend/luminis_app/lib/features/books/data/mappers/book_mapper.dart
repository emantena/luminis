import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/entities/book_search_item.dart';
import '../../domain/entities/edition.dart';
import '../../domain/entities/publisher.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/user_book_draft.dart';

/// Conversões wire -> domínio das rotas do Catalog.
///
/// Mantido em `data` para que JSON e particularidades HTTP não atravessem a
/// fronteira de `domain`.
abstract final class BookMapper {
  static BookCatalogSearchResult searchResultFromJson(
    Map<String, dynamic> json,
  ) {
    return BookCatalogSearchResult(
      items: (json['items'] as List<dynamic>)
          .map((item) => searchItemFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }

  static BookSearchItem searchItemFromJson(Map<String, dynamic> json) {
    return BookSearchItem(
      book: bookFromJson(json['book'] as Map<String, dynamic>),
      edition: editionFromJson(json['edition'] as Map<String, dynamic>),
    );
  }

  static BookDetail detailFromJson(Map<String, dynamic> json) {
    return BookDetail(
      book: bookFromJson(json['book'] as Map<String, dynamic>),
      editions: (json['editions'] as List<dynamic>)
          .map((edition) => editionFromJson(edition as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static Book bookFromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      authors: (json['authors'] as List<dynamic>)
          .map((author) => authorFromJson(author as Map<String, dynamic>))
          .toList(growable: false),
      description: json['description'] as String?,
      originalTitle: json['originalTitle'] as String?,
      subjects: (json['subjects'] as List<dynamic>? ?? const <dynamic>[])
          .map((subject) => subjectFromJson(subject as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static Author authorFromJson(Map<String, dynamic> json) =>
      Author(id: json['id'] as String, name: json['name'] as String);

  static Subject subjectFromJson(Map<String, dynamic> json) =>
      Subject(id: json['id'] as String, name: json['name'] as String);

  static Edition editionFromJson(Map<String, dynamic> json) {
    return Edition(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      coverUrl: json['coverUrl'] as String?,
      publisher: publisherFromJson(json['publisher'] as Map<String, dynamic>),
      publishedYear: json['publishedYear'] as int?,
      language: json['language'] as String?,
      format: json['format'] as String?,
      pageCount: json['pageCount'] as int?,
      isbn10: json['isbn10'] as String?,
      isbn13: json['isbn13'] as String?,
    );
  }

  static Publisher publisherFromJson(Map<String, dynamic> json) => Publisher(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logoUrl'] as String?,
  );

  static UserBookDraft draftFromJson(Map<String, dynamic> json) {
    final editionJson = json['edition'] as Map<String, dynamic>?;
    return UserBookDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      authors: (json['authors'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      edition: editionJson == null ? null : draftEditionFromJson(editionJson),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  static UserBookDraftEdition draftEditionFromJson(Map<String, dynamic> json) {
    return UserBookDraftEdition(
      publisher: json['publisher'] as String?,
      publishedYear: json['publishedYear'] as int?,
      language: json['language'] as String?,
      format: json['format'] as String?,
      pageCount: json['pageCount'] as int?,
      isbn10: json['isbn10'] as String?,
      isbn13: json['isbn13'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  static Map<String, Object?> draftEditionToJson(
    UserBookDraftEdition edition,
  ) => {
    'publisher': edition.publisher,
    'publishedYear': edition.publishedYear,
    'language': edition.language,
    'format': edition.format,
    'pageCount': edition.pageCount,
    'isbn10': edition.isbn10,
    'isbn13': edition.isbn13,
    'coverUrl': edition.coverUrl,
  };
}
