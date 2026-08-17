import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/bookshelf/data/fixtures/bookshelf_fixtures.dart';
import 'package:luminis_app/features/bookshelf/data/providers/bookshelf_providers.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_target.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/presentation/controllers/add_to_bookshelf_controller.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_bookshelf_repository.dart';

void main() {
  group('AddToBookshelfController', () {
    test('addFromCatalog com sucesso guarda o item criado', () async {
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
        onAddBookItem:
            ({
              required bookId,
              required editionId,
              required readingStatus,
            }) async {
              return BookshelfItem(
                id: 'bookshelf_item_new',
                target: BookshelfBookTarget(
                  bookId: bookId,
                  editionId: editionId,
                ),
                readingStatus: readingStatus,
                addedAt: DateTime.utc(2026, 1, 1),
                updatedAt: DateTime.utc(2026, 1, 1),
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(addToBookshelfControllerProvider.notifier)
          .addFromCatalog(
            bookId: 'book_x',
            editionId: 'edition_x',
            readingStatus: ReadingStatus.wantToRead,
          );

      final state = container.read(addToBookshelfControllerProvider);
      expect(state.status, FormSubmissionStatus.success);
      expect(state.createdItem?.id, 'bookshelf_item_new');
    });

    test('addFromCatalog com item já existente sinaliza isDuplicate', () async {
      final repository = FakeBookshelfRepository(
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
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(addToBookshelfControllerProvider.notifier)
          .addFromCatalog(
            bookId: BookshelfFixtures.wantToReadQuincasBorba.id,
            editionId: 'edition_quincas_borba_companhia',
            readingStatus: ReadingStatus.wantToRead,
          );

      final state = container.read(addToBookshelfControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.isDuplicate, isTrue);
    });

    test('addFromDraft com falha genérica não marca isDuplicate', () async {
      final repository = FakeBookshelfRepository(
        onAddDraftItem:
            ({required userBookDraftId, required readingStatus}) async {
              throw const ApiNetworkFailure('Sem conexão.');
            },
      );
      final container = ProviderContainer.test(
        overrides: [bookshelfRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(addToBookshelfControllerProvider.notifier)
          .addFromDraft(
            userBookDraftId: 'draft_x',
            readingStatus: ReadingStatus.wantToRead,
          );

      final state = container.read(addToBookshelfControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.isDuplicate, isFalse);
    });
  });
}
