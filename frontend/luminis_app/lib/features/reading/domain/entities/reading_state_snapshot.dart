import '../../../bookshelf/domain/entities/bookshelf_item.dart';
import 'reading_pace.dart';
import 'reading_plan.dart';
import 'reading_progress_entry.dart';
import 'reading_session.dart';

class ReadingStateSnapshot {
  const ReadingStateSnapshot({
    required this.bookshelfItem,
    required this.pace,
    this.session,
    this.lastProgress,
    this.activePlan,
  });

  final BookshelfItem bookshelfItem;
  final ReadingSession? session;
  final ReadingProgressEntry? lastProgress;
  final ReadingPlan? activePlan;
  final ReadingPace pace;

  int? get pageCount => bookshelfItem.summary?.pageCount;

  int get progressPercent {
    final percentage = lastProgress?.percentage;
    if (percentage != null) return percentage.clamp(0, 100).toInt();
    final pages = pageCount;
    final page = lastProgress?.pageNumber;
    if (pages == null || pages <= 0 || page == null) return 0;
    return ((page / pages) * 100).round().clamp(0, 100).toInt();
  }

  int? get currentPage => lastProgress?.pageNumber;

  int? get remainingPages {
    final pages = pageCount;
    final page = currentPage;
    if (pages == null || page == null) return null;
    return (pages - page).clamp(0, pages).toInt();
  }

  String get title => bookshelfItem.summary?.title ?? 'Livro da estante';

  String get authorLabel =>
      bookshelfItem.summary?.authorLabel ?? 'Autoria não informada';
}
