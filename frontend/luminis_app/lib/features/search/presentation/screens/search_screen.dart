import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
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
  });

  final BookSearchState state;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) => switch (state) {
    BookSearchIdle() => const LuminisEmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Encontre sua próxima leitura',
      description: 'Busque por título, autor, editora, assunto ou ISBN.',
    ),
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

String _searchTypeLabel(BookSearchType type) => switch (type) {
  BookSearchType.all => 'Todos',
  BookSearchType.title => 'Título',
  BookSearchType.author => 'Autor',
  BookSearchType.publisher => 'Editora',
  BookSearchType.subject => 'Assunto',
  BookSearchType.isbn => 'ISBN',
};
