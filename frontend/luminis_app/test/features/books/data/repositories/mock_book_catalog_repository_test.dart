import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/fixtures/book_catalog_fixtures.dart';
import 'package:luminis_app/features/books/data/repositories/mock_book_catalog_repository.dart';
import 'package:luminis_app/features/books/domain/value_objects/book_search_type.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('MockBookCatalogRepository', () {
    late MockBookCatalogRepository repository;

    setUp(() {
      repository = MockBookCatalogRepository();
    });

    test('busca por título encontra livro com uma única edição', () async {
      final result = await repository.search(
        query: 'Memórias Póstumas',
        type: BookSearchType.title,
      );

      expect(result.items, hasLength(1));
      expect(result.items.single.book.id, BookCatalogFixtures.brasCubas.id);
      expect(
        result.items.single.edition.id,
        BookCatalogFixtures.brasCubasEdition.id,
      );
      expect(result.hasNextPage, isFalse);
    });

    test('busca por autor encontra livro com múltiplas edições', () async {
      final result = await repository.search(
        query: 'Machado de Assis',
        type: BookSearchType.author,
      );

      final domCasmurroItems = result.items.where(
        (item) => item.book.id == BookCatalogFixtures.domCasmurro.id,
      );
      expect(domCasmurroItems, hasLength(2));
      expect(
        domCasmurroItems.map((item) => item.edition.id),
        containsAll(<String>[
          BookCatalogFixtures.domCasmurroCompanhiaEdition.id,
          BookCatalogFixtures.domCasmurroPopularEdition.id,
        ]),
      );
    });

    test('edição inclui editora com logoUrl quando cadastrado', () async {
      final result = await repository.search(
        query: 'Dom Casmurro',
        type: BookSearchType.title,
      );

      final companhiaItem = result.items.firstWhere(
        (item) =>
            item.edition.id ==
            BookCatalogFixtures.domCasmurroCompanhiaEdition.id,
      );
      expect(companhiaItem.edition.publisher.logoUrl, isNotNull);
    });

    test('edição inclui editora sem logoUrl quando não cadastrado', () async {
      final result = await repository.search(
        query: 'Dom Casmurro',
        type: BookSearchType.title,
      );

      final popularItem = result.items.firstWhere(
        (item) =>
            item.edition.id == BookCatalogFixtures.domCasmurroPopularEdition.id,
      );
      expect(popularItem.edition.publisher.logoUrl, isNull);
    });

    test('busca por editora usa type=publisher', () async {
      final result = await repository.search(
        query: 'Editora Popular',
        type: BookSearchType.publisher,
      );

      expect(result.items, hasLength(1));
      expect(
        result.items.single.edition.id,
        BookCatalogFixtures.domCasmurroPopularEdition.id,
      );
    });

    test('busca sem correspondência retorna items vazio, não erro', () async {
      final result = await repository.search(query: 'inexistente-xyz');

      expect(result.items, isEmpty);
      expect(result.hasNextPage, isFalse);
    });

    test(
      'termo de busca reservado simula indisponibilidade de provedor',
      () async {
        await expectLater(
          repository.search(
            query: BookCatalogFixtures.providerUnavailableQuery,
          ),
          throwsA(
            isA<ApiServiceUnavailableFailure>().having(
              (failure) => failure.code,
              'code',
              'catalog.provider_unavailable',
            ),
          ),
        );
      },
    );

    test(
      'getBookDetail retorna a obra com todas as edições conhecidas',
      () async {
        final detail = await repository.getBookDetail(
          bookId: BookCatalogFixtures.domCasmurro.id,
        );

        expect(detail.book.id, BookCatalogFixtures.domCasmurro.id);
        expect(detail.editions, hasLength(2));
      },
    );

    test(
      'getBookDetail lança catalog.book_not_found para id desconhecido',
      () async {
        await expectLater(
          repository.getBookDetail(bookId: 'book_inexistente'),
          throwsA(
            isA<ApiNotFoundFailure>().having(
              (failure) => failure.code,
              'code',
              'catalog.book_not_found',
            ),
          ),
        );
      },
    );

    test('searchByIsbn encontra edição por isbn13', () async {
      final item = await repository.searchByIsbn(
        isbn: BookCatalogFixtures.brasCubasEdition.isbn13!,
      );

      expect(item.edition.id, BookCatalogFixtures.brasCubasEdition.id);
    });

    test(
      'searchByIsbn lança catalog.isbn_not_found quando não encontrado',
      () async {
        await expectLater(
          repository.searchByIsbn(isbn: '0000000000000'),
          throwsA(
            isA<ApiNotFoundFailure>().having(
              (failure) => failure.code,
              'code',
              'catalog.isbn_not_found',
            ),
          ),
        );
      },
    );
  });
}
