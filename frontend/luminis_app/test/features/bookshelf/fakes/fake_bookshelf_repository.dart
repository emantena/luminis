import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tags_patch.dart';

/// Fake de [BookshelfRepository] para testes de controllers/providers,
/// seguindo o mesmo padrão de `test/features/auth/fakes/fake_auth_repository.dart`.
class FakeBookshelfRepository implements BookshelfRepository {
  FakeBookshelfRepository({
    this.onListItems,
    this.onAddBookItem,
    this.onAddDraftItem,
    this.onUpdateReadingStatus,
    this.onUpdateTags,
    this.onRemoveItem,
  });

  final Future<BookshelfListResult> Function({
    BookshelfFilter filter,
    int page,
    int limit,
  })?
  onListItems;
  final Future<BookshelfItem> Function({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  })?
  onAddBookItem;
  final Future<BookshelfItem> Function({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  })?
  onAddDraftItem;
  final Future<BookshelfItem> Function({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  })?
  onUpdateReadingStatus;
  final Future<BookshelfItem> Function({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  })?
  onUpdateTags;
  final Future<void> Function({required String bookshelfItemId})? onRemoveItem;

  int listItemsCallCount = 0;

  @override
  Future<BookshelfListResult> listItems({
    BookshelfFilter filter = const BookshelfFilter(),
    int page = 1,
    int limit = 20,
  }) {
    listItemsCallCount++;
    final callback = onListItems;
    if (callback == null) {
      throw StateError('FakeBookshelfRepository.listItems não configurado.');
    }
    return callback(filter: filter, page: page, limit: limit);
  }

  @override
  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) {
    final callback = onAddBookItem;
    if (callback == null) {
      throw StateError('FakeBookshelfRepository.addBookItem não configurado.');
    }
    return callback(
      bookId: bookId,
      editionId: editionId,
      readingStatus: readingStatus,
    );
  }

  @override
  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) {
    final callback = onAddDraftItem;
    if (callback == null) {
      throw StateError('FakeBookshelfRepository.addDraftItem não configurado.');
    }
    return callback(
      userBookDraftId: userBookDraftId,
      readingStatus: readingStatus,
    );
  }

  @override
  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  }) {
    final callback = onUpdateReadingStatus;
    if (callback == null) {
      throw StateError(
        'FakeBookshelfRepository.updateReadingStatus não configurado.',
      );
    }
    return callback(
      bookshelfItemId: bookshelfItemId,
      readingStatus: readingStatus,
    );
  }

  @override
  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  }) {
    final callback = onUpdateTags;
    if (callback == null) {
      throw StateError('FakeBookshelfRepository.updateTags não configurado.');
    }
    return callback(bookshelfItemId: bookshelfItemId, tags: tags);
  }

  @override
  Future<void> removeItem({required String bookshelfItemId}) {
    final callback = onRemoveItem;
    if (callback == null) {
      return Future<void>.value();
    }
    return callback(bookshelfItemId: bookshelfItemId);
  }
}
