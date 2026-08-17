import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/providers/book_providers.dart';
import 'package:luminis_app/features/books/domain/entities/user_book_draft.dart';
import 'package:luminis_app/features/books/presentation/controllers/book_draft_controller.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';
import 'package:luminis_app/shared/presentation/state/form_submission_status.dart';

import '../../fakes/fake_book_draft_repository.dart';

void main() {
  group('BookDraftController', () {
    test('submit com sucesso guarda o draft criado', () async {
      final repository = FakeBookDraftRepository(
        onCreateDraft: ({required title, authors = const [], edition}) async {
          return UserBookDraft(
            id: 'draft_1',
            title: title,
            authors: authors,
            edition: edition,
            createdAt: DateTime.utc(2026, 1, 1),
          );
        },
      );
      final container = ProviderContainer.test(
        overrides: [bookDraftRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(bookDraftControllerProvider.notifier)
          .submit(title: 'Livro Não Encontrado', authors: const ['Autora']);

      final state = container.read(bookDraftControllerProvider);
      expect(state.status, FormSubmissionStatus.success);
      expect(state.createdDraft?.id, 'draft_1');
    });

    test('submit com título inválido termina em erro de campo', () async {
      final repository = FakeBookDraftRepository(
        onCreateDraft: ({required title, authors = const [], edition}) async {
          throw const ApiValidationFailure(
            code: 'validation.failed',
            message: 'Existem campos inválidos.',
            statusCode: 400,
            fieldErrors: {
              'title': ['Informe um título.'],
            },
          );
        },
      );
      final container = ProviderContainer.test(
        overrides: [bookDraftRepositoryProvider.overrideWithValue(repository)],
      );

      await container
          .read(bookDraftControllerProvider.notifier)
          .submit(title: '   ');

      final state = container.read(bookDraftControllerProvider);
      expect(state.status, FormSubmissionStatus.error);
      expect(state.fieldErrors.keys, contains('title'));
    });

    test(
      'submit sem autor termina em erro de campo antes do repository',
      () async {
        final container = ProviderContainer.test(
          overrides: [
            bookDraftRepositoryProvider.overrideWithValue(
              FakeBookDraftRepository(),
            ),
          ],
        );

        await container
            .read(bookDraftControllerProvider.notifier)
            .submit(title: 'Livro sem autor');

        final state = container.read(bookDraftControllerProvider);
        expect(state.status, FormSubmissionStatus.error);
        expect(state.fieldErrors.keys, contains('authors'));
      },
    );
  });
}
