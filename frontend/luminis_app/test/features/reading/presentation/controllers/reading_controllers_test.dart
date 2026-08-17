import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/reading/data/providers/reading_providers.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_progress_entry.dart';
import 'package:luminis_app/features/reading/domain/repositories/reading_repository.dart';
import 'package:luminis_app/features/reading/presentation/controllers/reading_controllers.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

import '../../fakes/fake_reading_repository.dart';

void main() {
  group('ReadingProgressController', () {
    test('submit registra progresso e expõe sucesso', () async {
      ReadingProgressResult? received;
      final repository = FakeReadingRepository(
        onRegisterProgress:
            ({
              required readingSessionId,
              pageNumber,
              percentage,
              note,
              isPublic = false,
            }) async {
              received = ReadingProgressResult(
                entry: ReadingProgressEntry(
                  id: 'progress_1',
                  readingSessionId: readingSessionId,
                  pageNumber: pageNumber,
                  percentage: percentage,
                  note: note,
                  isPublic: isPublic,
                  createdAt: DateTime.utc(2026, 8, 17),
                ),
                completedReading: false,
              );
              return received!;
            },
      );
      final container = ProviderContainer.test(
        overrides: [readingRepositoryProvider.overrideWithValue(repository)],
      );

      final result = await container
          .read(readingProgressControllerProvider.notifier)
          .submit(
            readingSessionId: 'session_1',
            bookshelfItemId: 'item_1',
            pageNumber: 140,
            note: 'Bom trecho.',
          );

      expect(result, same(received));
      expect(container.read(readingProgressControllerProvider).isSuccess, true);
      expect(received!.entry.pageNumber, 140);
      expect(received!.entry.isPublic, false);
    });

    test('submit transforma ApiFailure em mensagem de formulário', () async {
      final repository = FakeReadingRepository(
        onRegisterProgress:
            ({
              required readingSessionId,
              pageNumber,
              percentage,
              note,
              isPublic = false,
            }) async {
              throw const ApiConflictFailure(
                code: 'reading.progress_regression',
                message:
                    'A página não pode ser menor que o progresso anterior.',
                statusCode: 409,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [readingRepositoryProvider.overrideWithValue(repository)],
      );

      final result = await container
          .read(readingProgressControllerProvider.notifier)
          .submit(
            readingSessionId: 'session_1',
            bookshelfItemId: 'item_1',
            pageNumber: 20,
          );

      expect(result, isNull);
      expect(
        container.read(readingProgressControllerProvider).errorMessage,
        'A página não pode ser menor que o progresso anterior.',
      );
    });
  });

  group('ReadingPlanController', () {
    test('save transforma ApiFailure em mensagem de formulário', () async {
      DateTime? receivedDate;
      final repository = FakeReadingRepository(
        onSavePlan:
            ({required bookshelfItemId, required targetFinishDate}) async {
              receivedDate = targetFinishDate;
              throw const ApiNotFoundFailure(
                code: 'bookshelf.item_not_found',
                message: 'Item da estante não encontrado.',
                statusCode: 404,
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [readingRepositoryProvider.overrideWithValue(repository)],
      );

      final success = await container
          .read(readingPlanControllerProvider.notifier)
          .save(
            bookshelfItemId: 'item_1',
            targetFinishDate: DateTime.utc(2026, 9, 30),
          );

      expect(success, false);
      expect(receivedDate, DateTime.utc(2026, 9, 30));
      expect(
        container.read(readingPlanControllerProvider).errorMessage,
        'Item da estante não encontrado.',
      );
    });
  });

  group('ReadingStatusController', () {
    test('update transforma ApiFailure em mensagem de comando', () async {
      WantToReadSessionAction? receivedAction;
      final repository = FakeReadingRepository(
        onUpdateReadingStatus:
            ({
              required bookshelfItemId,
              required readingStatus,
              sessionAction,
            }) async {
              receivedAction = sessionAction;
              throw const ApiValidationFailure(
                code: 'validation.failed',
                message: 'Escolha o que fazer com o progresso atual.',
                statusCode: 400,
                fieldErrors: {
                  'sessionAction': ['Informe como tratar a sessão atual.'],
                },
              );
            },
      );
      final container = ProviderContainer.test(
        overrides: [readingRepositoryProvider.overrideWithValue(repository)],
      );

      final success = await container
          .read(readingStatusControllerProvider.notifier)
          .update(
            bookshelfItemId: 'item_1',
            readingStatus: ReadingStatus.wantToRead,
            sessionAction: WantToReadSessionAction.keepPaused,
          );

      expect(success, false);
      expect(receivedAction, WantToReadSessionAction.keepPaused);
      expect(
        container.read(readingStatusControllerProvider).errorMessage,
        'Informe como tratar a sessão atual.',
      );
    });
  });
}
