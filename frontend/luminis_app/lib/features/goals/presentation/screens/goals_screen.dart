import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../controllers/goal_controllers.dart';
import '../widgets/goal_ui.dart';

/// Aba raiz Metas (`/goals`).
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          TextButton.icon(
            onPressed: () => context.pushNamed(AppRouteNames.goalNew),
            icon: const Icon(Icons.add),
            label: const Text('Criar'),
          ),
        ],
      ),
      body: switch (goals) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.flag_outlined,
          title: 'Não foi possível carregar suas metas',
          description: 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: () => ref.invalidate(goalsControllerProvider),
        ),
        AsyncData(:final value) when value.isEmpty => LuminisEmptyState(
          icon: Icons.flag_outlined,
          title: 'Nenhuma meta criada',
          description:
              'Crie uma meta mensal ou anual para acompanhar sua leitura.',
          actionLabel: 'Criar meta',
          onAction: () => context.pushNamed(AppRouteNames.goalNew),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(goalsControllerProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LuminisSpacing.screenMargin,
              LuminisSpacing.listItemGap,
              LuminisSpacing.screenMargin,
              LuminisSpacing.sectionGap,
            ),
            children: [
              Text(
                'Veja seu ritmo de leitura por mês ou por ano.',
                style: LuminisTypography.body,
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              for (final snapshot in value) ...[
                GoalCard(
                  snapshot: snapshot,
                  onTap: () => context.pushNamed(
                    AppRouteNames.goalDetail,
                    pathParameters: {'readingGoalId': snapshot.goal.id},
                  ),
                ),
                const SizedBox(height: LuminisSpacing.listItemGap),
              ],
            ],
          ),
        ),
      },
    );
  }
}
