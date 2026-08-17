import '../entities/reading_goal.dart';

abstract interface class GoalRepository {
  Future<List<ReadingGoalSnapshot>> listGoals();

  Future<ReadingGoalSnapshot> getGoal(String readingGoalId);

  Future<ReadingGoalSnapshot> createGoal(ReadingGoalDraft draft);

  Future<ReadingGoalSnapshot> updateGoal({
    required String readingGoalId,
    required ReadingGoalDraft draft,
  });

  Future<void> cancelGoal(String readingGoalId);
}
