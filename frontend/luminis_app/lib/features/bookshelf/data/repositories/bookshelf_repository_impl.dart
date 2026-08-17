import '../../../../shared/infrastructure/api_client.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/repositories/bookshelf_repository.dart';
import '../../domain/value_objects/bookshelf_filter.dart';
import '../../domain/value_objects/bookshelf_tags_patch.dart';
import '../mappers/bookshelf_mapper.dart';

/// Implementação HTTP da Estante na fronteira própria do Luminis.
class BookshelfRepositoryImpl implements BookshelfRepository {
  BookshelfRepositoryImpl(this._apiClient, {this.bearerToken});

  final ApiClient _apiClient;
  final String? bearerToken;

  @override
  Future<BookshelfListResult> listItems({
    BookshelfFilter filter = const BookshelfFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    final tags = filter.tags;
    final parameters = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (filter.readingStatus != null)
        'readingStatus': filter.readingStatus!.wireValue,
      if (tags.isFavorite != null) 'isFavorite': '${tags.isFavorite}',
      if (tags.isOwned != null) 'isOwned': '${tags.isOwned}',
      if (tags.isWished != null) 'isWished': '${tags.isWished}',
      if (tags.isBorrowed != null) 'isBorrowed': '${tags.isBorrowed}',
      if (tags.isLent != null) 'isLent': '${tags.isLent}',
      if (tags.isEbook != null) 'isEbook': '${tags.isEbook}',
      if (tags.isAudiobook != null) 'isAudiobook': '${tags.isAudiobook}',
    };
    final query = Uri(queryParameters: parameters).query;
    final response = await _apiClient.get(
      '/bookshelf-items?$query',
      bearerToken: bearerToken,
    );
    return BookshelfMapper.listResultFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) async {
    final response = await _apiClient.post(
      '/bookshelf-items',
      bearerToken: bearerToken,
      body: {
        'bookId': bookId,
        'editionId': editionId,
        'readingStatus': readingStatus.wireValue,
      },
    );
    return BookshelfMapper.itemFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) async {
    final response = await _apiClient.post(
      '/bookshelf-items',
      bearerToken: bearerToken,
      body: {
        'userBookDraftId': userBookDraftId,
        'readingStatus': readingStatus.wireValue,
      },
    );
    return BookshelfMapper.itemFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  }) async {
    final response = await _apiClient.patch(
      '/bookshelf-items/${Uri.encodeComponent(bookshelfItemId)}/reading-status',
      bearerToken: bearerToken,
      body: {'readingStatus': readingStatus.wireValue},
    );
    return BookshelfMapper.itemFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  }) async {
    final response = await _apiClient.patch(
      '/bookshelf-items/${Uri.encodeComponent(bookshelfItemId)}/tags',
      bearerToken: bearerToken,
      body: {
        if (tags.isFavorite != null) 'isFavorite': tags.isFavorite,
        if (tags.isOwned != null) 'isOwned': tags.isOwned,
        if (tags.isWished != null) 'isWished': tags.isWished,
        if (tags.isBorrowed != null) 'isBorrowed': tags.isBorrowed,
        if (tags.isLent != null) 'isLent': tags.isLent,
        if (tags.isEbook != null) 'isEbook': tags.isEbook,
        if (tags.isAudiobook != null) 'isAudiobook': tags.isAudiobook,
      },
    );
    return BookshelfMapper.itemFromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> removeItem({required String bookshelfItemId}) async {
    await _apiClient.delete(
      '/bookshelf-items/${Uri.encodeComponent(bookshelfItemId)}',
      bearerToken: bearerToken,
    );
  }
}
