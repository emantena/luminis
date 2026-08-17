import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/book_card.dart';
import '../../../../shared/presentation/widgets/bookshelf_status_chip.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/value_objects/bookshelf_filter.dart';
import '../../domain/value_objects/bookshelf_tags_patch.dart';
import '../controllers/bookshelf_controller.dart';
import '../controllers/bookshelf_item_actions_controller.dart';

/// Aba raiz Estante (`/bookshelf`).
///
class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({super.key});

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen> {
  ReadingStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(bookshelfControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estante'),
        actions: [
          IconButton(
            tooltip: 'Buscar livros',
            onPressed: () => context.goNamed(AppRouteNames.search),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: switch (items) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => _BookshelfLoadError(
          onRetry: () =>
              ref.read(bookshelfControllerProvider.notifier).refresh(),
        ),
        AsyncData(:final value) when value.isEmpty => LuminisEmptyState(
          icon: Icons.auto_stories_outlined,
          title: 'Sua estante ainda está vazia',
          description:
              'Encontre um livro para começar a organizar suas leituras.',
          actionLabel: 'Buscar livros',
          onAction: () => context.goNamed(AppRouteNames.search),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () =>
              ref.read(bookshelfControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LuminisSpacing.screenMargin,
              LuminisSpacing.listItemGap,
              LuminisSpacing.screenMargin,
              LuminisSpacing.sectionGap,
            ),
            children: [
              _NowReading(items: value),
              const SizedBox(height: LuminisSpacing.sectionGap),
              _StatusFilters(
                selectedStatus: _selectedStatus,
                onSelected: _applyStatusFilter,
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Meus livros', style: LuminisTypography.sectionTitle),
              const SizedBox(height: LuminisSpacing.listItemGap),
              for (final item in value) ...[
                _BookshelfItemCard(item: item),
                const SizedBox(height: LuminisSpacing.listItemGap),
              ],
            ],
          ),
        ),
      },
    );
  }

  Future<void> _applyStatusFilter(ReadingStatus? status) async {
    setState(() => _selectedStatus = status);
    await ref
        .read(bookshelfControllerProvider.notifier)
        .applyFilter(BookshelfFilter(readingStatus: status));
  }
}

class _NowReading extends StatelessWidget {
  const _NowReading({required this.items});

  final List<BookshelfItem> items;

  @override
  Widget build(BuildContext context) {
    final current = items
        .where((item) => item.readingStatus == ReadingStatus.reading)
        .firstOrNull;
    if (current == null) return const SizedBox.shrink();
    final summary = current.summary;
    return Card(
      color: LuminisColors.ink,
      child: ListTile(
        title: Text(
          'Lendo agora',
          style: LuminisTypography.sectionTitle.copyWith(
            color: LuminisColors.surface,
          ),
        ),
        subtitle: Text(
          summary?.title ?? 'Leitura em andamento',
          style: LuminisTypography.body.copyWith(color: LuminisColors.surface),
        ),
        trailing: const Icon(Icons.menu_book, color: LuminisColors.accent),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.selectedStatus,
    required this.onSelected,
  });

  final ReadingStatus? selectedStatus;
  final ValueChanged<ReadingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: selectedStatus == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final status in ReadingStatus.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(_statusLabel(status)),
              selected: selectedStatus == status,
              onSelected: (_) => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookshelfItemCard extends ConsumerWidget {
  const _BookshelfItemCard({required this.item});

  final BookshelfItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = item.summary;
    return BookCard(
      title: summary?.title ?? 'Livro da estante',
      coverUrl: summary?.coverUrl,
      metadata: [
        summary?.authorLabel ?? 'Dados da edição indisponíveis',
        if (summary?.editionLabel.isNotEmpty ?? false) summary!.editionLabel,
      ].join(' · '),
      status: BookshelfStatusChip(status: item.readingStatus),
      semanticLabel:
          '${summary?.title ?? 'Livro'} — ${_statusLabel(item.readingStatus)}',
      onTap: () => context.pushNamed(
        AppRouteNames.readingState,
        pathParameters: {'bookshelfItemId': item.id},
      ),
      trailing: PopupMenuButton<_ItemAction>(
        tooltip: 'Ações da estante',
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _ItemAction.favorite,
            child: Text(
              item.tags.isFavorite ? 'Remover dos favoritos' : 'Favoritar',
            ),
          ),
          const PopupMenuItem(
            value: _ItemAction.remove,
            child: Text('Remover da estante'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ItemAction action,
  ) async {
    final controller = ref.read(
      bookshelfItemActionsControllerProvider(item.id).notifier,
    );
    if (action == _ItemAction.favorite) {
      await controller.changeTags(
        BookshelfTagsPatch(isFavorite: !item.tags.isFavorite),
      );
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remover da estante?'),
          content: const Text(
            'O livro poderá ser adicionado novamente depois.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: LuminisColors.coral,
              ),
              child: const Text('Remover'),
            ),
          ],
        ),
      );
      if (confirmed == true) await controller.remove();
    }
    if (!context.mounted) return;
    final state = ref.read(bookshelfItemActionsControllerProvider(item.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ??
              (action == _ItemAction.remove
                  ? 'Livro removido da estante.'
                  : 'Etiquetas atualizadas.'),
        ),
      ),
    );
  }
}

class _BookshelfLoadError extends StatelessWidget {
  const _BookshelfLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => LuminisEmptyState(
    icon: Icons.cloud_off_outlined,
    title: 'Não foi possível carregar os livros agora',
    description: 'Verifique sua conexão e tente novamente.',
    actionLabel: 'Tentar novamente',
    onAction: onRetry,
  );
}

enum _ItemAction { favorite, remove }

String _statusLabel(ReadingStatus status) => switch (status) {
  ReadingStatus.wantToRead => 'Quero ler',
  ReadingStatus.reading => 'Lendo',
  ReadingStatus.paused => 'Pausado',
  ReadingStatus.read => 'Lido',
  ReadingStatus.rereading => 'Relendo',
  ReadingStatus.abandoned => 'Abandonei',
};
