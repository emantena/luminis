import '../entities/bookshelf_tags.dart';

/// Filtro tri-state por etiqueta para `GET /api/bookshelf-items`: `null`
/// significa "não filtrar por esta etiqueta", `true`/`false` restringe.
///
/// Imutável com `==`/`hashCode` estáveis para poder ser usado com segurança
/// como parte de estado de controller (e, futuramente, como parâmetro de
/// `family`, conforme `references/riverpod-3.md`).
class BookshelfTagFilter {
  const BookshelfTagFilter({
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

  bool matches(BookshelfTags tags) {
    if (isFavorite != null && isFavorite != tags.isFavorite) return false;
    if (isOwned != null && isOwned != tags.isOwned) return false;
    if (isWished != null && isWished != tags.isWished) return false;
    if (isBorrowed != null && isBorrowed != tags.isBorrowed) return false;
    if (isLent != null && isLent != tags.isLent) return false;
    if (isEbook != null && isEbook != tags.isEbook) return false;
    if (isAudiobook != null && isAudiobook != tags.isAudiobook) return false;
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is BookshelfTagFilter &&
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
}
