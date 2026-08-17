import 'author.dart';
import 'subject.dart';

/// Obra conceitual do Catalog (`docs/architecture/backend-contracts.md`).
///
/// `description`, `originalTitle` e `subjects` só chegam preenchidos em
/// `GET /api/books/{bookId}` (detalhe). Em `GET /api/books/search` e
/// `GET /api/books/isbn/{isbn}`, o `book` de cada item não traz esses
/// campos — modelados aqui como opcionais/vazios em vez de duas classes
/// diferentes, para manter um único tipo `Book` reutilizável nas três rotas
/// do Catalog, conforme a decisão "DTOs compartilhados do Catalog".
class Book {
  const Book({
    required this.id,
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.description,
    this.originalTitle,
    this.subjects = const [],
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<Author> authors;
  final String? description;
  final String? originalTitle;
  final List<Subject> subjects;

  @override
  bool operator ==(Object other) {
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        _listEquals(other.authors, authors) &&
        other.description == description &&
        other.originalTitle == originalTitle &&
        _listEquals(other.subjects, subjects);
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    Object.hashAll(authors),
    description,
    originalTitle,
    Object.hashAll(subjects),
  );

  @override
  String toString() => 'Book(id: $id, title: $title)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
