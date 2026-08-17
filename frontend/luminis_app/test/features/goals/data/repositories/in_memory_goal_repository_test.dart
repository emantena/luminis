import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/goals/data/repositories/in_memory_goal_repository.dart';
import 'package:luminis_app/features/goals/domain/entities/reading_goal.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('InMemoryGoalRepository', () {
    test(
      'lista metas ativa, concluida com bonus e vencida com alerta',
      () async {
        final repository = InMemoryGoalRepository(
          now: () => DateTime.utc(2026, 8, 17),
        );

        final goals = await repository.listGoals();
        final expired = goals.first;

        expect(goals, hasLength(3));
        expect(expired.needsAttention, isTrue);
        expect(
          expired.contributors.fold<int>(
            0,
            (total, contributor) => total + contributor.value,
          ),
          expired.currentValue,
        );
        expect(goals.any((goal) => goal.bonusValue == 2), isTrue);
        expect(
          goals.any(
            (goal) =>
                goal.goal.status == GoalStatus.active &&
                goal.goal.metricType == GoalMetricType.pagesRead,
          ),
          isTrue,
        );
      },
    );

    test('cria meta privada por padrao quando draft vem privado', () async {
      final repository = InMemoryGoalRepository(
        now: () => DateTime.utc(2026, 8, 17),
      );

      final snapshot = await repository.createGoal(
        const ReadingGoalDraft(
          periodType: GoalPeriodType.monthly,
          metricType: GoalMetricType.booksRead,
          targetValue: 4,
          isPublic: false,
        ),
      );

      expect(snapshot.goal.isPublic, isFalse);
      expect(snapshot.goal.targetValue, 4);
      expect(snapshot.goal.periodType, GoalPeriodType.monthly);
    });

    test('persiste meta concluida quando alvo ja foi atingido', () async {
      final repository = InMemoryGoalRepository(
        now: () => DateTime.utc(2026, 8, 17),
      );

      final snapshot = await repository.createGoal(
        const ReadingGoalDraft(
          periodType: GoalPeriodType.monthly,
          metricType: GoalMetricType.booksRead,
          targetValue: 1,
          isPublic: false,
        ),
      );

      expect(snapshot.goal.status, GoalStatus.completed);
      expect(
        () => repository.cancelGoal(snapshot.goal.id),
        throwsA(isA<ApiConflictFailure>()),
      );
    });

    test('rejeita alvo menor ou igual a zero', () async {
      final repository = InMemoryGoalRepository(
        now: () => DateTime.utc(2026, 8, 17),
      );

      expect(
        () => repository.createGoal(
          const ReadingGoalDraft(
            periodType: GoalPeriodType.yearly,
            metricType: GoalMetricType.pagesRead,
            targetValue: 0,
            isPublic: false,
          ),
        ),
        throwsA(isA<ApiValidationFailure>()),
      );
    });
  });
}
