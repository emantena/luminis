/// Status de leitura de um item da estante, conforme
/// `docs/architecture/backend-contracts.md` e
/// `docs/architecture/domain-model.md` (`BookshelfItem.readingStatus`).
enum ReadingStatus { wantToRead, reading, paused, read, rereading, abandoned }

/// Conversão para/de `readingStatus` no formato usado pela fronteira HTTP.
/// Mantida à parte do enum para não acoplar o domínio ao formato de wire —
/// uma futura implementação HTTP de `BookshelfRepository` usa esta extensão.
extension ReadingStatusWire on ReadingStatus {
  String get wireValue => switch (this) {
    ReadingStatus.wantToRead => 'want_to_read',
    ReadingStatus.reading => 'reading',
    ReadingStatus.paused => 'paused',
    ReadingStatus.read => 'read',
    ReadingStatus.rereading => 'rereading',
    ReadingStatus.abandoned => 'abandoned',
  };

  static ReadingStatus fromWire(String value) => switch (value) {
    'want_to_read' => ReadingStatus.wantToRead,
    'reading' => ReadingStatus.reading,
    'paused' => ReadingStatus.paused,
    'read' => ReadingStatus.read,
    'rereading' => ReadingStatus.rereading,
    'abandoned' => ReadingStatus.abandoned,
    _ => throw ArgumentError('readingStatus desconhecido: $value'),
  };
}
