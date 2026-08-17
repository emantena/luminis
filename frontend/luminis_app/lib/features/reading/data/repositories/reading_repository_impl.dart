import '../../../../shared/infrastructure/api_exception.dart';
import '../../../bookshelf/domain/entities/bookshelf_item.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../../bookshelf/domain/repositories/bookshelf_repository.dart';
import '../../../bookshelf/domain/value_objects/bookshelf_filter.dart';
import '../../domain/entities/reading_pace.dart';
import '../../domain/entities/reading_plan.dart';
import '../../domain/entities/reading_progress_entry.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl({
    required this._bookshelfRepository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    _seed();
  }

  final BookshelfRepository _bookshelfRepository;
  final DateTime Function() _now;

  final Map<String, ReadingSession> _sessions = {};
  final Map<String, List<ReadingProgressEntry>> _progressBySession = {};
  final Map<String, ReadingPlan> _plansByItem = {};
  int _sessionSequence = 100;
  int _progressSequence = 100;
  int _planSequence = 100;

  @override
  Future<List<ReadingStateSnapshot>> listContinuableReadings() async {
    final result = await _bookshelfRepository.listItems(
      filter: const BookshelfFilter(),
      limit: 50,
    );
    final items = result.items.where((item) {
      return item.readingStatus == ReadingStatus.reading ||
          item.readingStatus == ReadingStatus.rereading ||
          item.readingStatus == ReadingStatus.paused;
    }).toList();

    final snapshots = <ReadingStateSnapshot>[];
    for (final item in items) {
      snapshots.add(await _snapshotFor(item));
    }
    snapshots.sort(_continuitySort);
    return snapshots;
  }

  int _continuitySort(ReadingStateSnapshot a, ReadingStateSnapshot b) {
    final activeA =
        a.bookshelfItem.readingStatus == ReadingStatus.reading ||
        a.bookshelfItem.readingStatus == ReadingStatus.rereading;
    final activeB =
        b.bookshelfItem.readingStatus == ReadingStatus.reading ||
        b.bookshelfItem.readingStatus == ReadingStatus.rereading;
    if (activeA != activeB) return activeA ? -1 : 1;
    return b.bookshelfItem.updatedAt.compareTo(a.bookshelfItem.updatedAt);
  }

  @override
  Future<ReadingStateSnapshot> getReadingState({
    required String bookshelfItemId,
  }) async {
    final item = await _requireItem(bookshelfItemId);
    return _snapshotFor(item);
  }

  @override
  Future<ReadingStateSnapshot> resumeReading({
    required String bookshelfItemId,
  }) async {
    return updateReadingStatus(
      bookshelfItemId: bookshelfItemId,
      readingStatus: ReadingStatus.reading,
    );
  }

  @override
  Future<ReadingStateSnapshot> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  }) async {
    await _requireItem(bookshelfItemId);
    if (readingStatus == ReadingStatus.wantToRead &&
        _relevantSessionFor(bookshelfItemId) != null &&
        sessionAction == null) {
      throw const ApiValidationFailure(
        code: 'validation.failed',
        message: 'Escolha o que fazer com o progresso atual.',
        statusCode: 400,
        fieldErrors: {
          'sessionAction': ['Informe como tratar a sessão atual.'],
        },
      );
    }

    final updated = await _bookshelfRepository.updateReadingStatus(
      bookshelfItemId: bookshelfItemId,
      readingStatus: readingStatus,
    );
    final now = _now().toUtc();
    final session = _relevantSessionFor(bookshelfItemId);

    switch (readingStatus) {
      case ReadingStatus.reading:
      case ReadingStatus.rereading:
        if (session == null) {
          final id = _newSessionId();
          _sessions[id] = ReadingSession(
            id: id,
            bookshelfItemId: bookshelfItemId,
            status: ReadingSessionStatus.active,
            startedAt: now,
          );
        } else {
          _sessions[session.id] = session.copyWith(
            status: ReadingSessionStatus.active,
            clearFinishedAt: true,
          );
        }
        break;
      case ReadingStatus.paused:
        if (session != null) {
          _sessions[session.id] = session.copyWith(
            status: ReadingSessionStatus.paused,
          );
        }
        _plansByItem.remove(bookshelfItemId);
        break;
      case ReadingStatus.read:
        final active = session ?? _createSessionFor(updated);
        _finishSession(active, ReadingSessionStatus.finished, now);
        _plansByItem.remove(bookshelfItemId);
        await _ensureFinalProgress(active, updated, now);
        break;
      case ReadingStatus.abandoned:
        if (session != null) {
          _finishSession(session, ReadingSessionStatus.abandoned, now);
        }
        _plansByItem.remove(bookshelfItemId);
        break;
      case ReadingStatus.wantToRead:
        if (sessionAction == WantToReadSessionAction.interrupt &&
            session != null) {
          _finishSession(session, ReadingSessionStatus.interrupted, now);
        } else if (session != null) {
          _sessions[session.id] = session.copyWith(
            status: ReadingSessionStatus.paused,
          );
        }
        _plansByItem.remove(bookshelfItemId);
        break;
    }

    return _snapshotFor(updated);
  }

  @override
  Future<ReadingProgressResult> registerProgress({
    required String readingSessionId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic = false,
  }) async {
    final session = _sessions[readingSessionId];
    if (session == null) {
      throw const ApiNotFoundFailure(
        code: 'reading.session_not_found',
        message: 'Sessão de leitura não encontrada.',
        statusCode: 404,
      );
    }
    if (session.status != ReadingSessionStatus.active) {
      throw const ApiConflictFailure(
        code: 'reading.session_not_active',
        message: 'Retome a leitura antes de registrar progresso.',
        statusCode: 409,
      );
    }
    final item = await _requireItem(session.bookshelfItemId);
    _validateProgress(item, session, pageNumber, percentage);

    final now = _now().toUtc();
    final entry = ReadingProgressEntry(
      id: _newProgressId(),
      readingSessionId: readingSessionId,
      pageNumber: pageNumber,
      percentage: percentage,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      isPublic: isPublic,
      createdAt: now,
    );
    _progressBySession
        .putIfAbsent(readingSessionId, () => <ReadingProgressEntry>[])
        .add(entry);

    final pageCount = item.summary?.pageCount;
    final completed =
        (pageCount != null && pageNumber != null && pageNumber >= pageCount) ||
        percentage == 100;
    if (completed) {
      final updated = await _bookshelfRepository.updateReadingStatus(
        bookshelfItemId: item.id,
        readingStatus: ReadingStatus.read,
      );
      _finishSession(session, ReadingSessionStatus.finished, now);
      _plansByItem.remove(updated.id);
    }

    return ReadingProgressResult(entry: entry, completedReading: completed);
  }

  @override
  Future<ReadingStateSnapshot> savePlan({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  }) async {
    final item = await _requireItem(bookshelfItemId);
    final date = _dateOnly(targetFinishDate);
    final now = _dateOnly(_now());
    _plansByItem[bookshelfItemId] =
        _plansByItem[bookshelfItemId]?.copyWith(targetFinishDate: date) ??
        ReadingPlan(
          id: _newPlanId(),
          bookshelfItemId: bookshelfItemId,
          startDate: now,
          targetFinishDate: date,
        );
    return _snapshotFor(item);
  }

  @override
  Future<ReadingStateSnapshot> removePlan({
    required String bookshelfItemId,
  }) async {
    final item = await _requireItem(bookshelfItemId);
    _plansByItem.remove(bookshelfItemId);
    return _snapshotFor(item);
  }

  Future<BookshelfItem> _requireItem(String bookshelfItemId) async {
    final result = await _bookshelfRepository.listItems(limit: 50);
    for (final item in result.items) {
      if (item.id == bookshelfItemId) return item;
    }
    throw const ApiNotFoundFailure(
      code: 'bookshelf.item_not_found',
      message: 'Item da estante não encontrado.',
      statusCode: 404,
    );
  }

  Future<ReadingStateSnapshot> _snapshotFor(BookshelfItem item) async {
    final session = _ensureSessionFor(item);
    final lastProgress = session == null ? null : _lastProgress(session.id);
    return ReadingStateSnapshot(
      bookshelfItem: item,
      session: session,
      lastProgress: lastProgress,
      activePlan: _plansByItem[item.id],
      pace: _calculatePace(item, lastProgress, _plansByItem[item.id]),
    );
  }

  ReadingSession? _ensureSessionFor(BookshelfItem item) {
    final session = _relevantSessionFor(item.id);
    if (session != null) return session;
    if (item.readingStatus == ReadingStatus.reading ||
        item.readingStatus == ReadingStatus.rereading ||
        item.readingStatus == ReadingStatus.paused) {
      return _createSessionFor(item);
    }
    return null;
  }

  ReadingSession _createSessionFor(BookshelfItem item) {
    final status = item.readingStatus == ReadingStatus.paused
        ? ReadingSessionStatus.paused
        : ReadingSessionStatus.active;
    final id = _newSessionId();
    final session = ReadingSession(
      id: id,
      bookshelfItemId: item.id,
      status: status,
      startedAt: item.startedAt ?? _now().toUtc(),
    );
    _sessions[id] = session;
    return session;
  }

  ReadingSession? _relevantSessionFor(String bookshelfItemId) {
    final matches = _sessions.values.where((session) {
      return session.bookshelfItemId == bookshelfItemId &&
          (session.status == ReadingSessionStatus.active ||
              session.status == ReadingSessionStatus.paused);
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    if (matches.isEmpty) return null;
    return matches.first;
  }

  ReadingProgressEntry? _lastProgress(String sessionId) {
    final entries = _progressBySession[sessionId] ?? const [];
    if (entries.isEmpty) return null;
    return entries.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  void _validateProgress(
    BookshelfItem item,
    ReadingSession session,
    int? pageNumber,
    int? percentage,
  ) {
    final errors = <String, List<String>>{};
    if (pageNumber == null && percentage == null) {
      errors['progress'] = ['Informe página ou percentual.'];
    }
    if (pageNumber != null && pageNumber <= 0) {
      errors['pageNumber'] = ['A página deve ser maior que zero.'];
    }
    final pageCount = item.summary?.pageCount;
    if (pageCount != null && pageNumber != null && pageNumber > pageCount) {
      errors['pageNumber'] = ['A página não pode passar de $pageCount.'];
    }
    final lastPage = _lastProgress(session.id)?.pageNumber;
    if (lastPage != null && pageNumber != null && pageNumber < lastPage) {
      throw const ApiConflictFailure(
        code: 'reading.progress_regression',
        message: 'A página não pode ser menor que o progresso anterior.',
        statusCode: 409,
      );
    }
    if (percentage != null && (percentage < 0 || percentage > 100)) {
      errors['percentage'] = ['O percentual deve ficar entre 0 e 100.'];
    }
    if (errors.isNotEmpty) {
      throw ApiValidationFailure(
        code: 'validation.failed',
        message: 'Existem campos inválidos.',
        statusCode: 400,
        fieldErrors: errors,
      );
    }
  }

  Future<void> _ensureFinalProgress(
    ReadingSession session,
    BookshelfItem item,
    DateTime now,
  ) async {
    final pageCount = item.summary?.pageCount;
    if (pageCount == null) return;
    final lastPage = _lastProgress(session.id)?.pageNumber;
    if (lastPage == pageCount) return;
    final entry = ReadingProgressEntry(
      id: _newProgressId(),
      readingSessionId: session.id,
      pageNumber: pageCount,
      percentage: 100,
      isPublic: false,
      createdAt: now,
    );
    _progressBySession
        .putIfAbsent(session.id, () => <ReadingProgressEntry>[])
        .add(entry);
  }

  void _finishSession(
    ReadingSession session,
    ReadingSessionStatus status,
    DateTime now,
  ) {
    _sessions[session.id] = session.copyWith(status: status, finishedAt: now);
  }

  ReadingPace _calculatePace(
    BookshelfItem item,
    ReadingProgressEntry? progress,
    ReadingPlan? plan,
  ) {
    if (plan == null) {
      return const ReadingPace(
        canCalculate: false,
        reason: 'Defina uma data alvo para calcular o ritmo.',
      );
    }
    final pageCount = item.summary?.pageCount;
    if (pageCount == null) {
      return const ReadingPace(
        canCalculate: false,
        reason: 'Esta edição não tem total de páginas conhecido.',
      );
    }
    final currentPage = progress?.pageNumber;
    if (currentPage == null) {
      return const ReadingPace(
        canCalculate: false,
        reason: 'Registre uma página para calcular o ritmo.',
      );
    }
    final remainingPages = (pageCount - currentPage)
        .clamp(0, pageCount)
        .toInt();
    final today = _dateOnly(_now());
    final remainingDays = plan.targetFinishDate.difference(today).inDays;
    if (remainingDays <= 0) {
      return ReadingPace(
        canCalculate: false,
        remainingPages: remainingPages,
        remainingDays: remainingDays,
        reason: 'Escolha uma data futura para calcular o ritmo.',
      );
    }
    return ReadingPace(
      canCalculate: true,
      remainingPages: remainingPages,
      remainingDays: remainingDays,
      dailyPagesTarget: (remainingPages / remainingDays).ceil(),
    );
  }

  String _newSessionId() {
    _sessionSequence++;
    return 'reading_session_$_sessionSequence';
  }

  String _newProgressId() {
    _progressSequence++;
    return 'reading_progress_$_progressSequence';
  }

  String _newPlanId() {
    _planSequence++;
    return 'reading_plan_$_planSequence';
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.toUtc().year, value.toUtc().month, value.toUtc().day);

  void _seed() {
    _sessions['reading_session_seed_active'] = ReadingSession(
      id: 'reading_session_seed_active',
      bookshelfItemId: 'bookshelf_item_seed_reading',
      status: ReadingSessionStatus.active,
      startedAt: DateTime.utc(2026, 8, 1),
    );
    _progressBySession['reading_session_seed_active'] = [
      ReadingProgressEntry(
        id: 'reading_progress_seed_active_1',
        readingSessionId: 'reading_session_seed_active',
        pageNumber: 120,
        createdAt: DateTime.utc(2026, 8, 15, 22),
      ),
    ];
    _plansByItem['bookshelf_item_seed_reading'] = ReadingPlan(
      id: 'reading_plan_seed_active',
      bookshelfItemId: 'bookshelf_item_seed_reading',
      startDate: DateTime.utc(2026, 8, 7),
      targetFinishDate: DateTime.utc(2026, 9, 30),
    );

    _sessions['reading_session_seed_paused'] = ReadingSession(
      id: 'reading_session_seed_paused',
      bookshelfItemId: 'bookshelf_item_seed_paused',
      status: ReadingSessionStatus.paused,
      startedAt: DateTime.utc(2026, 6, 10),
    );
    _progressBySession['reading_session_seed_paused'] = [
      ReadingProgressEntry(
        id: 'reading_progress_seed_paused_1',
        readingSessionId: 'reading_session_seed_paused',
        pageNumber: 42,
        percentage: 44,
        createdAt: DateTime.utc(2026, 7, 20, 21),
      ),
    ];
  }
}
