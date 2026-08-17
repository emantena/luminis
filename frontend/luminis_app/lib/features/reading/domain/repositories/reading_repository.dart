import '../../../bookshelf/domain/entities/reading_status.dart';
import '../entities/reading_progress_entry.dart';
import '../entities/reading_state_snapshot.dart';

enum WantToReadSessionAction { keepPaused, interrupt }

abstract interface class ReadingRepository {
  Future<List<ReadingStateSnapshot>> listContinuableReadings();

  Future<ReadingStateSnapshot> getReadingState({
    required String bookshelfItemId,
  });

  Future<ReadingStateSnapshot> resumeReading({required String bookshelfItemId});

  Future<ReadingStateSnapshot> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  });

  Future<ReadingProgressResult> registerProgress({
    required String readingSessionId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic = false,
  });

  Future<ReadingStateSnapshot> savePlan({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  });

  Future<ReadingStateSnapshot> removePlan({required String bookshelfItemId});
}
