class ReadingPace {
  const ReadingPace({
    required this.canCalculate,
    this.remainingPages,
    this.remainingDays,
    this.dailyPagesTarget,
    this.reason,
  });

  final bool canCalculate;
  final int? remainingPages;
  final int? remainingDays;
  final int? dailyPagesTarget;
  final String? reason;

  bool get isDemanding => (dailyPagesTarget ?? 0) >= 45;
}
