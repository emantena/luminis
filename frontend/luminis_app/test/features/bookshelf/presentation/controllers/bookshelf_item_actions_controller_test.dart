import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/bookshelf/data/fixtures/bookshelf_fixtures.dart';
import 'package:luminis_app/features/bookshelf/data/providers/bookshelf_providers.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tags_patch.dart';
import 'package:luminis_app/features/bookshelf/presentation/controllers/bookshelf_item_actions_controller.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_bookshelf_repository.dart';

void main() {
  group('BookshelfItemActionsController', () {
    test('changeReadingStatus com sucesso termina em success', () async {
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
        onUpdateReadingStatus:
            ({required bookshelfItemId, required readingStatus}) async {
              return BookshelfFixtures.reading.copyWith(
                readingStatus: readingStatus,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(
            bookshelfItemActionsControllerProvider(
              BookshelfFixtures.reading.id,
            ).notifier,
          )
          .changeReadingStatus(ReadingStatus.paused);

      final state = container.read(
        bookshelfItemActionsControllerProvider(BookshelfFixtures.reading.id),
      );
      expect(state.status, FormSubmissionStatus.success);
    });

    test('changeTags com falha do repository termina em erro', () async {
      final repository = FakeBookshelfRepository(
        onUpdateTags: ({required bookshelfItemId, required tags}) async {
          throw const ApiValidationFailure(
            code: 'validation.failed',
            message: 'Existem campos inválidos.',
            statusCode: 400,
            fieldErrors: {
              'tags': ['Informe ao menos uma etiqueta.'],
            },
          );
        },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(
            bookshelfItemActionsControllerProvider(
              BookshelfFixtures.reading.id,
            ).notifier,
          )
          .changeTags(const BookshelfTagsPatch());

      final state = container.read(
        bookshelfItemActionsControllerProvider(BookshelfFixtures.reading.id),
      );
      expect(state.status, FormSubmissionStatus.error);
    });

    test('remove com sucesso termina em success', () async {
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
        onRemoveItem: ({required bookshelfItemId}) async {},
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(
            bookshelfItemActionsControllerProvider(
              BookshelfFixtures.paused.id,
            ).notifier,
          )
          .remove();

      final state = container.read(
        bookshelfItemActionsControllerProvider(BookshelfFixtures.paused.id),
      );
      expect(state.status, FormSubmissionStatus.success);
    });
  });
}
