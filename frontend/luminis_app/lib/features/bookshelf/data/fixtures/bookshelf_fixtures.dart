import '../../../books/data/fixtures/book_catalog_fixtures.dart';
import '../../../books/data/fixtures/book_draft_fixtures.dart';
import '../../domain/entities/bookshelf_item.dart';
import '../../domain/entities/bookshelf_tags.dart';
import '../../domain/entities/bookshelf_target.dart';
import '../../domain/entities/reading_status.dart';

/// Itens semeados por padrão em [InMemoryBookshelfRepository] enquanto
/// `backend/mock-api` não expõe as rotas de Bookshelf (ver relatório desta
/// fatia).
///
/// Cobre os cenários pedidos para esta fatia:
/// - os 6 valores de [ReadingStatus];
/// - [wantToReadQuincasBorba]: mesma edição de
///   `BookCatalogFixtures.quincasBorbaSearchItem`, propositalmente, para que
///   um teste possa buscar esse livro no catálogo e tentar adicioná-lo de
///   novo à estante, validando a rejeição de duplicidade pelo repository.
///
/// Importa fixtures de `books` (`data/` -> `data/`, não `domain/` ->
/// `domain/`) apenas para manter os dados de demonstração coerentes entre
/// as duas features mockadas; `BookshelfItem` em si não depende de nenhum
/// tipo de `books`.
abstract final class BookshelfFixtures {
  const BookshelfFixtures._();

  static final BookshelfItem wantToReadQuincasBorba = BookshelfItem(
    id: 'bookshelf_item_seed_want_to_read',
    target: BookshelfBookTarget(
      bookId: BookCatalogFixtures.quincasBorba.id,
      editionId: BookCatalogFixtures.quincasBorbaEdition.id,
    ),
    readingStatus: ReadingStatus.wantToRead,
    addedAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );

  static final BookshelfItem reading = BookshelfItem(
    id: 'bookshelf_item_seed_reading',
    target: BookshelfBookTarget(
      bookId: BookCatalogFixtures.brasCubas.id,
      editionId: BookCatalogFixtures.brasCubasEdition.id,
    ),
    readingStatus: ReadingStatus.reading,
    tags: const BookshelfTags(isOwned: true),
    addedAt: DateTime.utc(2026, 7, 2),
    updatedAt: DateTime.utc(2026, 8, 1),
    startedAt: DateTime.utc(2026, 8, 1),
  );

  static final BookshelfItem paused = BookshelfItem(
    id: 'bookshelf_item_seed_paused',
    target: BookshelfDraftTarget(
      userBookDraftId: BookDraftFixtures.seedDraft.id,
    ),
    readingStatus: ReadingStatus.paused,
    addedAt: DateTime.utc(2026, 6, 5),
    updatedAt: DateTime.utc(2026, 7, 20),
    startedAt: DateTime.utc(2026, 6, 10),
  );

  static final BookshelfItem read = BookshelfItem(
    id: 'bookshelf_item_seed_read',
    target: BookshelfBookTarget(
      bookId: BookCatalogFixtures.domCasmurro.id,
      editionId: BookCatalogFixtures.domCasmurroCompanhiaEdition.id,
    ),
    readingStatus: ReadingStatus.read,
    tags: const BookshelfTags(isFavorite: true, isOwned: true),
    addedAt: DateTime.utc(2026, 3, 1),
    updatedAt: DateTime.utc(2026, 4, 15),
    startedAt: DateTime.utc(2026, 3, 2),
    finishedAt: DateTime.utc(2026, 4, 15),
  );

  /// Edição diferente da mesma obra de [read], para validar que duplicidade
  /// é avaliada por `editionId`, não por `bookId`.
  static final BookshelfItem rereading = BookshelfItem(
    id: 'bookshelf_item_seed_rereading',
    target: BookshelfBookTarget(
      bookId: BookCatalogFixtures.domCasmurro.id,
      editionId: BookCatalogFixtures.domCasmurroPopularEdition.id,
    ),
    readingStatus: ReadingStatus.rereading,
    addedAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 5),
    startedAt: DateTime.utc(2026, 8, 5),
  );

  static final BookshelfItem abandoned = BookshelfItem(
    id: 'bookshelf_item_seed_abandoned',
    target: const BookshelfBookTarget(
      bookId: 'book_seed_abandoned',
      editionId: 'edition_seed_abandoned',
    ),
    readingStatus: ReadingStatus.abandoned,
    addedAt: DateTime.utc(2026, 1, 10),
    updatedAt: DateTime.utc(2026, 2, 1),
    startedAt: DateTime.utc(2026, 1, 12),
    finishedAt: DateTime.utc(2026, 2, 1),
  );

  static List<BookshelfItem> get all => [
    wantToReadQuincasBorba,
    reading,
    paused,
    read,
    rereading,
    abandoned,
  ];
}
