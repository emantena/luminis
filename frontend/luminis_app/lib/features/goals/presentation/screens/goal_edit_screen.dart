import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../domain/entities/reading_goal.dart';
import '../controllers/goal_controllers.dart';
import '../widgets/goal_form.dart';
import '../widgets/goal_ui.dart';

/// Edição de meta ativa (`/goals/:readingGoalId/edit`), dentro da branch Metas.
class GoalEditScreen extends ConsumerWidget {
  const GoalEditScreen({required this.readingGoalId, super.key});

  final String readingGoalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(goalDetailControllerProvider(readingGoalId));
    final formState = ref.watch(goalFormControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Editar meta')),
      body: switch (snapshot) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.flag_outlined,
          title: 'Meta não encontrada',
          description: 'Volte para a lista e escolha outra meta.',
          actionLabel: 'Voltar',
          onAction: () => context.pop(),
        ),
        AsyncData(:final value) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LuminisSpacing.screenMargin,
                LuminisSpacing.listItemGap,
                LuminisSpacing.screenMargin,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${value.currentValue} de ${value.goal.targetValue} ${metricUnit(value.goal.metricType)} já calculados.',
                  style: LuminisTypography.body,
                ),
              ),
            ),
            if (value.needsAttention)
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  LuminisSpacing.screenMargin,
                  LuminisSpacing.listItemGap,
                  LuminisSpacing.screenMargin,
                  0,
                ),
                child: GoalAttentionBanner(),
              ),
            Expanded(
              child: GoalForm(
                key: ValueKey(value.goal.id),
                initialGoal: value.goal,
                submitLabel: 'Salvar alterações',
                isSubmitting: formState.isSubmitting,
                errorMessage: formState.errorMessage,
                canEditGoalShape: false,
                onSubmit:
                    ({
                      required GoalPeriodType periodType,
                      required GoalMetricType metricType,
                      required int targetValue,
                      required bool isPublic,
                    }) async {
                      final updated = await ref
                          .read(goalFormControllerProvider.notifier)
                          .update(
                            readingGoalId: readingGoalId,
                            periodType: periodType,
                            metricType: metricType,
                            targetValue: targetValue,
                            isPublic: isPublic,
                          );
                      if (!context.mounted || updated == null) return;
                      context.goNamed(
                        AppRouteNames.goalDetail,
                        pathParameters: {'readingGoalId': updated.goal.id},
                      );
                    },
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(
                LuminisSpacing.screenMargin,
                0,
                LuminisSpacing.screenMargin,
                LuminisSpacing.listItemGap,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: formState.isSubmitting
                      ? null
                      : () => _confirmCancel(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: LuminisColors.coral,
                  ),
                  child: const Text('Cancelar meta'),
                ),
              ),
            ),
          ],
        ),
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar meta?'),
        content: const Text('A meta deixará de aparecer na lista ativa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: LuminisColors.coral),
            child: const Text('Cancelar meta'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final canceled = await ref
        .read(goalFormControllerProvider.notifier)
        .cancel(readingGoalId);
    if (!context.mounted || !canceled) return;
    context.goNamed(AppRouteNames.goals);
  }
}
