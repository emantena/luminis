/// Editora normalizada do Catalog, conforme
/// `docs/architecture/backend-contracts.md`.
///
/// `logoUrl` é `null` quando a editora não tem logo cadastrado; o fallback
/// visual pertence à presentation (`luminis-flutter-agent`), não a esta
/// entidade.
class Publisher {
  const Publisher({required this.id, required this.name, this.logoUrl});

  final String id;
  final String name;
  final String? logoUrl;

  @override
  bool operator ==(Object other) =>
      other is Publisher &&
      other.id == id &&
      other.name == name &&
      other.logoUrl == logoUrl;

  @override
  int get hashCode => Object.hash(id, name, logoUrl);

  @override
  String toString() => 'Publisher(id: $id, name: $name)';
}
