import '../../../../shared/infrastructure/api_exception.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/bookshelf_tags.dart';
import '../../domain/entities/bookshelf_target.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/repositories/bookshelf_repository.dart';
import '../../domain/value_objects/bookshelf_filter.dart';
import '../../domain/value_objects/bookshelf_tags_patch.dart';

/// Implementação em memória de [BookshelfRepository].
///
/// Usada apenas como double determinístico em testes unitários. A remoção é
/// física nesta implementação; o runtime usa [BookshelfRepositoryImpl], que
/// consome a remoção lógica definida no contrato HTTP.
class InMemoryBookshelfRepository implements BookshelfRepository {
  InMemoryBookshelfRepository({List<BookshelfItem>? seed})
    : _items = {for (final item in seed ?? const []) item.id: item};

  final Map<String, BookshelfItem> _items;
  int _sequence = 0;

  @override
  Future<BookshelfListResult> listItems({
    BookshelfFilter filter = const BookshelfFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    final matches = _items.values.where((item) {
      if (filter.readingStatus != null &&
          item.readingStatus != filter.readingStatus) {
        return false;
      }
      return filter.tags.matches(item.tags);
    }).toList()..sort(_byUpdatedThenAddedDesc);

    final start = (page - 1) * limit;
    final pageItems = start >= matches.length
        ? const <BookshelfItem>[]
        : matches.skip(start).take(limit).toList(growable: false);

    return BookshelfListResult(
      items: pageItems,
      page: page,
      limit: limit,
      hasNextPage: start + pageItems.length < matches.length,
    );
  }

  int _byUpdatedThenAddedDesc(BookshelfItem a, BookshelfItem b) {
    final updatedComparison = b.updatedAt.compareTo(a.updatedAt);
    if (updatedComparison != 0) return updatedComparison;
    return b.addedAt.compareTo(a.addedAt);
  }

  @override
  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) async {
    final alreadyActive = _items.values.any((item) {
      final target = item.target;
      return target is BookshelfBookTarget && target.editionId == editionId;
    });
    if (alreadyActive) {
      throw const ApiConflictFailure(
        code: 'bookshelf.item_already_exists',
        message: 'Esta edição já está na sua estante.',
        statusCode: 409,
      );
    }
    return _insert(
      BookshelfBookTarget(bookId: bookId, editionId: editionId),
      readingStatus,
    );
  }

  @override
  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) async {
    final alreadyActive = _items.values.any((item) {
      final target = item.target;
      return target is BookshelfDraftTarget &&
          target.userBookDraftId == userBookDraftId;
    });
    if (alreadyActive) {
      throw const ApiConflictFailure(
        code: 'bookshelf.item_already_exists',
        message: 'Este cadastro local já está na sua estante.',
        statusCode: 409,
      );
    }
    return _insert(
      BookshelfDraftTarget(userBookDraftId: userBookDraftId),
      readingStatus,
    );
  }

  BookshelfItem _insert(BookshelfTarget target, ReadingStatus readingStatus) {
    _sequence++;
    final now = DateTime.now().toUtc();
    final item = BookshelfItem(
      id: 'bookshelf_item_$_sequence',
      target: target,
      readingStatus: readingStatus,
      addedAt: now,
      updatedAt: now,
      startedAt:
          readingStatus == ReadingStatus.reading ||
              readingStatus == ReadingStatus.rereading
          ? now
          : null,
      finishedAt: readingStatus == ReadingStatus.read ? now : null,
    );
    _items[item.id] = item;
    return item;
  }

  @override
  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  }) async {
    final current = _requireActive(bookshelfItemId);
    final now = DateTime.now().toUtc();

    // Simplificação desta fatia (ver `BookshelfRepository`): sem
    // `sessionAction`/`reading_sessions`. `paused`/`wantToRead` preservam
    // `startedAt`/`finishedAt` existentes.
    final DateTime? startedAt =
        readingStatus == ReadingStatus.reading ||
            readingStatus == ReadingStatus.rereading
        ? (current.startedAt ?? now)
        : current.startedAt;
    final DateTime? finishedAt = switch (readingStatus) {
      ReadingStatus.read || ReadingStatus.abandoned => now,
      ReadingStatus.reading || ReadingStatus.rereading => null,
      ReadingStatus.paused || ReadingStatus.wantToRead => current.finishedAt,
    };

    final updated = BookshelfItem(
      id: current.id,
      target: current.target,
      readingStatus: readingStatus,
      tags: current.tags,
      addedAt: current.addedAt,
      updatedAt: now,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
    _items[bookshelfItemId] = updated;
    return updated;
  }

  @override
  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  }) async {
    if (tags.isEmpty) {
      throw const ApiValidationFailure(
        code: 'validation.failed',
        message: 'Existem campos inválidos.',
        statusCode: 400,
        fieldErrors: {
          'tags': ['Informe ao menos uma etiqueta.'],
        },
      );
    }
    final current = _requireActive(bookshelfItemId);
    final updated = current.copyWith(
      tags: _applyTagsPatch(current.tags, tags),
      updatedAt: DateTime.now().toUtc(),
    );
    _items[bookshelfItemId] = updated;
    return updated;
  }

  @override
  Future<void> removeItem({required String bookshelfItemId}) async {
    _requireActive(bookshelfItemId);
    _items.remove(bookshelfItemId);
  }

  BookshelfItem _requireActive(String bookshelfItemId) {
    final item = _items[bookshelfItemId];
    if (item == null) {
      throw const ApiNotFoundFailure(
        code: 'bookshelf.item_not_found',
        message: 'Item da estante não encontrado.',
        statusCode: 404,
      );
    }
    return item;
  }
}

BookshelfTags _applyTagsPatch(BookshelfTags current, BookshelfTagsPatch patch) {
  return BookshelfTags(
    isFavorite: patch.isFavorite ?? current.isFavorite,
    isOwned: patch.isOwned ?? current.isOwned,
    isWished: patch.isWished ?? current.isWished,
    isBorrowed: patch.isBorrowed ?? current.isBorrowed,
    isLent: patch.isLent ?? current.isLent,
    isEbook: patch.isEbook ?? current.isEbook,
    isAudiobook: patch.isAudiobook ?? current.isAudiobook,
  );
}
