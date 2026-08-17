class ReadingProgressEntry {
  const ReadingProgressEntry({
    required this.id,
    required this.readingSessionId,
    required this.createdAt,
    this.pageNumber,
    this.percentage,
    this.note,
    this.isPublic = false,
  });

  final String id;
  final String readingSessionId;
  final int? pageNumber;
  final int? percentage;
  final String? note;
  final bool isPublic;
  final DateTime createdAt;
}

class ReadingProgressResult {
  const ReadingProgressResult({
    required this.entry,
    required this.completedReading,
  });

  final ReadingProgressEntry entry;
  final bool completedReading;
}
