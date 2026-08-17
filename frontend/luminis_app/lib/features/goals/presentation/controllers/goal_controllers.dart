import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/infrastructure/no_retry.dart';
import '../../data/providers/goal_providers.dart';
import '../../domain/entities/reading_goal.dart';

final goalsControllerProvider = FutureProvider<List<ReadingGoalSnapshot>>(
  (ref) => ref.watch(goalRepositoryProvider).listGoals(),
  retry: noRetry,
);

final goalDetailControllerProvider = FutureProvider.autoDispose
    .family<ReadingGoalSnapshot, String>(
      (ref, readingGoalId) =>
          ref.watch(goalRepositoryProvider).getGoal(readingGoalId),
      retry: noRetry,
    );

final goalFormControllerProvider =
    NotifierProvider.autoDispose<GoalFormController, GoalFormState>(
      GoalFormController.new,
    );

class GoalFormController extends Notifier<GoalFormState> {
  @override
  GoalFormState build() => const GoalFormState();

  Future<ReadingGoalSnapshot?> create({
    required GoalPeriodType periodType,
    required GoalMetricType metricType,
    required int targetValue,
    required bool isPublic,
  }) async {
    return _submit(
      () => ref
          .read(goalRepositoryProvider)
          .createGoal(
            ReadingGoalDraft(
              periodType: periodType,
              metricType: metricType,
              targetValue: targetValue,
              isPublic: isPublic,
            ),
          ),
    );
  }

  Future<ReadingGoalSnapshot?> update({
    required String readingGoalId,
    required GoalPeriodType periodType,
    required GoalMetricType metricType,
    required int targetValue,
    required bool isPublic,
  }) async {
    return _submit(
      () => ref
          .read(goalRepositoryProvider)
          .updateGoal(
            readingGoalId: readingGoalId,
            draft: ReadingGoalDraft(
              periodType: periodType,
              metricType: metricType,
              targetValue: targetValue,
              isPublic: isPublic,
            ),
          ),
      detailId: readingGoalId,
    );
  }

  Future<bool> cancel(String readingGoalId) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      await ref.read(goalRepositoryProvider).cancelGoal(readingGoalId);
      ref.invalidate(goalsControllerProvider);
      ref.invalidate(goalDetailControllerProvider(readingGoalId));
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  Future<ReadingGoalSnapshot?> _submit(
    Future<ReadingGoalSnapshot> Function() action, {
    String? detailId,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      final snapshot = await action();
      ref.invalidate(goalsControllerProvider);
      ref.invalidate(goalDetailControllerProvider(snapshot.goal.id));
      if (detailId != null) {
        ref.invalidate(goalDetailControllerProvider(detailId));
      }
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return snapshot;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return null;
    }
  }
}

class GoalFormState {
  const GoalFormState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  GoalFormState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GoalFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

String _messageFor(ApiFailure error) {
  if (error is ApiValidationFailure && error.fieldErrors.isNotEmpty) {
    return error.fieldErrors.values.first.first;
  }
  return error.message;
}
