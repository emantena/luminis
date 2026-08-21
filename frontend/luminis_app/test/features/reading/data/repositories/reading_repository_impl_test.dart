import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_session.dart';
import 'package:luminis_app/features/reading/domain/repositories/reading_repository.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';

void main() {
  test('getReadingState mapeia estado completo de leitura', () async {
    final repository = ReadingRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/api/bookshelf-items/bookshelf_item_seed_reading/reading-state',
          );
          expect(request.headers['Authorization'], 'Bearer token-abc');
          return http.Response(jsonEncode(_readingStateResponse), 200);
        }),
      ),
      bearerToken: 'token-abc',
    );

    final state = await repository.getReadingState(
      bookshelfItemId: 'bookshelf_item_seed_reading',
    );

    expect(state.title, 'Memórias Póstumas de Brás Cubas');
    expect(state.session?.id, 'reading_session_seed_active');
    expect(state.lastProgress?.pageNumber, 120);
    expect(state.activePlan?.targetFinishDate, DateTime.utc(2026, 9, 30));
    expect(state.pace.dailyPagesTarget, 2);
  });

  test('listContinuableReadings prioriza leitura com progresso', () async {
    final repository = ReadingRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/bookshelf-items') {
            final status = request.url.queryParameters['readingStatus'];
            return http.Response(
              jsonEncode({
                'items': switch (status) {
                  'reading' => [_bookshelfItemResponse],
                  'rereading' => [_rereadingItemResponse],
                  _ => const <Object?>[],
                },
                'page': 1,
                'limit': 50,
                'hasNextPage': false,
              }),
              200,
            );
          }

          if (request.url.path.endsWith(
            '/bookshelf_item_seed_rereading/reading-state',
          )) {
            return http.Response(jsonEncode(_rereadingStateResponse), 200);
          }
          return http.Response(jsonEncode(_readingStateResponse), 200);
        }),
      ),
    );

    final readings = await repository.listContinuableReadings();

    expect(readings.map((reading) => reading.bookshelfItem.id), [
      'bookshelf_item_seed_reading',
      'bookshelf_item_seed_rereading',
    ]);
  });

  test('registerProgress envia progresso e mapeia resultado', () async {
    final repository = ReadingRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/api/reading-sessions/reading_session_seed_active/progress',
          );
          expect(jsonDecode(request.body), {
            'pageNumber': 130,
            'note': 'Capitulo encerrado',
            'isPublic': true,
          });
          return http.Response(jsonEncode(_progressResponse), 201);
        }),
      ),
    );

    final result = await repository.registerProgress(
      readingSessionId: 'reading_session_seed_active',
      pageNumber: 130,
      note: 'Capitulo encerrado',
      isPublic: true,
    );

    expect(result.entry.pageNumber, 130);
    expect(result.entry.note, 'Capitulo encerrado');
    expect(result.entry.isPublic, isTrue);
    expect(result.completedReading, isFalse);
  });

  test('updateReadingStatus envia sessionAction e recarrega estado', () async {
    final seenMethods = <String>[];
    final repository = ReadingRepositoryImpl(
      ApiClient(
        baseUrl: 'http://mock.local/api',
        httpClient: MockClient((request) async {
          seenMethods.add(request.method);
          if (request.method == 'PATCH') {
            expect(
              request.url.path,
              '/api/bookshelf-items/bookshelf_item_seed_reading/reading-status',
            );
            expect(jsonDecode(request.body), {
              'readingStatus': 'want_to_read',
              'sessionAction': 'keep_paused',
            });
            return http.Response(jsonEncode(_bookshelfItemResponse), 200);
          }
          expect(request.method, 'GET');
          expect(
            request.url.path,
            '/api/bookshelf-items/bookshelf_item_seed_reading/reading-state',
          );
          return http.Response(jsonEncode(_readingStateResponse), 200);
        }),
      ),
    );

    final state = await repository.updateReadingStatus(
      bookshelfItemId: 'bookshelf_item_seed_reading',
      readingStatus: ReadingStatus.wantToRead,
      sessionAction: WantToReadSessionAction.keepPaused,
    );

    expect(seenMethods, ['PATCH', 'GET']);
    expect(state.session?.status, ReadingSessionStatus.active);
  });
}

const _bookshelfItemResponse = <String, Object?>{
  'id': 'bookshelf_item_seed_reading',
  'target': {
    'type': 'book',
    'bookId': 'book_bras_cubas',
    'editionId': 'edition_bras_cubas_companhia',
  },
  'readingStatus': 'reading',
  'tags': {
    'isFavorite': false,
    'isOwned': true,
    'isWished': false,
    'isBorrowed': false,
    'isLent': false,
    'isEbook': false,
    'isAudiobook': false,
  },
  'book': {
    'id': 'book_bras_cubas',
    'title': 'Memórias Póstumas de Brás Cubas',
    'subtitle': null,
    'authors': [
      {'id': 'author_machado_de_assis', 'name': 'Machado de Assis'},
    ],
  },
  'edition': {
    'id': 'edition_bras_cubas_companhia',
    'title': 'Memórias Póstumas de Brás Cubas',
    'coverUrl': null,
    'pageCount': 208,
    'language': 'pt-BR',
    'format': 'paperback',
  },
  'draft': null,
  'startedAt': '2026-08-01T00:00:00.000Z',
  'finishedAt': null,
  'addedAt': '2026-07-02T00:00:00.000Z',
  'updatedAt': '2026-08-01T00:00:00.000Z',
};

const _readingStateResponse = <String, Object?>{
  'bookshelfItem': _bookshelfItemResponse,
  'session': {
    'id': 'reading_session_seed_active',
    'bookshelfItemId': 'bookshelf_item_seed_reading',
    'status': 'active',
    'startedAt': '2026-08-01T00:00:00.000Z',
    'finishedAt': null,
  },
  'lastProgress': {
    'id': 'reading_progress_seed_active_1',
    'readingSessionId': 'reading_session_seed_active',
    'pageNumber': 120,
    'percentage': null,
    'note': null,
    'isPublic': false,
    'createdAt': '2026-08-15T22:00:00.000Z',
  },
  'activePlan': {
    'id': 'reading_plan_seed_active',
    'bookshelfItemId': 'bookshelf_item_seed_reading',
    'startDate': '2026-08-07',
    'targetFinishDate': '2026-09-30',
  },
  'readingPace': {
    'canCalculate': true,
    'remainingPages': 88,
    'remainingDays': 44,
    'dailyPagesTarget': 2,
  },
};

const _progressResponse = <String, Object?>{
  'id': 'reading_progress_101',
  'readingSessionId': 'reading_session_seed_active',
  'pageNumber': 130,
  'percentage': null,
  'note': 'Capitulo encerrado',
  'isPublic': true,
  'createdAt': '2026-08-17T12:00:00.000Z',
  'readingStatusAfterProgress': 'reading',
  'completedReading': false,
};

const _rereadingItemResponse = <String, Object?>{
  'id': 'bookshelf_item_seed_rereading',
  'target': {
    'type': 'book',
    'bookId': 'book_dom_casmurro',
    'editionId': 'edition_dom_casmurro_popular',
  },
  'readingStatus': 'rereading',
  'tags': {
    'isFavorite': false,
    'isOwned': false,
    'isWished': false,
    'isBorrowed': false,
    'isLent': false,
    'isEbook': false,
    'isAudiobook': false,
  },
  'book': {
    'id': 'book_dom_casmurro',
    'title': 'Dom Casmurro',
    'subtitle': null,
    'authors': [
      {'id': 'author_machado_de_assis', 'name': 'Machado de Assis'},
    ],
  },
  'edition': {
    'id': 'edition_dom_casmurro_popular',
    'title': 'Dom Casmurro',
    'coverUrl': null,
    'pageCount': 240,
    'language': 'pt-BR',
    'format': 'paperback',
  },
  'draft': null,
  'startedAt': '2026-08-05T00:00:00.000Z',
  'finishedAt': null,
  'addedAt': '2026-08-01T00:00:00.000Z',
  'updatedAt': '2026-08-05T00:00:00.000Z',
};

const _rereadingStateResponse = <String, Object?>{
  'bookshelfItem': _rereadingItemResponse,
  'session': {
    'id': 'reading_session_seed_rereading',
    'bookshelfItemId': 'bookshelf_item_seed_rereading',
    'status': 'active',
    'startedAt': '2026-08-05T00:00:00.000Z',
    'finishedAt': null,
  },
  'lastProgress': null,
  'activePlan': null,
  'readingPace': {
    'canCalculate': false,
    'remainingPages': null,
    'remainingDays': null,
    'dailyPagesTarget': null,
  },
};
