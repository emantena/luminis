enum GoalPeriodType { monthly, yearly }

enum GoalMetricType { booksRead, pagesRead }

enum GoalStatus { active, completed, canceled }

class ReadingGoal {
  const ReadingGoal({
    required this.id,
    required this.periodType,
    required this.metricType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    required this.isPublic,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.canceledAt,
  });

  final String id;
  final GoalPeriodType periodType;
  final GoalMetricType metricType;
  final int targetValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;

  ReadingGoal copyWith({
    GoalPeriodType? periodType,
    GoalMetricType? metricType,
    int? targetValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPublic,
    GoalStatus? status,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? canceledAt,
  }) {
    return ReadingGoal(
      id: id,
      periodType: periodType ?? this.periodType,
      metricType: metricType ?? this.metricType,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }
}

class ReadingGoalSnapshot {
  const ReadingGoalSnapshot({
    required this.goal,
    required this.currentValue,
    required this.bonusValue,
    required this.progressPercent,
    required this.remainingDays,
    required this.isExpired,
    required this.needsAttention,
    required this.contributors,
  });

  final ReadingGoal goal;
  final int currentValue;
  final int bonusValue;
  final double progressPercent;
  final int remainingDays;
  final bool isExpired;
  final bool needsAttention;
  final List<GoalProgressContributor> contributors;

  bool get isCompleted => goal.status == GoalStatus.completed;
}

class GoalProgressContributor {
  const GoalProgressContributor({
    required this.title,
    required this.value,
    required this.description,
  });

  final String title;
  final int value;
  final String description;
}

class ReadingGoalDraft {
  const ReadingGoalDraft({
    required this.periodType,
    required this.metricType,
    required this.targetValue,
    required this.isPublic,
  });

  final GoalPeriodType periodType;
  final GoalMetricType metricType;
  final int targetValue;
  final bool isPublic;
}
