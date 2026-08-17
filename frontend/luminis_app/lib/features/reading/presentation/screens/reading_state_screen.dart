import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/book_cover.dart';
import '../../../../shared/presentation/widgets/bookshelf_status_chip.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../../shared/presentation/widgets/reading_progress_bar.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../../domain/repositories/reading_repository.dart';
import '../controllers/reading_controllers.dart';

class ReadingStateScreen extends ConsumerWidget {
  const ReadingStateScreen({required this.bookshelfItemId, super.key});

  final String bookshelfItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingStateControllerProvider(bookshelfItemId));
    return switch (state) {
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: LuminisEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Não foi possível abrir esta leitura',
          description: 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: () =>
              ref.invalidate(readingStateControllerProvider(bookshelfItemId)),
        ),
      ),
      AsyncData(:final value) => _ReadingStateView(snapshot: value),
    };
  }
}

class _ReadingStateView extends ConsumerWidget {
  const _ReadingStateView({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = snapshot.session;
    final isPaused = session?.status == ReadingSessionStatus.paused;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitura'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: LuminisSpacing.listItemGap),
            child: Center(
              child: BookshelfStatusChip(
                status: snapshot.bookshelfItem.readingStatus,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          LuminisSpacing.screenMargin,
          LuminisSpacing.listItemGap,
          LuminisSpacing.screenMargin,
          LuminisSpacing.sectionGap,
        ),
        children: [
          _BookHeader(snapshot: snapshot),
          const SizedBox(height: LuminisSpacing.sectionGap),
          _ProgressCard(snapshot: snapshot),
          const SizedBox(height: LuminisSpacing.listItemGap),
          _PlanCard(snapshot: snapshot),
          const SizedBox(height: LuminisSpacing.sectionGap),
          if (isPaused)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _changeStatus(context, ref, ReadingStatus.reading),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Retomar leitura'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: session == null
                    ? () => _changeStatus(context, ref, ReadingStatus.reading)
                    : () => context.pushNamed(
                        AppRouteNames.readingProgressNew,
                        pathParameters: {
                          'bookshelfItemId': snapshot.bookshelfItem.id,
                        },
                      ),
                icon: const Icon(Icons.edit_note),
                label: Text(
                  session == null ? 'Iniciar leitura' : 'Registrar progresso',
                ),
              ),
            ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed(
              AppRouteNames.readingPlan,
              pathParameters: {'bookshelfItemId': snapshot.bookshelfItem.id},
            ),
            icon: const Icon(Icons.event),
            label: Text(
              snapshot.activePlan == null
                  ? 'Definir data alvo'
                  : 'Alterar plano',
            ),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isPaused && session != null)
                OutlinedButton(
                  onPressed: () =>
                      _changeStatus(context, ref, ReadingStatus.paused),
                  child: const Text('Pausar'),
                ),
              OutlinedButton(
                onPressed: () =>
                    _changeStatus(context, ref, ReadingStatus.read),
                child: const Text('Marcar como lido'),
              ),
              OutlinedButton(
                onPressed: () => _confirmWantToRead(context, ref),
                child: const Text('Quero ler'),
              ),
              TextButton(
                onPressed: () =>
                    _changeStatus(context, ref, ReadingStatus.abandoned),
                style: TextButton.styleFrom(
                  foregroundColor: LuminisColors.coral,
                ),
                child: const Text('Abandonar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    ReadingStatus status, {
    WantToReadSessionAction? sessionAction,
  }) async {
    final success = await ref
        .read(readingStatusControllerProvider.notifier)
        .update(
          bookshelfItemId: snapshot.bookshelfItem.id,
          readingStatus: status,
          sessionAction: sessionAction,
        );
    if (!success) {
      if (!context.mounted) return;
      final message = ref.read(readingStatusControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Não foi possível alterar status.')),
      );
      return;
    }
    if (!context.mounted) return;
    if (status == ReadingStatus.wantToRead ||
        status == ReadingStatus.read ||
        status == ReadingStatus.abandoned) {
      context.goNamed(AppRouteNames.bookshelf);
    }
  }

  Future<void> _confirmWantToRead(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<WantToReadSessionAction>(
      context: context,
      builder: (context) => _WantToReadSheet(snapshot: snapshot),
    );
    if (action == null || !context.mounted) return;
    await _changeStatus(
      context,
      ref,
      ReadingStatus.wantToRead,
      sessionAction: action,
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot.bookshelfItem.summary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookCover(
          title: snapshot.title,
          coverUrl: summary?.coverUrl,
          width: 72,
          height: 108,
        ),
        const SizedBox(width: LuminisSpacing.listItemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(snapshot.title, style: LuminisTypography.sectionTitle),
              const SizedBox(height: 4),
              Text(snapshot.authorLabel, style: LuminisTypography.body),
              const SizedBox(height: 8),
              Text(
                [
                  if (summary?.editionLabel.isNotEmpty ?? false)
                    summary!.editionLabel,
                  if (summary?.pageCount != null)
                    '${summary!.pageCount} páginas',
                ].join(' · '),
                style: LuminisTypography.metadata,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso', style: LuminisTypography.sectionTitle),
            const SizedBox(height: LuminisSpacing.listItemGap),
            Text(
              _progressMainLabel(snapshot),
              style: LuminisTypography.cardTitle,
            ),
            const SizedBox(height: 8),
            ReadingProgressBar(percent: snapshot.progressPercent),
            const SizedBox(height: 8),
            Text(_remainingLabel(snapshot), style: LuminisTypography.metadata),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final plan = snapshot.activePlan;
    final pace = snapshot.pace;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plano', style: LuminisTypography.sectionTitle),
            const SizedBox(height: 8),
            Text(
              plan == null
                  ? 'Sem data alvo definida.'
                  : 'Terminar até ${_formatDate(plan.targetFinishDate)}.',
              style: LuminisTypography.body,
            ),
            const SizedBox(height: 4),
            Text(
              pace.canCalculate
                  ? 'Leia ${pace.dailyPagesTarget} páginas por dia.'
                  : pace.reason ?? 'Ritmo indisponível.',
              style: LuminisTypography.metadata.copyWith(
                color: pace.isDemanding ? LuminisColors.coral : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WantToReadSheet extends StatelessWidget {
  const _WantToReadSheet({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voltar para Quero ler?',
              style: LuminisTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              '${_progressMainLabel(snapshot)}. O plano ativo será removido.',
              style: LuminisTypography.body,
            ),
            const SizedBox(height: LuminisSpacing.listItemGap),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, WantToReadSessionAction.keepPaused),
                child: const Text('Manter progresso pausado'),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, WantToReadSessionAction.interrupt),
              style: TextButton.styleFrom(foregroundColor: LuminisColors.coral),
              child: const Text('Encerrar esta tentativa'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _progressMainLabel(ReadingStateSnapshot snapshot) {
  final page = snapshot.currentPage;
  final pageCount = snapshot.pageCount;
  if (page != null && pageCount != null) return 'Página $page de $pageCount';
  if (page != null) return 'Página $page';
  if (snapshot.progressPercent > 0) return '${snapshot.progressPercent}% lido';
  return 'Nenhum progresso registrado';
}

String _remainingLabel(ReadingStateSnapshot snapshot) {
  final remaining = snapshot.remainingPages;
  if (remaining != null) return '$remaining páginas restantes';
  if (snapshot.pageCount == null) {
    return 'Total de páginas indisponível; use percentual.';
  }
  return 'Registre uma página para calcular quanto falta.';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
