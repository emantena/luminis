/// Atualização parcial de etiquetas para
/// `PATCH /api/bookshelf-items/{id}/tags`. Campo `null` significa "não
/// alterar"; campo `true`/`false` substitui o valor atual.
///
/// "Pelo menos uma etiqueta deve ser enviada" — quem valida [isEmpty] é a
/// implementação de `BookshelfRepository` (mock hoje, mirror do
/// comportamento esperado da API real), não a UI.
class BookshelfTagsPatch {
  const BookshelfTagsPatch({
    this.isFavorite,
    this.isOwned,
    this.isWished,
    this.isBorrowed,
    this.isLent,
    this.isEbook,
    this.isAudiobook,
  });

  final bool? isFavorite;
  final bool? isOwned;
  final bool? isWished;
  final bool? isBorrowed;
  final bool? isLent;
  final bool? isEbook;
  final bool? isAudiobook;

  bool get isEmpty =>
      isFavorite == null &&
      isOwned == null &&
      isWished == null &&
      isBorrowed == null &&
      isLent == null &&
      isEbook == null &&
      isAudiobook == null;
}
