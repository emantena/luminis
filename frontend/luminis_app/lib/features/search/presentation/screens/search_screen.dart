import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/book_card.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../books/domain/value_objects/book_search_type.dart';
import '../../../books/presentation/controllers/book_search_controller.dart';
import '../../../books/presentation/state/book_search_state.dart';

/// Aba raiz Buscar (`/search`).
///
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  BookSearchType _type = BookSearchType.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookSearchControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminisSpacing.screenMargin,
              LuminisSpacing.listItemGap,
              LuminisSpacing.screenMargin,
              0,
            ),
            child: SearchBar(
              controller: _queryController,
              hintText: 'Título, autor, editora ou ISBN',
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(
                LuminisColors.surface,
              ),
              surfaceTintColor: const WidgetStatePropertyAll(
                LuminisColors.surface,
              ),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              side: const WidgetStatePropertyAll(
                BorderSide(color: LuminisColors.line),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LuminisRadii.card),
                ),
              ),
              leading: const Icon(Icons.search),
              trailing: [
                if (_queryController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Limpar busca',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                  ),
              ],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(),
            ),
          ),
          _SearchTypeFilters(
            selected: _type,
            onSelected: (type) => setState(() => _type = type),
          ),
          Expanded(
            child: _SearchContent(
              state: state,
              onRetry: _search,
              onLoadMore: () =>
                  ref.read(bookSearchControllerProvider.notifier).loadMore(),
              onQuickSearch: _quickSearch,
            ),
          ),
        ],
      ),
    );
  }

  void _search() => ref
      .read(bookSearchControllerProvider.notifier)
      .search(query: _queryController.text, type: _type);

  void _clearSearch() {
    _queryController.clear();
    ref.read(bookSearchControllerProvider.notifier).reset();
    setState(() {});
  }

  void _quickSearch(String query) {
    _queryController.text = query;
    ref
        .read(bookSearchControllerProvider.notifier)
        .search(query: query, type: _type);
    setState(() {});
  }
}

class _SearchTypeFilters extends StatelessWidget {
  const _SearchTypeFilters({required this.selected, required this.onSelected});

  final BookSearchType selected;
  final ValueChanged<BookSearchType> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: LuminisSpacing.screenMargin,
      vertical: LuminisSpacing.listItemGap,
    ),
    child: Row(
      children: [
        for (final type in BookSearchType.values) ...[
          ChoiceChip(
            label: Text(_searchTypeLabel(type)),
            selected: selected == type,
            onSelected: (_) => onSelected(type),
          ),
          const SizedBox(width: 8),
        ],
      ],
    ),
  );
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({
    required this.state,
    required this.onRetry,
    required this.onLoadMore,
    required this.onQuickSearch,
  });

  final BookSearchState state;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onQuickSearch;

  @override
  Widget build(BuildContext context) => switch (state) {
    BookSearchIdle() => _SearchDiscovery(onQuickSearch: onQuickSearch),
    BookSearchLoading() => const Center(child: CircularProgressIndicator()),
    BookSearchEmpty() => LuminisEmptyState(
      icon: Icons.search_off_outlined,
      title: 'Nenhum resultado encontrado',
      description: 'Tente outro termo ou crie um cadastro local privado.',
      actionLabel: 'Criar cadastro local',
      onAction: () => context.pushNamed(AppRouteNames.bookDraftNew),
    ),
    BookSearchError(:final message) => LuminisEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Não foi possível buscar livros agora',
      description: message,
      actionLabel: 'Tentar novamente',
      onAction: onRetry,
    ),
    BookSearchData(:final items, :final hasNextPage) => ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        LuminisSpacing.screenMargin,
        0,
        LuminisSpacing.screenMargin,
        LuminisSpacing.sectionGap,
      ),
      itemCount: items.length + (hasNextPage ? 1 : 0),
      separatorBuilder: (_, _) =>
          const SizedBox(height: LuminisSpacing.listItemGap),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return OutlinedButton(
            onPressed: onLoadMore,
            child: const Text('Carregar mais'),
          );
        }
        final item = items[index];
        final edition = item.edition;
        return BookCard(
          title: item.book.title,
          coverUrl: edition.coverUrl,
          metadata: [
            item.book.authors.map((author) => author.name).join(', '),
            edition.publisher.name,
            if (edition.language != null) edition.language!,
            if (edition.pageCount != null) '${edition.pageCount} páginas',
          ].join(' · '),
          onTap: () => context.pushNamed(
            AppRouteNames.bookDetail,
            pathParameters: {'bookId': item.book.id},
          ),
          semanticLabel: 'Abrir ${item.book.title}',
        );
      },
    ),
  };
}

class _SearchDiscovery extends StatelessWidget {
  const _SearchDiscovery({required this.onQuickSearch});

  final ValueChanged<String> onQuickSearch;

  static const _suggestions = [
    ('Machado de Assis', Icons.auto_stories_outlined),
    ('Clarice Lispector', Icons.edit_note_outlined),
    ('Romance', Icons.favorite_border),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LuminisSpacing.screenMargin,
        LuminisSpacing.sectionGap,
        LuminisSpacing.screenMargin,
        LuminisSpacing.sectionGap,
      ),
      children: [
        const LuminisEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Encontre sua próxima leitura',
          description: 'Busque por título, autor, editora, assunto ou ISBN.',
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        Text('Comece por aqui', style: LuminisTypography.sectionTitle),
        const SizedBox(height: LuminisSpacing.listItemGap),
        for (final suggestion in _suggestions) ...[
          _DiscoverySuggestion(
            label: suggestion.$1,
            icon: suggestion.$2,
            onTap: () => onQuickSearch(suggestion.$1),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
        ],
      ],
    );
  }
}

class _DiscoverySuggestion extends StatelessWidget {
  const _DiscoverySuggestion({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buscar $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LuminisColors.surface,
          border: Border.all(color: LuminisColors.line),
          borderRadius: BorderRadius.circular(LuminisRadii.card),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(LuminisRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(LuminisSpacing.listItemGap),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Icon(icon, color: LuminisColors.primary),
                ),
                const SizedBox(width: LuminisSpacing.listItemGap),
                Expanded(
                  child: Text(label, style: LuminisTypography.cardTitle),
                ),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _searchTypeLabel(BookSearchType type) => switch (type) {
  BookSearchType.all => 'Todos',
  BookSearchType.title => 'Título',
  BookSearchType.author => 'Autor',
  BookSearchType.publisher => 'Editora',
  BookSearchType.subject => 'Assunto',
  BookSearchType.isbn => 'ISBN',
};
