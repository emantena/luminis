import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_search_item.dart';
import '../../domain/entities/edition.dart';
import '../../domain/entities/publisher.dart';

/// Catálogo fixo usado por [MockBookCatalogRepository] enquanto
/// `backend/mock-api` não expõe as rotas de Catalog (ver relatório desta
/// fatia).
///
/// Cobre os cenários pedidos para esta fatia:
/// - livro com uma única edição ([brasCubasSearchItem]);
/// - livro com múltiplas edições ([domCasmurroCompanhiaSearchItem] e
///   [domCasmurroPopularSearchItem], mesma [domCasmurro] em duas edições);
/// - editora com `logoUrl` ([companhiaDasLetras]) e sem `logoUrl`
///   ([editoraPopular]);
/// - [quincasBorbaSearchItem]: reutilizado por `bookshelf`
///   (`BookshelfFixtures`) como item já ativo na estante, para testar que o
///   repository de estante rejeita duplicidade ao tentar adicionar o mesmo
///   resultado de busca de novo.
abstract final class BookCatalogFixtures {
  const BookCatalogFixtures._();

  /// Termo de busca reservado para simular indisponibilidade de provedor
  /// (`catalog.provider_unavailable`) em [MockBookCatalogRepository.search]
  /// e [MockBookCatalogRepository.searchByIsbn].
  static const String providerUnavailableQuery = '__provider_unavailable__';

  static const Author machadoDeAssis = Author(
    id: 'author_machado_de_assis',
    name: 'Machado de Assis',
  );

  static const Publisher companhiaDasLetras = Publisher(
    id: 'publisher_companhia_das_letras',
    name: 'Companhia das Letras',
    logoUrl: 'https://covers.luminis.dev/publishers/companhia-das-letras.png',
  );

  /// Editora sem `logoUrl` cadastrado, propositalmente, para cobrir o
  /// fallback visual que `luminis-flutter-agent` deve tratar.
  static const Publisher editoraPopular = Publisher(
    id: 'publisher_editora_popular',
    name: 'Editora Popular',
  );

  static const Book brasCubas = Book(
    id: 'book_bras_cubas',
    title: 'Memórias Póstumas de Brás Cubas',
    authors: [machadoDeAssis],
  );

  static const Edition brasCubasEdition = Edition(
    id: 'edition_bras_cubas_companhia',
    title: 'Memórias Póstumas de Brás Cubas',
    coverUrl: 'https://covers.luminis.dev/editions/bras-cubas.jpg',
    publisher: companhiaDasLetras,
    publishedYear: 2014,
    language: 'pt-BR',
    format: 'paperback',
    pageCount: 208,
    isbn10: '8582850128',
    isbn13: '9788582850121',
  );

  static const BookSearchItem brasCubasSearchItem = BookSearchItem(
    book: brasCubas,
    edition: brasCubasEdition,
  );

  static const Book domCasmurro = Book(
    id: 'book_dom_casmurro',
    title: 'Dom Casmurro',
    authors: [machadoDeAssis],
  );

  static const Edition domCasmurroCompanhiaEdition = Edition(
    id: 'edition_dom_casmurro_companhia',
    title: 'Dom Casmurro',
    coverUrl: 'https://covers.luminis.dev/editions/dom-casmurro-companhia.jpg',
    publisher: companhiaDasLetras,
    publishedYear: 2008,
    language: 'pt-BR',
    format: 'paperback',
    pageCount: 256,
    isbn10: '8535910667',
    isbn13: '9788535910663',
  );

  static const BookSearchItem domCasmurroCompanhiaSearchItem = BookSearchItem(
    book: domCasmurro,
    edition: domCasmurroCompanhiaEdition,
  );

  /// Segunda edição da mesma obra, com a editora sem `logoUrl`.
  static const Edition domCasmurroPopularEdition = Edition(
    id: 'edition_dom_casmurro_popular',
    title: 'Dom Casmurro',
    publisher: editoraPopular,
    publishedYear: 1999,
    language: 'pt-BR',
    format: 'paperback',
    pageCount: 240,
  );

  static const BookSearchItem domCasmurroPopularSearchItem = BookSearchItem(
    book: domCasmurro,
    edition: domCasmurroPopularEdition,
  );

  static const Book quincasBorba = Book(
    id: 'book_quincas_borba',
    title: 'Quincas Borba',
    authors: [machadoDeAssis],
  );

  static const Edition quincasBorbaEdition = Edition(
    id: 'edition_quincas_borba_companhia',
    title: 'Quincas Borba',
    coverUrl: 'https://covers.luminis.dev/editions/quincas-borba.jpg',
    publisher: companhiaDasLetras,
    publishedYear: 2012,
    language: 'pt-BR',
    format: 'paperback',
    pageCount: 264,
    isbn13: '9788535911233',
  );

  static const BookSearchItem quincasBorbaSearchItem = BookSearchItem(
    book: quincasBorba,
    edition: quincasBorbaEdition,
  );

  static const List<BookSearchItem> all = [
    brasCubasSearchItem,
    domCasmurroCompanhiaSearchItem,
    domCasmurroPopularSearchItem,
    quincasBorbaSearchItem,
  ];
}
