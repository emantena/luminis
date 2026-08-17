import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/bookshelf/data/repositories/bookshelf_repository_impl.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tag_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tags_patch.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';

void main() {
  test('listItems serializa filtros e mapeia item de livro', () async {
    final repository = BookshelfRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/bookshelf-items');
          expect(request.url.queryParameters['readingStatus'], 'reading');
          expect(request.url.queryParameters['isOwned'], 'true');
          expect(request.headers['Authorization'], 'Bearer token-abc');
          return http.Response(jsonEncode(_listResponse), 200);
        }),
      ),
      bearerToken: 'token-abc',
    );

    final result = await repository.listItems(
      filter: const BookshelfFilter(
        readingStatus: ReadingStatus.reading,
        tags: BookshelfTagFilter(isOwned: true),
      ),
    );

    expect(result.items.single.readingStatus, ReadingStatus.reading);
    expect(result.items.single.tags.isOwned, isTrue);
  });

  test('updateTags envia somente os campos alterados', () async {
    final repository = BookshelfRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/bookshelf-items/item-1/tags');
          expect(jsonDecode(request.body), {'isFavorite': true});
          return http.Response(
            jsonEncode((_listResponse['items'] as List<Object?>).first),
            200,
          );
        }),
      ),
      bearerToken: 'token-abc',
    );

    final item = await repository.updateTags(
      bookshelfItemId: 'item-1',
      tags: const BookshelfTagsPatch(isFavorite: true),
    );

    expect(item.tags.isFavorite, isTrue);
  });
}

const _listResponse = <String, Object?>{
  'items': [
    {
      'id': 'item-1',
      'target': {'type': 'book', 'bookId': 'book-1', 'editionId': 'edition-1'},
      'readingStatus': 'reading',
      'tags': {
        'isFavorite': true,
        'isOwned': true,
        'isWished': false,
        'isBorrowed': false,
        'isLent': false,
        'isEbook': false,
        'isAudiobook': false,
      },
      'startedAt': '2026-08-01T00:00:00Z',
      'finishedAt': null,
      'addedAt': '2026-07-02T00:00:00Z',
      'updatedAt': '2026-08-01T00:00:00Z',
    },
  ],
  'page': 1,
  'limit': 20,
  'hasNextPage': false,
};
