import 'publisher.dart';

/// Publicação específica de uma [Book], conforme
/// `docs/architecture/backend-contracts.md` ("DTOs compartilhados do
/// Catalog").
///
/// `format` e `language` são mantidos como texto bruto (ex.: `paperback`,
/// `pt-BR`) em vez de enum: o contrato de backend não fecha um vocabulário
/// exaustivo para esses campos, então fixar um enum aqui arriscaria rejeitar
/// valores válidos vindos do Catalog no futuro — mesma decisão já tomada
/// para `User.status` na feature `auth`.
class Edition {
  const Edition({
    required this.id,
    required this.title,
    required this.publisher,
    this.subtitle,
    this.coverUrl,
    this.publishedYear,
    this.language,
    this.format,
    this.pageCount,
    this.isbn10,
    this.isbn13,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final Publisher publisher;
  final int? publishedYear;
  final String? language;
  final String? format;
  final int? pageCount;
  final String? isbn10;
  final String? isbn13;

  @override
  bool operator ==(Object other) {
    return other is Edition &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.coverUrl == coverUrl &&
        other.publisher == publisher &&
        other.publishedYear == publishedYear &&
        other.language == language &&
        other.format == format &&
        other.pageCount == pageCount &&
        other.isbn10 == isbn10 &&
        other.isbn13 == isbn13;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    coverUrl,
    publisher,
    publishedYear,
    language,
    format,
    pageCount,
    isbn10,
    isbn13,
  );

  @override
  String toString() => 'Edition(id: $id, title: $title)';
}
