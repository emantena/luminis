import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/reading_goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../mappers/goal_mapper.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(
    this._apiClient, {
    this.bearerToken,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ApiClient _apiClient;
  final String? bearerToken;
  final DateTime Function() _now;

  @override
  Future<List<ReadingGoalSnapshot>> listGoals() async {
    final response = await _apiClient.get(
      '/reading-goals',
      bearerToken: bearerToken,
    );
    return GoalMapper.listFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReadingGoalSnapshot> getGoal(String readingGoalId) async {
    final response = await _apiClient.get(
      '/reading-goals/${Uri.encodeComponent(readingGoalId)}',
      bearerToken: bearerToken,
    );
    return GoalMapper.snapshotFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReadingGoalSnapshot> createGoal(ReadingGoalDraft draft) async {
    final period = _periodFor(draft.periodType, _now().toUtc());
    final response = await _apiClient.post(
      '/reading-goals',
      bearerToken: bearerToken,
      body: {
        'periodType': GoalMapper.periodTypeToWire(draft.periodType),
        'metricType': GoalMapper.metricTypeToWire(draft.metricType),
        'targetValue': draft.targetValue,
        'startsOn': _dateOnlyToWire(period.start),
        'endsOn': _dateOnlyToWire(period.end),
        'isPublic': draft.isPublic,
      },
    );
    return GoalMapper.snapshotFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReadingGoalSnapshot> updateGoal({
    required String readingGoalId,
    required ReadingGoalDraft draft,
  }) async {
    final period = _periodFor(draft.periodType, _now().toUtc());
    final response = await _apiClient.patch(
      '/reading-goals/${Uri.encodeComponent(readingGoalId)}',
      bearerToken: bearerToken,
      body: {
        'targetValue': draft.targetValue,
        'startsOn': _dateOnlyToWire(period.start),
        'endsOn': _dateOnlyToWire(period.end),
        'isPublic': draft.isPublic,
      },
    );
    return GoalMapper.snapshotFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> cancelGoal(String readingGoalId) async {
    await _apiClient.post(
      '/reading-goals/${Uri.encodeComponent(readingGoalId)}/cancel',
      bearerToken: bearerToken,
      body: const <String, Object?>{},
    );
  }

  _GoalPeriod _periodFor(GoalPeriodType type, DateTime value) {
    final date = DateTime.utc(value.year, value.month, value.day);
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

  String _dateOnlyToWire(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _GoalPeriod {
  const _GoalPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
