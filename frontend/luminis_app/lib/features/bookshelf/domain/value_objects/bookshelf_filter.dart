import '../entities/reading_status.dart';
import 'bookshelf_tag_filter.dart';

/// Combinação de filtros de `GET /api/bookshelf-items` usada pela
/// presentation (`BookshelfController`). `readingStatus == null` significa
/// "todos os status".
class BookshelfFilter {
  const BookshelfFilter({
    this.readingStatus,
    this.tags = const BookshelfTagFilter(),
  });

  final ReadingStatus? readingStatus;
  final BookshelfTagFilter tags;

  @override
  bool operator ==(Object other) {
    return other is BookshelfFilter &&
        other.readingStatus == readingStatus &&
        other.tags == tags;
  }

  @override
  int get hashCode => Object.hash(readingStatus, tags);
}
