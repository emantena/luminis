import '../../../../shared/infrastructure/api_exception.dart';
import '../../domain/entities/user_book_draft.dart';
import '../../domain/repositories/book_draft_repository.dart';

/// Implementação em memória de [BookDraftRepository].
///
/// Usada apenas como double determinístico em testes unitários. Mantém os
/// drafts da instância para permitir que cenários de teste resolvam
/// `userBookDraftId` via [getDraft]. O runtime usa [BookDraftRepositoryImpl].
class InMemoryBookDraftRepository implements BookDraftRepository {
  InMemoryBookDraftRepository({List<UserBookDraft>? seed})
    : _drafts = {for (final draft in seed ?? const []) draft.id: draft};

  final Map<String, UserBookDraft> _drafts;
  int _sequence = 0;

  @override
  Future<UserBookDraft> createDraft({
    required String title,
    List<String> authors = const [],
    UserBookDraftEdition? edition,
  }) async {
    final trimmedTitle = title.trim();
    final normalizedAuthors = authors
        .map((author) => author.trim())
        .where((author) => author.isNotEmpty)
        .toList(growable: false);
    final fieldErrors = <String, List<String>>{
      if (trimmedTitle.isEmpty) 'title': ['Informe um título.'],
      if (normalizedAuthors.isEmpty) 'authors': ['Informe ao menos um autor.'],
    };
    if (fieldErrors.isNotEmpty) {
      throw ApiValidationFailure(
        code: 'validation.failed',
        message: 'Existem campos inválidos.',
        statusCode: 400,
        fieldErrors: fieldErrors,
      );
    }

    _sequence++;
    final draft = UserBookDraft(
      id: 'draft_local_$_sequence',
      title: trimmedTitle,
      authors: normalizedAuthors,
      edition: edition,
      createdAt: DateTime.now().toUtc(),
    );
    _drafts[draft.id] = draft;
    return draft;
  }

  @override
  Future<UserBookDraft> getDraft({required String userBookDraftId}) async {
    final draft = _drafts[userBookDraftId];
    if (draft == null) {
      throw const ApiNotFoundFailure(
        code: 'book_draft.not_found',
        message: 'Cadastro local não encontrado.',
        statusCode: 404,
      );
    }
    return draft;
  }
}
