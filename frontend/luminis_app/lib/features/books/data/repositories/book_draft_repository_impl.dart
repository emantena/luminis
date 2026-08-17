import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/user_book_draft.dart';
import '../../domain/repositories/book_draft_repository.dart';
import '../mappers/book_mapper.dart';

/// Implementação HTTP de cadastro local privado do Catalog.
class BookDraftRepositoryImpl implements BookDraftRepository {
  BookDraftRepositoryImpl(this._apiClient, {this.bearerToken});

  final ApiClient _apiClient;
  final String? bearerToken;

  @override
  Future<UserBookDraft> createDraft({
    required String title,
    List<String> authors = const [],
    UserBookDraftEdition? edition,
  }) async {
    final response = await _apiClient.post(
      '/book-drafts',
      bearerToken: bearerToken,
      body: {
        'title': title,
        'authors': authors,
        if (edition != null) 'edition': BookMapper.draftEditionToJson(edition),
      },
    );
    return BookMapper.draftFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserBookDraft> getDraft({required String userBookDraftId}) async {
    final response = await _apiClient.get(
      '/book-drafts/${Uri.encodeComponent(userBookDraftId)}',
      bearerToken: bearerToken,
    );
    return BookMapper.draftFromJson(response as Map<String, dynamic>);
  }
}
