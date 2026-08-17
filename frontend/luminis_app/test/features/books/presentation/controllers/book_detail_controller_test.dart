import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/fixtures/book_catalog_fixtures.dart';
import 'package:luminis_app/features/books/data/providers/book_providers.dart';
import 'package:luminis_app/features/books/domain/entities/book_detail.dart';
import 'package:luminis_app/features/books/presentation/controllers/book_detail_controller.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_book_catalog_repository.dart';

void main() {
  group('bookDetailControllerProvider', () {
    test('carrega o detalhe da obra pelo bookId', () async {
      final repository = FakeBookCatalogRepository(
        onGetBookDetail: ({required bookId}) async {
          expect(bookId, BookCatalogFixtures.domCasmurro.id);
          return BookDetail(
            book: BookCatalogFixtures.domCasmurro,
            editions: const [
              BookCatalogFixtures.domCasmurroCompanhiaEdition,
              BookCatalogFixtures.domCasmurroPopularEdition,
            ],
          );
        },
      );
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(repository),
        ],
      );

      final detail = await container.read(
        bookDetailControllerProvider(BookCatalogFixtures.domCasmurro.id).future,
      );

      expect(detail.editions, hasLength(2));
    });

    test('propaga ApiNotFoundFailure quando a obra não existe', () async {
      final repository = FakeBookCatalogRepository(
        onGetBookDetail: ({required bookId}) async {
          throw const ApiNotFoundFailure(
            code: 'catalog.book_not_found',
            message: 'Livro não encontrado.',
            statusCode: 404,
          );
        },
      );
      final container = ProviderContainer.test(
        overrides: [
          bookCatalogRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await expectLater(
        container.read(bookDetailControllerProvider('book_inexistente').future),
        throwsA(isA<ApiNotFoundFailure>()),
      );
    });
  });
}
