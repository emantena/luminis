/// Metadados de exibição já incluídos em `GET /api/bookshelf-items`.
///
/// A Estante mantém este resumo próprio, em vez de depender das entidades do
/// Catalog. Assim ela consegue renderizar a lista com uma única consulta sem
/// acoplamento entre os módulos.
class BookshelfItemSummary {
  const BookshelfItemSummary({
    required this.title,
    this.authors = const [],
    this.coverUrl,
    this.language,
    this.format,
    this.pageCount,
  });

  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String? language;
  final String? format;
  final int? pageCount;

  String get authorLabel =>
      authors.isEmpty ? 'Autor não informado' : authors.join(', ');

  String get editionLabel => [
    if (language != null && language!.isNotEmpty) language,
    if (format != null && format!.isNotEmpty) format,
  ].join(' · ');
}
