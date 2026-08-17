import '../entities/user_book_draft.dart';

/// Contrato do módulo Catalog para cadastro local privado
/// (`docs/architecture/backend-contracts.md`).
///
/// Implementações HTTP e doubles em memória para teste devem respeitar
/// exatamente esta interface. Widgets nunca devem instanciar uma implementação diretamente — apenas via
/// `bookDraftRepositoryProvider` (`data/providers/book_providers.dart`).
abstract interface class BookDraftRepository {
  /// `POST /api/book-drafts`.
  ///
  /// Cria somente o draft local; incluí-lo na estante é responsabilidade de
  /// `BookshelfRepository.addDraftItem`, conforme "Decisão sobre uso
  /// imediato de cadastro local".
  ///
  /// Lança `ApiValidationFailure` (`validation.failed`) quando `title`
  /// ou a lista `authors` estiver ausente, vazia ou contiver apenas espaços.
  Future<UserBookDraft> createDraft({
    required String title,
    List<String> authors = const [],
    UserBookDraftEdition? edition,
  });

  /// Busca um draft já criado pelo usuário autenticado.
  ///
  /// A Estante referencia apenas
  /// `userBookDraftId`, sem duplicar dados de `books`) consiga exibir
  /// título/autores/edição de um item local sem manter esses dados
  /// duplicados em `bookshelf`. Este método mapeia
  /// `GET /api/book-drafts/{userBookDraftId}`.
  ///
  /// Lança `ApiNotFoundFailure` quando o draft não existir ou não pertencer
  /// ao usuário autenticado.
  Future<UserBookDraft> getDraft({required String userBookDraftId});
}
