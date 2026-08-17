import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/goals/data/providers/goal_providers.dart';
import 'package:luminis_app/features/goals/data/repositories/in_memory_goal_repository.dart';
import 'package:luminis_app/features/goals/domain/entities/reading_goal.dart';
import 'package:luminis_app/features/goals/presentation/controllers/goal_controllers.dart';

void main() {
  group('GoalFormController', () {
    test('cria meta e invalida lista via estado de sucesso', () async {
      final repository = InMemoryGoalRepository(
        now: () => DateTime.utc(2026, 8, 17),
      );
      final container = ProviderContainer.test(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final snapshot = await container
          .read(goalFormControllerProvider.notifier)
          .create(
            periodType: GoalPeriodType.monthly,
            metricType: GoalMetricType.booksRead,
            targetValue: 3,
            isPublic: false,
          );

      expect(snapshot, isNotNull);
      expect(container.read(goalFormControllerProvider).isSuccess, isTrue);
      expect(snapshot!.goal.isPublic, isFalse);
    });

    test('cancelar meta remove da lista', () async {
      final repository = InMemoryGoalRepository(
        now: () => DateTime.utc(2026, 8, 17),
      );
      final container = ProviderContainer.test(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final canceled = await container
          .read(goalFormControllerProvider.notifier)
          .cancel('goal_monthly_pages_active');
      final goals = await repository.listGoals();

      expect(canceled, isTrue);
      expect(
        goals.any((goal) => goal.goal.id == 'goal_monthly_pages_active'),
        isFalse,
      );
    });
  });
}
