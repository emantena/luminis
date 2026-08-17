import 'package:luminis_app/features/books/domain/entities/user_book_draft.dart';
import 'package:luminis_app/features/books/domain/repositories/book_draft_repository.dart';

class FakeBookDraftRepository implements BookDraftRepository {
  FakeBookDraftRepository({this.onCreateDraft, this.onGetDraft});

  final Future<UserBookDraft> Function({
    required String title,
    List<String> authors,
    UserBookDraftEdition? edition,
  })?
  onCreateDraft;
  final Future<UserBookDraft> Function({required String userBookDraftId})?
  onGetDraft;

  @override
  Future<UserBookDraft> createDraft({
    required String title,
    List<String> authors = const [],
    UserBookDraftEdition? edition,
  }) {
    final callback = onCreateDraft;
    if (callback == null) {
      throw StateError('FakeBookDraftRepository.createDraft não configurado.');
    }
    return callback(title: title, authors: authors, edition: edition);
  }

  @override
  Future<UserBookDraft> getDraft({required String userBookDraftId}) {
    final callback = onGetDraft;
    if (callback == null) {
      throw StateError('FakeBookDraftRepository.getDraft não configurado.');
    }
    return callback(userBookDraftId: userBookDraftId);
  }
}
