/// Etiquetas auxiliares de organização pessoal de um item da estante
/// (`docs/architecture/backend-contracts.md` — "Decisão sobre etiquetas
/// auxiliares"). Não substituem `readingStatus` e não orquestram recursos
/// de Reading.
class BookshelfTags {
  const BookshelfTags({
    this.isFavorite = false,
    this.isOwned = false,
    this.isWished = false,
    this.isBorrowed = false,
    this.isLent = false,
    this.isEbook = false,
    this.isAudiobook = false,
  });

  final bool isFavorite;
  final bool isOwned;
  final bool isWished;
  final bool isBorrowed;
  final bool isLent;
  final bool isEbook;
  final bool isAudiobook;

  @override
  bool operator ==(Object other) {
    return other is BookshelfTags &&
        other.isFavorite == isFavorite &&
        other.isOwned == isOwned &&
        other.isWished == isWished &&
        other.isBorrowed == isBorrowed &&
        other.isLent == isLent &&
        other.isEbook == isEbook &&
        other.isAudiobook == isAudiobook;
  }

  @override
  int get hashCode => Object.hash(
    isFavorite,
    isOwned,
    isWished,
    isBorrowed,
    isLent,
    isEbook,
    isAudiobook,
  );

  @override
  String toString() =>
      'BookshelfTags(isFavorite: $isFavorite, isOwned: $isOwned, '
      'isWished: $isWished, isBorrowed: $isBorrowed, isLent: $isLent, '
      'isEbook: $isEbook, isAudiobook: $isAudiobook)';
}
