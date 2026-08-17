import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_progress_entry.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_state_snapshot.dart';
import 'package:luminis_app/features/reading/domain/repositories/reading_repository.dart';

class FakeReadingRepository implements ReadingRepository {
  FakeReadingRepository({
    this.onListContinuableReadings,
    this.onGetReadingState,
    this.onResumeReading,
    this.onUpdateReadingStatus,
    this.onRegisterProgress,
    this.onSavePlan,
    this.onRemovePlan,
  });

  final Future<List<ReadingStateSnapshot>> Function()?
  onListContinuableReadings;
  final Future<ReadingStateSnapshot> Function({
    required String bookshelfItemId,
  })?
  onGetReadingState;
  final Future<ReadingStateSnapshot> Function({
    required String bookshelfItemId,
  })?
  onResumeReading;
  final Future<ReadingStateSnapshot> Function({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  })?
  onUpdateReadingStatus;
  final Future<ReadingProgressResult> Function({
    required String readingSessionId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic,
  })?
  onRegisterProgress;
  final Future<ReadingStateSnapshot> Function({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  })?
  onSavePlan;
  final Future<ReadingStateSnapshot> Function({
    required String bookshelfItemId,
  })?
  onRemovePlan;

  @override
  Future<List<ReadingStateSnapshot>> listContinuableReadings() {
    final callback = onListContinuableReadings;
    if (callback == null) {
      throw StateError('FakeReadingRepository.listContinuableReadings.');
    }
    return callback();
  }

  @override
  Future<ReadingStateSnapshot> getReadingState({
    required String bookshelfItemId,
  }) {
    final callback = onGetReadingState;
    if (callback == null) {
      throw StateError('FakeReadingRepository.getReadingState.');
    }
    return callback(bookshelfItemId: bookshelfItemId);
  }

  @override
  Future<ReadingStateSnapshot> resumeReading({
    required String bookshelfItemId,
  }) {
    final callback = onResumeReading;
    if (callback == null) {
      throw StateError('FakeReadingRepository.resumeReading.');
    }
    return callback(bookshelfItemId: bookshelfItemId);
  }

  @override
  Future<ReadingStateSnapshot> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  }) {
    final callback = onUpdateReadingStatus;
    if (callback == null) {
      throw StateError('FakeReadingRepository.updateReadingStatus.');
    }
    return callback(
      bookshelfItemId: bookshelfItemId,
      readingStatus: readingStatus,
      sessionAction: sessionAction,
    );
  }

  @override
  Future<ReadingProgressResult> registerProgress({
    required String readingSessionId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic = false,
  }) {
    final callback = onRegisterProgress;
    if (callback == null) {
      throw StateError('FakeReadingRepository.registerProgress.');
    }
    return callback(
      readingSessionId: readingSessionId,
      pageNumber: pageNumber,
      percentage: percentage,
      note: note,
      isPublic: isPublic,
    );
  }

  @override
  Future<ReadingStateSnapshot> savePlan({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  }) {
    final callback = onSavePlan;
    if (callback == null) {
      throw StateError('FakeReadingRepository.savePlan.');
    }
    return callback(
      bookshelfItemId: bookshelfItemId,
      targetFinishDate: targetFinishDate,
    );
  }

  @override
  Future<ReadingStateSnapshot> removePlan({required String bookshelfItemId}) {
    final callback = onRemovePlan;
    if (callback == null) {
      throw StateError('FakeReadingRepository.removePlan.');
    }
    return callback(bookshelfItemId: bookshelfItemId);
  }
}
