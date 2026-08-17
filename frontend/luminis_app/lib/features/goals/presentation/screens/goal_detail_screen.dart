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
import '../widgets/goal_ui.dart';

/// Detalhe de meta (`/goals/:readingGoalId`), dentro da branch Metas.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({required this.readingGoalId, super.key});

  final String readingGoalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(goalDetailControllerProvider(readingGoalId));
    final formState = ref.watch(goalFormControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da meta'),
        actions: [
          snapshot.whenOrNull(
                data: (value) => value.goal.status == GoalStatus.active
                    ? IconButton(
                        tooltip: 'Editar meta',
                        onPressed: () => context.pushNamed(
                          AppRouteNames.goalEdit,
                          pathParameters: {'readingGoalId': readingGoalId},
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: switch (snapshot) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.flag_outlined,
          title: 'Meta não encontrada',
          description: 'Volte para a lista e escolha outra meta.',
          actionLabel: 'Voltar',
          onAction: () => context.pop(),
        ),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(
            LuminisSpacing.screenMargin,
            LuminisSpacing.listItemGap,
            LuminisSpacing.screenMargin,
            LuminisSpacing.sectionGap,
          ),
          children: [
            GoalCard(snapshot: value),
            const SizedBox(height: LuminisSpacing.sectionGap),
            Text('Período', style: LuminisTypography.sectionTitle),
            const SizedBox(height: 8),
            Text(
              '${dateLabel(value.goal.startDate)} até ${dateLabel(value.goal.endDate)}',
              style: LuminisTypography.body,
            ),
            const SizedBox(height: LuminisSpacing.sectionGap),
            Text(
              'Composição do progresso',
              style: LuminisTypography.sectionTitle,
            ),
            const SizedBox(height: LuminisSpacing.listItemGap),
            for (final contributor in value.contributors) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(contributor.title),
                subtitle: Text(contributor.description),
                trailing: Text(
                  '+${contributor.value}',
                  style: LuminisTypography.cardTitle,
                ),
              ),
              const Divider(height: 1),
            ],
            if (value.needsAttention) ...[
              const SizedBox(height: LuminisSpacing.sectionGap),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRouteNames.goalEdit,
                    pathParameters: {'readingGoalId': readingGoalId},
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('Revisar meta'),
                ),
              ),
            ],
            if (value.goal.status == GoalStatus.active) ...[
              const SizedBox(height: LuminisSpacing.sectionGap),
              SizedBox(
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
            ],
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
