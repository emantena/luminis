import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/books/data/repositories/book_catalog_repository_impl.dart';
import 'package:luminis_app/features/books/domain/value_objects/book_search_type.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';

void main() {
  test('search envia bearer e mapeia Book + Edition', () async {
    final repository = BookCatalogRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/books/search');
          expect(request.url.queryParameters['q'], 'Dom Casmurro');
          expect(request.url.queryParameters['type'], 'title');
          expect(request.headers['Authorization'], 'Bearer token-abc');
          return http.Response(jsonEncode(_searchResponse), 200);
        }),
      ),
      bearerToken: 'token-abc',
    );

    final result = await repository.search(
      query: 'Dom Casmurro',
      type: BookSearchType.title,
    );

    expect(result.items.single.book.title, 'Dom Casmurro');
    expect(result.items.single.edition.publisher.name, 'Editora Exemplo');
    expect(result.items.single.edition.isbn13, '9788535910663');
  });

  test('searchByIsbn usa rota exata antes da rota por id', () async {
    final repository = BookCatalogRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/books/isbn/9788535910663');
          return http.Response(
            jsonEncode((_searchResponse['items'] as List<Object?>).first),
            200,
          );
        }),
      ),
      bearerToken: 'token-abc',
    );

    final item = await repository.searchByIsbn(isbn: '9788535910663');

    expect(item.edition.id, 'edition_dom_casmurro');
  });
}

const _searchResponse = <String, Object?>{
  'items': [
    {
      'book': {
        'id': 'book_dom_casmurro',
        'title': 'Dom Casmurro',
        'subtitle': null,
        'authors': [
          {'id': 'author_machado', 'name': 'Machado de Assis'},
        ],
      },
      'edition': {
        'id': 'edition_dom_casmurro',
        'title': 'Dom Casmurro',
        'subtitle': null,
        'coverUrl': null,
        'publisher': {
          'id': 'publisher_exemplo',
          'name': 'Editora Exemplo',
          'logoUrl': null,
        },
        'publishedYear': 2008,
        'language': 'pt-BR',
        'format': 'paperback',
        'pageCount': 256,
        'isbn10': null,
        'isbn13': '9788535910663',
      },
    },
  ],
  'page': 1,
  'limit': 20,
  'hasNextPage': false,
};
