import '../../../../shared/infrastructure/api_exception.dart';
import '../../domain/entities/reading_goal.dart';
import '../../domain/repositories/goal_repository.dart';

class InMemoryGoalRepository implements GoalRepository {
  InMemoryGoalRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now {
    _seed();
  }

  final DateTime Function() _now;
  final Map<String, ReadingGoal> _goals = {};
  int _sequence = 100;

  @override
  Future<List<ReadingGoalSnapshot>> listGoals() async {
    final snapshots =
        _goals.values
            .where((goal) => goal.status != GoalStatus.canceled)
            .map(_snapshotFor)
            .toList()
          ..sort(_goalSort);
    return snapshots;
  }

  @override
  Future<ReadingGoalSnapshot> getGoal(String readingGoalId) async {
    return _snapshotFor(_requireGoal(readingGoalId));
  }

  @override
  Future<ReadingGoalSnapshot> createGoal(ReadingGoalDraft draft) async {
    _validateDraft(draft);
    final now = _now().toUtc();
    final period = _periodFor(draft.periodType, now);
    final goal = ReadingGoal(
      id: _newGoalId(),
      periodType: draft.periodType,
      metricType: draft.metricType,
      targetValue: draft.targetValue,
      startDate: period.start,
      endDate: period.end,
      isPublic: draft.isPublic,
      status: GoalStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    final storedGoal = _withCurrentStatus(goal, now);
    _goals[storedGoal.id] = storedGoal;
    return _snapshotFor(storedGoal);
  }

  @override
  Future<ReadingGoalSnapshot> updateGoal({
    required String readingGoalId,
    required ReadingGoalDraft draft,
  }) async {
    _validateDraft(draft);
    final current = _requireGoal(readingGoalId);
    if (current.status != GoalStatus.active) {
      throw const ApiConflictFailure(
        code: 'goal.not_active',
        message: 'Somente metas ativas podem ser editadas.',
        statusCode: 409,
      );
    }
    final now = _now().toUtc();
    final period = _periodFor(draft.periodType, now);
    final updated = current.copyWith(
      periodType: draft.periodType,
      metricType: draft.metricType,
      targetValue: draft.targetValue,
      startDate: period.start,
      endDate: period.end,
      isPublic: draft.isPublic,
      updatedAt: now,
    );
    final storedGoal = _withCurrentStatus(updated, now);
    _goals[readingGoalId] = storedGoal;
    return _snapshotFor(storedGoal);
  }

  @override
  Future<void> cancelGoal(String readingGoalId) async {
    final current = _requireGoal(readingGoalId);
    if (current.status != GoalStatus.active) {
      throw const ApiConflictFailure(
        code: 'goal.not_active',
        message: 'Somente metas ativas podem ser canceladas.',
        statusCode: 409,
      );
    }
    final now = _now().toUtc();
    _goals[readingGoalId] = current.copyWith(
      status: GoalStatus.canceled,
      updatedAt: now,
      canceledAt: now,
    );
  }

  ReadingGoal _requireGoal(String readingGoalId) {
    final goal = _goals[readingGoalId];
    if (goal == null || goal.status == GoalStatus.canceled) {
      throw const ApiNotFoundFailure(
        code: 'goal.not_found',
        message: 'Meta não encontrada.',
        statusCode: 404,
      );
    }
    return goal;
  }

  ReadingGoalSnapshot _snapshotFor(ReadingGoal goal) {
    final currentValue = _calculatedValue(goal);
    final completed = currentValue >= goal.targetValue;
    final today = _dateOnly(_now());
    final end = _dateOnly(goal.endDate);
    final remainingDays = end.difference(today).inDays.clamp(0, 366).toInt();
    final isExpired = today.isAfter(end) && !completed;
    final visibleGoal = _withCalculatedStatus(goal, currentValue);
    return ReadingGoalSnapshot(
      goal: visibleGoal,
      currentValue: currentValue,
      bonusValue: (currentValue - visibleGoal.targetValue).clamp(
        0,
        currentValue,
      ),
      progressPercent: (currentValue / visibleGoal.targetValue).clamp(0, 1),
      remainingDays: remainingDays,
      isExpired: isExpired,
      needsAttention: isExpired,
      contributors: _contributorsFor(visibleGoal),
    );
  }

  int _goalSort(ReadingGoalSnapshot a, ReadingGoalSnapshot b) {
    if (a.needsAttention != b.needsAttention) return a.needsAttention ? -1 : 1;
    if (a.goal.status != b.goal.status) {
      if (a.goal.status == GoalStatus.active) return -1;
      if (b.goal.status == GoalStatus.active) return 1;
    }
    return b.goal.updatedAt.compareTo(a.goal.updatedAt);
  }

  ReadingGoal _withCurrentStatus(ReadingGoal goal, DateTime now) {
    return _withCalculatedStatus(
      goal,
      _calculatedValue(goal),
      completedAt: now.toUtc(),
    );
  }

  ReadingGoal _withCalculatedStatus(
    ReadingGoal goal,
    int currentValue, {
    DateTime? completedAt,
  }) {
    if (goal.status != GoalStatus.active || currentValue < goal.targetValue) {
      return goal;
    }
    return goal.copyWith(
      status: GoalStatus.completed,
      completedAt: goal.completedAt ?? completedAt ?? _now().toUtc(),
    );
  }

  int _calculatedValue(ReadingGoal goal) {
    return switch (goal.id) {
      'goal_monthly_pages_active' => 120,
      'goal_yearly_books_bonus' => 14,
      'goal_expired_pages_attention' => 80,
      _ => goal.metricType == GoalMetricType.pagesRead ? 120 : 2,
    };
  }

  List<GoalProgressContributor> _contributorsFor(ReadingGoal goal) {
    final value = _calculatedValue(goal);
    if (goal.metricType == GoalMetricType.booksRead) {
      if (value <= 1) {
        return const [
          GoalProgressContributor(
            title: 'Memórias Póstumas de Brás Cubas',
            value: 1,
            description: 'Leitura concluída no período.',
          ),
        ];
      }
      return [
        GoalProgressContributor(
          title: 'Memórias Póstumas de Brás Cubas',
          value: value - 1,
          description: 'Leitura concluída no período.',
        ),
        const GoalProgressContributor(
          title: 'Dom Casmurro',
          value: 1,
          description: 'Releitura concluída conta como nova leitura.',
        ),
      ];
    }
    return [
      GoalProgressContributor(
        title: 'Dom Casmurro',
        value: value,
        description: 'Páginas novas lidas no período.',
      ),
    ];
  }

  void _validateDraft(ReadingGoalDraft draft) {
    if (draft.targetValue <= 0) {
      throw const ApiValidationFailure(
        code: 'validation.failed',
        message: 'Existem campos inválidos.',
        statusCode: 400,
        fieldErrors: {
          'targetValue': ['Informe um alvo maior que zero.'],
        },
      );
    }
  }

  _GoalPeriod _periodFor(GoalPeriodType type, DateTime value) {
    final date = _dateOnly(value);
    return switch (type) {
      GoalPeriodType.monthly => _GoalPeriod(
        DateTime.utc(date.year, date.month),
        DateTime.utc(date.year, date.month + 1, 0),
      ),
      GoalPeriodType.yearly => _GoalPeriod(
        DateTime.utc(date.year),
        DateTime.utc(date.year, 12, 31),
      ),
    };
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.toUtc().year, value.toUtc().month, value.toUtc().day);

  String _newGoalId() {
    _sequence++;
    return 'goal_$_sequence';
  }

  void _seed() {
    _goals['goal_monthly_pages_active'] = ReadingGoal(
      id: 'goal_monthly_pages_active',
      periodType: GoalPeriodType.monthly,
      metricType: GoalMetricType.pagesRead,
      targetValue: 500,
      startDate: DateTime.utc(2026, 8),
      endDate: DateTime.utc(2026, 8, 31),
      isPublic: false,
      status: GoalStatus.active,
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 16),
    );
    _goals['goal_yearly_books_bonus'] = ReadingGoal(
      id: 'goal_yearly_books_bonus',
      periodType: GoalPeriodType.yearly,
      metricType: GoalMetricType.booksRead,
      targetValue: 12,
      startDate: DateTime.utc(2026),
      endDate: DateTime.utc(2026, 12, 31),
      isPublic: false,
      status: GoalStatus.completed,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 8, 10),
      completedAt: DateTime.utc(2026, 8, 10),
    );
    _goals['goal_expired_pages_attention'] = ReadingGoal(
      id: 'goal_expired_pages_attention',
      periodType: GoalPeriodType.monthly,
      metricType: GoalMetricType.pagesRead,
      targetValue: 300,
      startDate: DateTime.utc(2026, 7),
      endDate: DateTime.utc(2026, 7, 31),
      isPublic: false,
      status: GoalStatus.active,
      createdAt: DateTime.utc(2026, 7),
      updatedAt: DateTime.utc(2026, 7, 31),
    );
  }
}

class _GoalPeriod {
  const _GoalPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
