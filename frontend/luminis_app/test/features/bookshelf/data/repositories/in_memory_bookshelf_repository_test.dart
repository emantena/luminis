import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/fixtures/book_catalog_fixtures.dart';
import 'package:luminis_app/features/bookshelf/data/fixtures/bookshelf_fixtures.dart';
import 'package:luminis_app/features/bookshelf/data/repositories/in_memory_bookshelf_repository.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_target.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tag_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tags_patch.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('InMemoryBookshelfRepository', () {
    test('fixtures cobrem os 6 valores de ReadingStatus', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final result = await repository.listItems();

      expect(
        result.items.map((item) => item.readingStatus).toSet(),
        ReadingStatus.values.toSet(),
      );
    });

    test('listItems filtra por readingStatus', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final result = await repository.listItems(
        filter: const BookshelfFilter(readingStatus: ReadingStatus.reading),
      );

      expect(result.items, hasLength(1));
      expect(result.items.single.id, BookshelfFixtures.reading.id);
    });

    test('listItems filtra por etiqueta', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final result = await repository.listItems(
        filter: const BookshelfFilter(
          tags: BookshelfTagFilter(isFavorite: true),
        ),
      );

      expect(result.items, hasLength(1));
      expect(result.items.single.id, BookshelfFixtures.read.id);
    });

    test(
      'addBookItem rejeita edição já ativa na estante com bookshelf.item_already_exists',
      () async {
        final repository = InMemoryBookshelfRepository(
          seed: BookshelfFixtures.all,
        );

        await expectLater(
          repository.addBookItem(
            bookId: BookCatalogFixtures.quincasBorba.id,
            editionId: BookCatalogFixtures.quincasBorbaEdition.id,
            readingStatus: ReadingStatus.wantToRead,
          ),
          throwsA(
            isA<ApiConflictFailure>().having(
              (failure) => failure.code,
              'code',
              'bookshelf.item_already_exists',
            ),
          ),
        );
      },
    );

    test('addBookItem aceita edição diferente da mesma obra', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final item = await repository.addBookItem(
        bookId: BookCatalogFixtures.brasCubas.id,
        editionId: 'edition_bras_cubas_outra_tiragem',
        readingStatus: ReadingStatus.wantToRead,
      );

      expect(item.target, isA<BookshelfBookTarget>());
    });

    test('addDraftItem rejeita draft já ativo na estante', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );
      final draftTarget =
          BookshelfFixtures.paused.target as BookshelfDraftTarget;

      await expectLater(
        repository.addDraftItem(
          userBookDraftId: draftTarget.userBookDraftId,
          readingStatus: ReadingStatus.wantToRead,
        ),
        throwsA(isA<ApiConflictFailure>()),
      );
    });

    test('updateReadingStatus para reading define startedAt', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final updated = await repository.updateReadingStatus(
        bookshelfItemId: BookshelfFixtures.wantToReadQuincasBorba.id,
        readingStatus: ReadingStatus.reading,
      );

      expect(updated.readingStatus, ReadingStatus.reading);
      expect(updated.startedAt, isNotNull);
    });

    test('updateReadingStatus para read define finishedAt', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      final updated = await repository.updateReadingStatus(
        bookshelfItemId: BookshelfFixtures.reading.id,
        readingStatus: ReadingStatus.read,
      );

      expect(updated.readingStatus, ReadingStatus.read);
      expect(updated.finishedAt, isNotNull);
    });

    test(
      'updateReadingStatus para id desconhecido lança bookshelf.item_not_found',
      () async {
        final repository = InMemoryBookshelfRepository(
          seed: BookshelfFixtures.all,
        );

        await expectLater(
          repository.updateReadingStatus(
            bookshelfItemId: 'inexistente',
            readingStatus: ReadingStatus.reading,
          ),
          throwsA(
            isA<ApiNotFoundFailure>().having(
              (failure) => failure.code,
              'code',
              'bookshelf.item_not_found',
            ),
          ),
        );
      },
    );

    test(
      'updateTags aplica patch parcial preservando os demais valores',
      () async {
        final repository = InMemoryBookshelfRepository(
          seed: BookshelfFixtures.all,
        );

        final updated = await repository.updateTags(
          bookshelfItemId: BookshelfFixtures.reading.id,
          tags: const BookshelfTagsPatch(isFavorite: true),
        );

        expect(updated.tags.isFavorite, isTrue);
        // isOwned já era true na fixture e não foi enviado no patch.
        expect(updated.tags.isOwned, isTrue);
      },
    );

    test('updateTags com patch vazio lança validation.failed', () async {
      final repository = InMemoryBookshelfRepository(
        seed: BookshelfFixtures.all,
      );

      await expectLater(
        repository.updateTags(
          bookshelfItemId: BookshelfFixtures.reading.id,
          tags: const BookshelfTagsPatch(),
        ),
        throwsA(isA<ApiValidationFailure>()),
      );
    });

    test(
      'removeItem remove o item e chamadas seguintes lançam not_found',
      () async {
        final repository = InMemoryBookshelfRepository(
          seed: BookshelfFixtures.all,
        );

        await repository.removeItem(
          bookshelfItemId: BookshelfFixtures.paused.id,
        );

        final result = await repository.listItems();
        expect(
          result.items.any((item) => item.id == BookshelfFixtures.paused.id),
          isFalse,
        );
        await expectLater(
          repository.removeItem(bookshelfItemId: BookshelfFixtures.paused.id),
          throwsA(isA<ApiNotFoundFailure>()),
        );
      },
    );
  });
}
