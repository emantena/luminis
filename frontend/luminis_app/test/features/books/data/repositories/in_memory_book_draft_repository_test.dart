import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/books/data/repositories/in_memory_book_draft_repository.dart';
import 'package:luminis_app/features/books/domain/entities/user_book_draft.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  group('InMemoryBookDraftRepository', () {
    test('createDraft cria e permite recuperar o draft por id', () async {
      final repository = InMemoryBookDraftRepository();

      final draft = await repository.createDraft(
        title: '  Livro Não Encontrado  ',
        authors: const ['Autor X'],
        edition: const UserBookDraftEdition(
          publisher: 'Editora Exemplo',
          publishedYear: 2024,
        ),
      );

      expect(draft.title, 'Livro Não Encontrado');
      expect(draft.status, 'local');

      final fetched = await repository.getDraft(userBookDraftId: draft.id);
      expect(fetched.id, draft.id);
      expect(fetched.edition?.publisher, 'Editora Exemplo');
    });

    test('createDraft com título vazio lança validation.failed', () async {
      final repository = InMemoryBookDraftRepository();

      await expectLater(
        repository.createDraft(title: '   ', authors: const ['Autor X']),
        throwsA(
          isA<ApiValidationFailure>().having(
            (failure) => failure.fieldErrors.keys,
            'fieldErrors',
            contains('title'),
          ),
        ),
      );
    });

    test('createDraft sem autor lança validation.failed', () async {
      final repository = InMemoryBookDraftRepository();

      await expectLater(
        repository.createDraft(title: 'Livro sem autor'),
        throwsA(
          isA<ApiValidationFailure>().having(
            (failure) => failure.fieldErrors.keys,
            'fieldErrors',
            contains('authors'),
          ),
        ),
      );
    });

    test('getDraft com id desconhecido lança ApiNotFoundFailure', () async {
      final repository = InMemoryBookDraftRepository();

      await expectLater(
        repository.getDraft(userBookDraftId: 'draft_inexistente'),
        throwsA(isA<ApiNotFoundFailure>()),
      );
    });
  });
}
