import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/reading_progress_bar.dart';
import '../../domain/entities/reading_goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({required this.snapshot, this.onTap, super.key});

  final ReadingGoalSnapshot snapshot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalTitle(snapshot.goal),
                      style: LuminisTypography.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${periodLabel(snapshot.goal)} · ${privacyLabel(snapshot.goal)}',
                      style: LuminisTypography.metadata,
                    ),
                  ],
                ),
              ),
              GoalStatusPill(snapshot: snapshot),
            ],
          ),
          if (snapshot.needsAttention) ...[
            const SizedBox(height: LuminisSpacing.listItemGap),
            const GoalAttentionBanner(),
          ],
          const SizedBox(height: LuminisSpacing.listItemGap),
          Text(
            '${snapshot.currentValue} de ${snapshot.goal.targetValue} ${metricUnit(snapshot.goal.metricType)}',
            style: LuminisTypography.sectionTitle,
          ),
          const SizedBox(height: 8),
          ReadingProgressBar(percent: (snapshot.progressPercent * 100).round()),
          const SizedBox(height: 8),
          Text(
            progressSupportLabel(snapshot),
            style: LuminisTypography.metadata,
          ),
        ],
      ),
    );

    return Card(
      color: LuminisColors.surface,
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(LuminisRadii.card),
              onTap: onTap,
              child: content,
            ),
    );
  }
}

class GoalStatusPill extends StatelessWidget {
  const GoalStatusPill({required this.snapshot, super.key});

  final ReadingGoalSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (snapshot.goal.status) {
      GoalStatus.completed => ('Concluída', LuminisColors.primary),
      GoalStatus.canceled => ('Cancelada', LuminisColors.line),
      GoalStatus.active when snapshot.needsAttention => (
        'Revisar',
        LuminisColors.coral,
      ),
      GoalStatus.active => ('Ativa', LuminisColors.accent),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(LuminisRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(label, style: LuminisTypography.labelChip),
      ),
    );
  }
}

class GoalAttentionBanner extends StatelessWidget {
  const GoalAttentionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LuminisColors.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LuminisRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Meta vencida e ainda ativa. Revise o alvo ou o período.',
          style: LuminisTypography.metadata.copyWith(
            color: LuminisColors.coral,
          ),
        ),
      ),
    );
  }
}

String goalTitle(ReadingGoal goal) {
  final metric = goal.metricType == GoalMetricType.booksRead
      ? 'livros lidos'
      : 'páginas lidas';
  return '${goal.targetValue} $metric';
}

String periodLabel(ReadingGoal goal) {
  return switch (goal.periodType) {
    GoalPeriodType.monthly => 'Meta mensal',
    GoalPeriodType.yearly => 'Meta anual',
  };
}

String metricUnit(GoalMetricType metricType) {
  return switch (metricType) {
    GoalMetricType.booksRead => 'livros',
    GoalMetricType.pagesRead => 'páginas',
  };
}

String privacyLabel(ReadingGoal goal) => goal.isPublic ? 'Pública' : 'Privada';

String progressSupportLabel(ReadingGoalSnapshot snapshot) {
  if (snapshot.isCompleted && snapshot.bonusValue > 0) {
    return 'Alvo atingido com ${snapshot.bonusValue} ${metricUnit(snapshot.goal.metricType)} de bônus.';
  }
  if (snapshot.isCompleted) return 'Alvo atingido pelo cálculo do sistema.';
  if (snapshot.needsAttention) return 'A meta continua ativa para revisão.';
  return '${snapshot.remainingDays} dia(s) restantes no período.';
}

String dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
