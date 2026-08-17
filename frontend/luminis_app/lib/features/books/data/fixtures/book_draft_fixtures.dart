import '../../domain/entities/user_book_draft.dart';

/// Draft local semeado por padrão em [InMemoryBookDraftRepository], usado
/// também por `bookshelf` (`BookshelfFixtures`) para compor um item de
/// estante local (`draft`) coerente entre as duas features mockadas.
abstract final class BookDraftFixtures {
  const BookDraftFixtures._();

  static final UserBookDraft seedDraft = UserBookDraft(
    id: 'draft_local_seed_1',
    title: 'Poemas Inéditos de Uma Leitora',
    authors: const ['Autor Desconhecido'],
    edition: const UserBookDraftEdition(format: 'paperback', pageCount: 96),
    createdAt: DateTime.utc(2026, 6, 1),
  );
}
