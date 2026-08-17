class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.bookshelfItemId,
    required this.startDate,
    required this.targetFinishDate,
  });

  final String id;
  final String bookshelfItemId;
  final DateTime startDate;
  final DateTime targetFinishDate;

  ReadingPlan copyWith({DateTime? startDate, DateTime? targetFinishDate}) {
    return ReadingPlan(
      id: id,
      bookshelfItemId: bookshelfItemId,
      startDate: startDate ?? this.startDate,
      targetFinishDate: targetFinishDate ?? this.targetFinishDate,
    );
  }
}
