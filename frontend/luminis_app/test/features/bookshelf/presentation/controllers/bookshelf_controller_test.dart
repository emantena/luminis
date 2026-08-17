import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/bookshelf/data/fixtures/bookshelf_fixtures.dart';
import 'package:luminis_app/features/bookshelf/data/providers/bookshelf_providers.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/presentation/controllers/bookshelf_controller.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_bookshelf_repository.dart';

void main() {
  group('BookshelfController', () {
    test('build carrega os itens do repository', () async {
      final repository = FakeBookshelfRepository(
        onListItems:
            ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
              return BookshelfListResult(
                items: BookshelfFixtures.all,
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      final items = await container.read(bookshelfControllerProvider.future);

      expect(items, hasLength(6));
    });

    test('estado vazio quando não há itens ativos', () async {
      final repository = FakeBookshelfRepository(
        onListItems:
            ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
              return const BookshelfListResult(
                items: [],
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      final items = await container.read(bookshelfControllerProvider.future);

      expect(items, isEmpty);
    });

    test('erro do repository termina em AsyncError', () async {
      final repository = FakeBookshelfRepository(
        onListItems:
            ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
              throw const ApiNetworkFailure('Sem conexão.');
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await expectLater(
        container.read(bookshelfControllerProvider.future),
        throwsA(isA<ApiNetworkFailure>()),
      );
    });

    test('applyFilter recarrega a lista com o novo filtro', () async {
      BookshelfFilter? receivedFilter;
      final repository = FakeBookshelfRepository(
        onListItems:
            ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
              receivedFilter = filter;
              return const BookshelfListResult(
                items: [],
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );
      await container.read(bookshelfControllerProvider.future);

      const filter = BookshelfFilter(readingStatus: ReadingStatus.reading);
      await container
          .read(bookshelfControllerProvider.notifier)
          .applyFilter(filter);

      expect(receivedFilter, filter);
      expect(
        container.read(bookshelfControllerProvider.notifier).filter,
        filter,
      );
    });

    test(
      'addBookItem propaga ApiConflictFailure sem substituir a lista atual por erro',
      () async {
        final repository = FakeBookshelfRepository(
          onListItems:
              ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
                return BookshelfListResult(
                  items: BookshelfFixtures.all,
                  page: 1,
                  limit: 20,
                  hasNextPage: false,
                );
              },
          onAddBookItem:
              ({
                required bookId,
                required editionId,
                required readingStatus,
              }) async {
                throw const ApiConflictFailure(
                  code: 'bookshelf.item_already_exists',
                  message: 'Esta edição já está na sua estante.',
                  statusCode: 409,
                );
              },
        );
        final container = ProviderContainer.test(
          overrides: [
            bookshelfRepositoryProvider.overrideWithValue(repository),
          ],
        );
        await container.read(bookshelfControllerProvider.future);

        await expectLater(
          container
              .read(bookshelfControllerProvider.notifier)
              .addBookItem(
                bookId: 'book_x',
                editionId: 'edition_x',
                readingStatus: ReadingStatus.wantToRead,
              ),
          throwsA(isA<ApiConflictFailure>()),
        );

        final state = container.read(bookshelfControllerProvider);
        expect(state, isA<AsyncData<List<BookshelfItem>>>());
        expect(state.value, hasLength(6));
      },
    );

    test('removeItem recarrega a lista após sucesso', () async {
      var listCallCount = 0;
      final repository = FakeBookshelfRepository(
        onListItems:
            ({filter = const BookshelfFilter(), page = 1, limit = 20}) async {
              listCallCount++;
              return BookshelfListResult(
                items: listCallCount == 1
                    ? BookshelfFixtures.all
                    : BookshelfFixtures.all
                          .where(
                            (item) => item.id != BookshelfFixtures.paused.id,
                          )
                          .toList(),
                page: 1,
                limit: 20,
                hasNextPage: false,
              );
            },
        onRemoveItem: ({required bookshelfItemId}) async {},
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );
      await container.read(bookshelfControllerProvider.future);

      await container
          .read(bookshelfControllerProvider.notifier)
          .removeItem(bookshelfItemId: BookshelfFixtures.paused.id);

      final items = container.read(bookshelfControllerProvider).value!;
      expect(items, hasLength(5));
    });
  });
}
