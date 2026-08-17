import 'book.dart';
import 'edition.dart';

/// Resposta de `GET /api/books/{bookId}`: a obra completa (com `description`,
/// `originalTitle` e `subjects`) e todas as suas edições conhecidas.
///
/// Não inclui estado de estante, progresso ou outros dados pessoais — isso
/// pertence aos módulos Bookshelf e Reading, conforme
/// `docs/architecture/backend-contracts.md`.
class BookDetail {
  const BookDetail({required this.book, required this.editions});

  final Book book;
  final List<Edition> editions;
}
