import '../../../bookshelf/data/mappers/bookshelf_mapper.dart';
import '../../domain/entities/reading_pace.dart';
import '../../domain/entities/reading_plan.dart';
import '../../domain/entities/reading_progress_entry.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/reading_state_snapshot.dart';

abstract final class ReadingMapper {
  static ReadingStateSnapshot stateFromJson(Map<String, dynamic> json) {
    final session = json['session'] as Map<String, dynamic>?;
    final lastProgress = json['lastProgress'] as Map<String, dynamic>?;
    final activePlan = json['activePlan'] as Map<String, dynamic>?;
    final pace = json['readingPace'] as Map<String, dynamic>? ?? const {};

    return ReadingStateSnapshot(
      bookshelfItem: BookshelfMapper.itemFromJson(
        json['bookshelfItem'] as Map<String, dynamic>,
      ),
      session: session == null ? null : sessionFromJson(session),
      lastProgress: lastProgress == null
          ? null
          : progressEntryFromJson(lastProgress),
      activePlan: activePlan == null ? null : planFromJson(activePlan),
      pace: paceFromJson(pace),
    );
  }

  static ReadingProgressResult progressResultFromJson(
    Map<String, dynamic> json,
  ) {
    return ReadingProgressResult(
      entry: progressEntryFromJson(json),
      completedReading: json['completedReading'] as bool? ?? false,
    );
  }

  static ReadingSession sessionFromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      bookshelfItemId: json['bookshelfItemId'] as String,
      status: ReadingSessionStatusWire.fromWire(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
      finishedAt: _dateTimeOrNull(json['finishedAt']),
    );
  }

  static ReadingProgressEntry progressEntryFromJson(Map<String, dynamic> json) {
    return ReadingProgressEntry(
      id: json['id'] as String,
      readingSessionId: json['readingSessionId'] as String,
      pageNumber: json['pageNumber'] as int?,
      percentage: json['percentage'] as int?,
      note: json['note'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  static ReadingPlan planFromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      bookshelfItemId: json['bookshelfItemId'] as String,
      startDate: _dateOnly(json['startDate'] as String),
      targetFinishDate: _dateOnly(json['targetFinishDate'] as String),
    );
  }

  static ReadingPace paceFromJson(Map<String, dynamic> json) {
    return ReadingPace(
      canCalculate: json['canCalculate'] as bool? ?? false,
      remainingPages: json['remainingPages'] as int?,
      remainingDays: json['remainingDays'] as int?,
      dailyPagesTarget: json['dailyPagesTarget'] as int?,
    );
  }

  static String dateOnlyToWire(DateTime date) {
    final utc = date.toUtc();
    final day = utc.day.toString().padLeft(2, '0');
    final month = utc.month.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  static DateTime _dateOnly(String value) {
    final parts = value.split('-').map(int.parse).toList(growable: false);
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  static DateTime? _dateTimeOrNull(Object? value) =>
      value is String ? DateTime.parse(value).toUtc() : null;
}
