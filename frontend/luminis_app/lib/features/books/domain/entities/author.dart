/// Autor normalizado do Catalog, conforme
/// `docs/architecture/backend-contracts.md`.
class Author {
  const Author({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Author && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Author(id: $id, name: $name)';
}
