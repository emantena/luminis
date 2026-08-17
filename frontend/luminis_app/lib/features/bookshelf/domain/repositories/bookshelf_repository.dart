import '../entities/bookshelf_item.dart';
import '../entities/reading_status.dart';
import '../value_objects/bookshelf_filter.dart';
import '../value_objects/bookshelf_tags_patch.dart';

/// Contrato do módulo Bookshelf (`docs/architecture/backend-contracts.md`).
///
/// Implementações HTTP e doubles em memória para teste devem respeitar
/// exatamente esta interface. Widgets nunca devem instanciar uma implementação diretamente — apenas via
/// `bookshelfRepositoryProvider` (`data/providers/bookshelf_providers.dart`).
///
/// Todos os métodos lançam `ApiFailure`
/// (`shared/infrastructure/api_exception.dart`) em caso de erro, mesmo na
/// implementação mock em memória.
abstract interface class BookshelfRepository {
  /// `GET /api/bookshelf-items`. Lista apenas itens ativos
  /// (`removed_at is null`) do usuário autenticado.
  Future<BookshelfListResult> listItems({
    BookshelfFilter filter = const BookshelfFilter(),
    int page = 1,
    int limit = 20,
  });

  /// `POST /api/bookshelf-items` com `bookId` + `editionId`.
  ///
  /// Lança `ApiConflictFailure` (`bookshelf.item_already_exists`) quando já
  /// existir item ativo para a mesma `editionId`, conforme "Decisão sobre
  /// duplicidade de item de estante".
  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  });

  /// `POST /api/bookshelf-items` com `userBookDraftId`.
  ///
  /// Lança `ApiConflictFailure` (`bookshelf.item_already_exists`) quando já
  /// existir item ativo para o mesmo `userBookDraftId`.
  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  });

  /// `PATCH /api/bookshelf-items/{id}/reading-status`.
  ///
  /// Simplificação desta fatia (ver relatório): não modela `sessionAction`
  /// nem orquestra `reading_sessions`/planos — isso pertence à feature
  /// `reading`, fora deste escopo. `startedAt`/`finishedAt` são derivados
  /// internamente pela implementação a partir do novo `readingStatus`.
  ///
  /// Lança `ApiNotFoundFailure` (`bookshelf.item_not_found`) quando o item
  /// não existir, não pertencer ao usuário autenticado ou estiver removido.
  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  });

  /// `PATCH /api/bookshelf-items/{id}/tags`. Atualização parcial: campos
  /// omitidos em [tags] permanecem inalterados.
  ///
  /// Lança `ApiValidationFailure` (`validation.failed`) quando [tags]
  /// estiver vazio (nenhuma etiqueta enviada), ou `ApiNotFoundFailure`
  /// (`bookshelf.item_not_found`) quando o item não existir, não pertencer
  /// ao usuário autenticado ou estiver removido.
  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  });

  /// `DELETE /api/bookshelf-items/{id}`. Remoção lógica.
  ///
  /// Lança `ApiNotFoundFailure` (`bookshelf.item_not_found`) quando o item
  /// não existir, não pertencer ao usuário autenticado ou já estiver
  /// removido.
  Future<void> removeItem({required String bookshelfItemId});
}
