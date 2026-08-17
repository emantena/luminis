import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../domain/entities/reading_goal.dart';
import '../controllers/goal_controllers.dart';
import '../widgets/goal_form.dart';

/// Criação de meta mensal/anual (`/goals/new`), dentro da branch Metas.
class GoalNewScreen extends ConsumerWidget {
  const GoalNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(goalFormControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar meta')),
      body: GoalForm(
        submitLabel: 'Criar meta',
        isSubmitting: formState.isSubmitting,
        errorMessage: formState.errorMessage,
        onSubmit:
            ({
              required GoalPeriodType periodType,
              required GoalMetricType metricType,
              required int targetValue,
              required bool isPublic,
            }) async {
              final snapshot = await ref
                  .read(goalFormControllerProvider.notifier)
                  .create(
                    periodType: periodType,
                    metricType: metricType,
                    targetValue: targetValue,
                    isPublic: isPublic,
                  );
              if (!context.mounted || snapshot == null) return;
              context.replaceNamed(
                AppRouteNames.goalDetail,
                pathParameters: {'readingGoalId': snapshot.goal.id},
              );
            },
      ),
    );
  }
}
