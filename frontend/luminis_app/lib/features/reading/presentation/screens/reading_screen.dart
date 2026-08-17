import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/book_card.dart';
import '../../../../shared/presentation/widgets/book_cover.dart';
import '../../../../shared/presentation/widgets/bookshelf_status_chip.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../../shared/presentation/widgets/reading_progress_bar.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../controllers/reading_controllers.dart';

/// Aba raiz Leitura (`/reading`).
class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(readingHubControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Leitura')),
      body: switch (readings) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => LuminisEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Não foi possível carregar suas leituras',
          description: 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: () => ref.invalidate(readingHubControllerProvider),
        ),
        AsyncData(:final value) when value.isEmpty => LuminisEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Nenhuma leitura em andamento',
          description:
              'Escolha um livro da estante ou busque uma nova leitura.',
          actionLabel: 'Abrir estante',
          onAction: () => context.goNamed(AppRouteNames.bookshelf),
        ),
        AsyncData(:final value) => _ReadingHub(readings: value),
      },
    );
  }
}

class _ReadingHub extends StatelessWidget {
  const _ReadingHub({required this.readings});

  final List<ReadingStateSnapshot> readings;

  @override
  Widget build(BuildContext context) {
    final active = readings.where(_isActive).toList();
    final paused = readings
        .where(
          (snapshot) =>
              snapshot.bookshelfItem.readingStatus == ReadingStatus.paused,
        )
        .toList();
    final primary = active.isEmpty ? null : active.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LuminisSpacing.screenMargin,
        LuminisSpacing.listItemGap,
        LuminisSpacing.screenMargin,
        LuminisSpacing.sectionGap,
      ),
      children: [
        Text(
          primary == null
              ? 'Retome uma leitura pausada quando quiser.'
              : 'Você tem ${active.length} leitura(s) em andamento.',
          style: LuminisTypography.body.copyWith(
            color: LuminisColors.ink.withValues(alpha: 0.7),
          ),
        ),
        if (primary != null) ...[
          const SizedBox(height: LuminisSpacing.sectionGap),
          Text('Continuar lendo', style: LuminisTypography.sectionTitle),
          const SizedBox(height: LuminisSpacing.listItemGap),
          _ReadingHighlight(snapshot: primary),
        ],
        if (paused.isNotEmpty) ...[
          const SizedBox(height: LuminisSpacing.sectionGap),
          Text('Pausados', style: LuminisTypography.sectionTitle),
          const SizedBox(height: LuminisSpacing.listItemGap),
          for (final snapshot in paused) ...[
            _PausedReadingCard(snapshot: snapshot),
            const SizedBox(height: LuminisSpacing.listItemGap),
          ],
        ],
      ],
    );
  }

  bool _isActive(ReadingStateSnapshot snapshot) {
    return snapshot.bookshelfItem.readingStatus == ReadingStatus.reading ||
        snapshot.bookshelfItem.readingStatus == ReadingStatus.rereading;
  }
}

class _ReadingHighlight extends StatelessWidget {
  const _ReadingHighlight({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LuminisColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  title: snapshot.title,
                  coverUrl: snapshot.bookshelfItem.summary?.coverUrl,
                  width: 72,
                  height: 108,
                ),
                const SizedBox(width: LuminisSpacing.listItemGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.title, style: LuminisTypography.cardTitle),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.authorLabel} · ${_progressLabel(snapshot)}',
                        style: LuminisTypography.metadata,
                      ),
                      const SizedBox(height: 8),
                      BookshelfStatusChip(
                        status: snapshot.bookshelfItem.readingStatus,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: LuminisSpacing.listItemGap),
            ReadingProgressBar(percent: snapshot.progressPercent),
            const SizedBox(height: 8),
            Text(_paceLabel(snapshot), style: LuminisTypography.metadata),
            const SizedBox(height: LuminisSpacing.listItemGap),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _open(context, snapshot),
                icon: const Icon(Icons.menu_book),
                label: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PausedReadingCard extends StatelessWidget {
  const _PausedReadingCard({required this.snapshot});

  final ReadingStateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: snapshot.title,
      coverUrl: snapshot.bookshelfItem.summary?.coverUrl,
      metadata: '${snapshot.authorLabel} · ${_progressLabel(snapshot)}',
      status: BookshelfStatusChip(status: snapshot.bookshelfItem.readingStatus),
      trailing: TextButton(
        onPressed: () => _open(context, snapshot),
        child: const Text('Retomar'),
      ),
      onTap: () => _open(context, snapshot),
    );
  }
}

void _open(BuildContext context, ReadingStateSnapshot snapshot) {
  context.pushNamed(
    AppRouteNames.readingState,
    pathParameters: {'bookshelfItemId': snapshot.bookshelfItem.id},
  );
}

String _progressLabel(ReadingStateSnapshot snapshot) {
  final page = snapshot.currentPage;
  final pageCount = snapshot.pageCount;
  if (page != null && pageCount != null) return 'página $page de $pageCount';
  if (page != null) return 'página $page';
  if (snapshot.progressPercent > 0) return '${snapshot.progressPercent}% lido';
  return 'sem progresso registrado';
}

String _paceLabel(ReadingStateSnapshot snapshot) {
  final pace = snapshot.pace;
  if (pace.canCalculate) {
    return 'Leia ${pace.dailyPagesTarget} páginas por dia para manter o plano.';
  }
  return pace.reason ?? 'Ritmo indisponível no momento.';
}
