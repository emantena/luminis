enum ReadingSessionStatus { active, paused, finished, interrupted, abandoned }

extension ReadingSessionStatusWire on ReadingSessionStatus {
  String get wireValue => switch (this) {
    ReadingSessionStatus.active => 'active',
    ReadingSessionStatus.paused => 'paused',
    ReadingSessionStatus.finished => 'finished',
    ReadingSessionStatus.interrupted => 'interrupted',
    ReadingSessionStatus.abandoned => 'abandoned',
  };

  static ReadingSessionStatus fromWire(String value) => switch (value) {
    'active' => ReadingSessionStatus.active,
    'paused' => ReadingSessionStatus.paused,
    'finished' => ReadingSessionStatus.finished,
    'interrupted' => ReadingSessionStatus.interrupted,
    'abandoned' => ReadingSessionStatus.abandoned,
    final String unknown => throw FormatException(
      'reading_session.status desconhecido: $unknown',
    ),
  };
}

class ReadingSession {
  const ReadingSession({
    required this.id,
    required this.bookshelfItemId,
    required this.status,
    required this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String bookshelfItemId;
  final ReadingSessionStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;

  ReadingSession copyWith({
    ReadingSessionStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
  }) {
    return ReadingSession(
      id: id,
      bookshelfItemId: bookshelfItemId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : finishedAt ?? this.finishedAt,
    );
  }
}
