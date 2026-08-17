import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/book_cover.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../bookshelf/domain/entities/bookshelf_item.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../../bookshelf/presentation/controllers/add_to_bookshelf_controller.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/entities/edition.dart';
import '../controllers/book_detail_controller.dart';

/// Detalhe de obra/edição (`/books/:bookId`), empilhada sobre a branch
/// Buscar do shell autenticado.
///
class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  String? _selectedEditionId;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(bookDetailControllerProvider(widget.bookId));
    return Scaffold(
      body: switch (detail) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => _BookDetailError(
          onRetry: () =>
              ref.invalidate(bookDetailControllerProvider(widget.bookId)),
        ),
        AsyncData(:final value) => _BookDetailView(
          detail: value,
          selectedEditionId: _selectedEditionId,
          onEditionSelected: (edition) =>
              setState(() => _selectedEditionId = edition.id),
          onAdd: () => _addToBookshelf(context, value),
        ),
      },
    );
  }

  Future<void> _addToBookshelf(BuildContext context, BookDetail detail) async {
    final edition = detail.editions.firstWhere(
      (item) => item.id == _selectedEditionId,
      orElse: () => detail.editions.first,
    );
    final item = await showModalBottomSheet<BookshelfItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _AddToBookshelfSheet(bookId: detail.book.id, edition: edition),
    );
    if (!context.mounted || item == null) return;
    if (item.readingStatus == ReadingStatus.reading) {
      context.goNamed(
        AppRouteNames.readingState,
        pathParameters: {'bookshelfItemId': item.id},
      );
    } else {
      context.goNamed(AppRouteNames.bookshelf);
    }
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView({
    required this.detail,
    required this.selectedEditionId,
    required this.onEditionSelected,
    required this.onAdd,
  });

  final BookDetail detail;
  final String? selectedEditionId;
  final ValueChanged<Edition> onEditionSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final selected = detail.editions.firstWhere(
      (edition) => edition.id == selectedEditionId,
      orElse: () => detail.editions.first,
    );
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 270,
          backgroundColor: LuminisColors.ink,
          foregroundColor: LuminisColors.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Center(
                child: BookCover(
                  title: selected.title,
                  coverUrl: selected.coverUrl,
                  width: 140,
                  height: 210,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(detail.book.title, style: LuminisTypography.screenTitle),
              const SizedBox(height: 4),
              Text(
                detail.book.authors.map((author) => author.name).join(', '),
                style: LuminisTypography.body,
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar à estante'),
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Sinopse', style: LuminisTypography.sectionTitle),
              const SizedBox(height: 8),
              Text(
                detail.book.description ??
                    'Sinopse ainda não disponível para esta obra.',
                style: LuminisTypography.body,
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Dados da edição', style: LuminisTypography.sectionTitle),
              const SizedBox(height: 8),
              _EditionMetadata(edition: selected),
              if (detail.book.subjects.isNotEmpty) ...[
                const SizedBox(height: LuminisSpacing.sectionGap),
                Text('Gêneros', style: LuminisTypography.sectionTitle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final subject in detail.book.subjects)
                      Chip(label: Text(subject.name)),
                  ],
                ),
              ],
              if (detail.editions.length > 1) ...[
                const SizedBox(height: LuminisSpacing.sectionGap),
                Text('Outras edições', style: LuminisTypography.sectionTitle),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: selected.id,
                  onChanged: (editionId) {
                    if (editionId == null) return;
                    onEditionSelected(
                      detail.editions.firstWhere(
                        (edition) => edition.id == editionId,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      for (final edition in detail.editions)
                        Card(
                          child: RadioListTile<String>(
                            value: edition.id,
                            title: Text(edition.publisher.name),
                            subtitle: Text(_editionDescription(edition)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _EditionMetadata extends StatelessWidget {
  const _EditionMetadata({required this.edition});

  final Edition edition;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('Editora', edition.publisher.name),
      if (edition.publishedYear != null) ('Ano', '${edition.publishedYear}'),
      if (edition.pageCount != null) ('Páginas', '${edition.pageCount}'),
      if (edition.isbn13 != null) ('ISBN-13', edition.isbn13!),
      if (edition.language != null) ('Idioma', edition.language!),
      if (edition.format != null) ('Formato', edition.format!),
    ];
    return Wrap(
      spacing: LuminisSpacing.sectionGap,
      runSpacing: LuminisSpacing.listItemGap,
      children: [
        for (final entry in entries)
          SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.$1, style: LuminisTypography.metadata),
                Text(entry.$2, style: LuminisTypography.body),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddToBookshelfSheet extends ConsumerStatefulWidget {
  const _AddToBookshelfSheet({required this.bookId, required this.edition});

  final String bookId;
  final Edition edition;

  @override
  ConsumerState<_AddToBookshelfSheet> createState() =>
      _AddToBookshelfSheetState();
}

class _AddToBookshelfSheetState extends ConsumerState<_AddToBookshelfSheet> {
  ReadingStatus _status = ReadingStatus.wantToRead;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addToBookshelfControllerProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          LuminisSpacing.screenMargin,
          LuminisSpacing.sectionGap,
          LuminisSpacing.screenMargin,
          MediaQuery.viewInsetsOf(context).bottom + LuminisSpacing.sectionGap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adicionar à estante', style: LuminisTypography.sectionTitle),
            const SizedBox(height: 4),
            Text(widget.edition.title, style: LuminisTypography.body),
            const SizedBox(height: LuminisSpacing.listItemGap),
            SegmentedButton<ReadingStatus>(
              segments: const [
                ButtonSegment(
                  value: ReadingStatus.wantToRead,
                  label: Text('Quero ler'),
                ),
                ButtonSegment(
                  value: ReadingStatus.reading,
                  label: Text('Lendo'),
                ),
                ButtonSegment(value: ReadingStatus.read, label: Text('Lido')),
              ],
              selected: {_status},
              onSelectionChanged: (selection) =>
                  setState(() => _status = selection.single),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: LuminisTypography.body.copyWith(
                  color: LuminisColors.coral,
                ),
              ),
            ],
            const SizedBox(height: LuminisSpacing.listItemGap),
            ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(addToBookshelfControllerProvider.notifier)
        .addFromCatalog(
          bookId: widget.bookId,
          editionId: widget.edition.id,
          readingStatus: _status,
        );
    final state = ref.read(addToBookshelfControllerProvider);
    if (!mounted || !state.isSuccess || state.createdItem == null) return;
    Navigator.pop(context, state.createdItem);
  }
}

class _BookDetailError extends StatelessWidget {
  const _BookDetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: LuminisEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Não foi possível carregar este livro',
      description: 'Tente novamente em alguns instantes.',
      actionLabel: 'Tentar novamente',
      onAction: onRetry,
    ),
  );
}

String _editionDescription(Edition edition) => [
  edition.publisher.name,
  if (edition.language != null) edition.language!,
  if (edition.format != null) edition.format!,
  if (edition.pageCount != null) '${edition.pageCount} páginas',
].join(' · ');
