import '../../domain/entities/reading_goal.dart';

abstract final class GoalMapper {
  static List<ReadingGoalSnapshot> listFromJson(Map<String, dynamic> json) {
    return (json['items'] as List<dynamic>)
        .map((item) => snapshotFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static ReadingGoalSnapshot snapshotFromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>;
    return ReadingGoalSnapshot(
      goal: ReadingGoal(
        id: json['id'] as String,
        periodType: _periodTypeFromWire(json['periodType'] as String),
        metricType: _metricTypeFromWire(json['metricType'] as String),
        targetValue: json['targetValue'] as int,
        startDate: _dateOnlyFromWire(json['startsOn'] as String),
        endDate: _dateOnlyFromWire(json['endsOn'] as String),
        isPublic: json['isPublic'] as bool? ?? false,
        status: _statusFromWire(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
        completedAt: _dateTimeOrNull(json['completedAt']),
        canceledAt: _dateTimeOrNull(json['cancelledAt'] ?? json['canceledAt']),
      ),
      currentValue: progress['currentValue'] as int,
      bonusValue: progress['bonusValue'] as int,
      progressPercent: ((progress['percentage'] as num).toDouble() / 100)
          .clamp(0, 1)
          .toDouble(),
      remainingDays: progress['remainingDays'] as int? ?? 0,
      isExpired: progress['isExpired'] as bool? ?? false,
      needsAttention: progress['needsAttention'] as bool? ?? false,
      contributors:
          (progress['contributors'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => contributorFromJson(item as Map<String, dynamic>))
              .toList(growable: false),
    );
  }

  static GoalProgressContributor contributorFromJson(
    Map<String, dynamic> json,
  ) {
    return GoalProgressContributor(
      title: json['title'] as String,
      value: json['value'] as int,
      description: json['description'] as String? ?? '',
    );
  }

  static String periodTypeToWire(GoalPeriodType type) {
    return switch (type) {
      GoalPeriodType.monthly => 'monthly',
      GoalPeriodType.yearly => 'annual',
    };
  }

  static String metricTypeToWire(GoalMetricType type) {
    return switch (type) {
      GoalMetricType.booksRead => 'books_read',
      GoalMetricType.pagesRead => 'pages_read',
    };
  }

  static GoalPeriodType _periodTypeFromWire(String value) {
    return switch (value) {
      'monthly' => GoalPeriodType.monthly,
      'annual' => GoalPeriodType.yearly,
      final type => throw FormatException('periodType desconhecido: $type'),
    };
  }

  static GoalMetricType _metricTypeFromWire(String value) {
    return switch (value) {
      'books_read' => GoalMetricType.booksRead,
      'pages_read' => GoalMetricType.pagesRead,
      final type => throw FormatException('metricType desconhecido: $type'),
    };
  }

  static GoalStatus _statusFromWire(String value) {
    return switch (value) {
      'active' => GoalStatus.active,
      'completed' => GoalStatus.completed,
      'cancelled' => GoalStatus.canceled,
      final status => throw FormatException('status desconhecido: $status'),
    };
  }

  static DateTime _dateOnlyFromWire(String value) {
    final parts = value.split('-').map(int.parse).toList(growable: false);
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  static DateTime? _dateTimeOrNull(Object? value) =>
      value is String ? DateTime.parse(value).toUtc() : null;
}
