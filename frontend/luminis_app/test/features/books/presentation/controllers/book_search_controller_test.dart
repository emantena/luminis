import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/fixtures/book_catalog_fixtures.dart';
import 'package:luminis_app/features/books/data/providers/book_providers.dart';
import 'package:luminis_app/features/books/domain/entities/book_search_item.dart';
import 'package:luminis_app/features/books/domain/value_objects/book_search_type.dart';
import 'package:luminis_app/features/books/presentation/controllers/book_search_controller.dart';
import 'package:luminis_app/features/books/presentation/state/book_search_state.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_book_catalog_repository.dart';

void main() {
  group('BookSearchController', () {
    test('inicia em BookSearchIdle', () {
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(
            FakeBookCatalogRepository(),
          ),
        ],
      );

      expect(
        container.read(bookSearchControllerProvider),
        isA<BookSearchIdle>(),
      );
    });

    test(
      'query vazia mantém/retorna estado idle sem chamar o repository',
      () async {
        final repository = FakeBookCatalogRepository();
        final container = ProviderContainer.test(
          overrides: [
            bookCatalogRepositoryProvider.overrideWithValue(repository),
          ],
        );

        await container
            .read(bookSearchControllerProvider.notifier)
            .search(query: '   ');

        expect(
          container.read(bookSearchControllerProvider),
          isA<BookSearchIdle>(),
        );
        expect(repository.searchCallCount, 0);
      },
    );

    test('busca com resultado termina em BookSearchData', () async {
      final repository = FakeBookCatalogRepository(
        onSearch:
            ({
              required query,
              type = BookSearchType.all,
              page = 1,
              limit = 20,
            }) async {
              return BookCatalogSearchResult(
                items: const [BookCatalogFixtures.brasCubasSearchItem],
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await container
          .read(bookSearchControllerProvider.notifier)
          .search(query: 'Brás Cubas');

      final state = container.read(bookSearchControllerProvider);
      expect(state, isA<BookSearchData>());
      expect((state as BookSearchData).items, hasLength(1));
    });

    test('busca sem resultado termina em BookSearchEmpty', () async {
      final repository = FakeBookCatalogRepository(
        onSearch:
            ({
              required query,
              type = BookSearchType.all,
              page = 1,
              limit = 20,
            }) async {
              return const BookCatalogSearchResult(
                items: [],
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await container
          .read(bookSearchControllerProvider.notifier)
          .search(query: 'inexistente');

      expect(
        container.read(bookSearchControllerProvider),
        isA<BookSearchEmpty>(),
      );
    });

    test('falha do provedor termina em BookSearchError', () async {
      final repository = FakeBookCatalogRepository(
        onSearch:
            ({
              required query,
              type = BookSearchType.all,
              page = 1,
              limit = 20,
            }) async {
              throw const ApiServiceUnavailableFailure(
                code: 'catalog.provider_unavailable',
                message: 'O catálogo está temporariamente indisponível.',
                statusCode: 503,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await container
          .read(bookSearchControllerProvider.notifier)
          .search(query: BookCatalogFixtures.providerUnavailableQuery);

      final state = container.read(bookSearchControllerProvider);
      expect(state, isA<BookSearchError>());
    });

    test(
      'loadMore concatena a próxima página aos itens já carregados',
      () async {
        var callCount = 0;
        final repository = FakeBookCatalogRepository(
          onSearch:
              ({
                required query,
                type = BookSearchType.all,
                page = 1,
                limit = 20,
              }) async {
                callCount++;
                return BookCatalogSearchResult(
                  items: callCount == 1
                      ? const [BookCatalogFixtures.brasCubasSearchItem]
                      : const [
                          BookCatalogFixtures.domCasmurroCompanhiaSearchItem,
                        ],
                  page: page,
                  limit: 20,
                  hasNextPage: callCount == 1,
                );
              },
        );
        final container = ProviderContainer.test(
          overrides: [
            bookCatalogRepositoryProvider.overrideWithValue(repository),
          ],
        );
        final controller = container.read(
          bookSearchControllerProvider.notifier,
        );
        await controller.search(query: 'Machado');

        await controller.loadMore();

        final state = container.read(bookSearchControllerProvider);
        expect(state, isA<BookSearchData>());
        expect((state as BookSearchData).items, hasLength(2));
        expect(state.hasNextPage, isFalse);
      },
    );
  });
}
