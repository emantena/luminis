/// Assunto/categoria persistido pelo Catalog em modelo plano (sem hierarquia
/// ou sinônimos no MVP), conforme `docs/architecture/backend-contracts.md`.
///
/// Só aparece em `Book.subjects` (detalhe da obra); a busca (`type=subject`)
/// consulta esses vínculos, mas o item de busca em si não expõe `Subject`.
class Subject {
  const Subject({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Subject && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Subject(id: $id, name: $name)';
}
