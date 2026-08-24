import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/bookshelf/data/providers/bookshelf_providers.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_item_summary.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_target.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/bookshelf_tags.dart';
import 'package:luminis_app/features/bookshelf/domain/entities/reading_status.dart';
import 'package:luminis_app/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_filter.dart';
import 'package:luminis_app/features/bookshelf/domain/value_objects/bookshelf_tags_patch.dart';
import 'package:luminis_app/features/goals/data/providers/goal_providers.dart';
import 'package:luminis_app/features/goals/domain/entities/reading_goal.dart';
import 'package:luminis_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:luminis_app/features/profile/data/providers/profile_providers.dart';
import 'package:luminis_app/features/profile/domain/entities/user_profile.dart';
import 'package:luminis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:luminis_app/features/profile/presentation/controllers/profile_controllers.dart';
import 'package:luminis_app/features/reading/data/providers/reading_providers.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_pace.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_progress_entry.dart';
import 'package:luminis_app/features/reading/domain/entities/reading_state_snapshot.dart';
import 'package:luminis_app/features/reading/domain/repositories/reading_repository.dart';
import 'package:luminis_app/shared/infrastructure/api_exception.dart';

void main() {
  test(
    'profileController agrega perfil, estatisticas e leitura atual',
    () async {
      final container = _container();
      addTearDown(container.dispose);

      final overview = await container.read(profileControllerProvider.future);

      expect(overview.profile.displayName, 'Ana Lima');
      expect(overview.stats.booksRead, 1);
      expect(overview.stats.currentlyReading, 1);
      expect(overview.stats.pagesRead, 120);
      expect(overview.stats.completedGoals, 1);
      expect(overview.currentReading?.title, 'Memórias Póstumas de Brás Cubas');
    },
  );

  test(
    'ProfileEditController salva, limpa campos opcionais vazios e invalida perfil',
    () async {
      final profileRepository = _FakeProfileRepository();
      final container = _container(profileRepository: profileRepository);
      addTearDown(container.dispose);

      final saved = await container
          .read(profileEditControllerProvider.notifier)
          .save(displayName: ' Ana Leitora ', photoUrl: ' ', bio: '');

      expect(saved?.displayName, 'Ana Leitora');
      expect(saved?.photoUrl, isNull);
      expect(saved?.bio, isNull);
      expect(container.read(profileEditControllerProvider).isSuccess, isTrue);

      final overview = await container.read(profileControllerProvider.future);
      expect(overview.profile.displayName, 'Ana Leitora');
    },
  );

  test(
    'ProfileEditController expõe mensagem segura em falha de validação',
    () async {
      final container = _container(
        profileRepository: _FakeProfileRepository(
          updateFailure: const ApiValidationFailure(
            code: 'validation.failed',
            message: 'Existem campos inválidos.',
            statusCode: 400,
            fieldErrors: {
              'displayName': ['Nome de exibição é obrigatório.'],
            },
          ),
        ),
      );
      addTearDown(container.dispose);

      final saved = await container
          .read(profileEditControllerProvider.notifier)
          .save(displayName: '', photoUrl: null, bio: null);

      expect(saved, isNull);
      expect(
        container.read(profileEditControllerProvider).errorMessage,
        'Nome de exibição é obrigatório.',
      );
    },
  );
}

ProviderContainer _container({_FakeProfileRepository? profileRepository}) {
  return ProviderContainer.test(
    overrides: [
      profileRepositoryProvider.overrideWithValue(
        profileRepository ?? _FakeProfileRepository(),
      ),
      bookshelfRepositoryProvider.overrideWithValue(_FakeBookshelfRepository()),
      readingRepositoryProvider.overrideWithValue(_FakeReadingRepository()),
      goalRepositoryProvider.overrideWithValue(_FakeGoalRepository()),
    ],
  );
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.updateFailure});

  final ApiFailure? updateFailure;
  UserProfile profile = const UserProfile(
    id: 'usr_ana_lima',
    displayName: 'Ana Lima',
    status: 'active',
    bio: 'Leitora de fantasia.',
  );

  @override
  Future<UserProfile> getCurrentProfile() async => profile;

  @override
  Future<UserProfile> updateProfile(ProfileEditDraft draft) async {
    final failure = updateFailure;
    if (failure != null) throw failure;
    profile = UserProfile(
      id: profile.id,
      displayName: draft.displayName,
      photoUrl: draft.photoUrl,
      bio: draft.bio,
      status: profile.status,
    );
    return profile;
  }
}

class _FakeBookshelfRepository implements BookshelfRepository {
  @override
  Future<BookshelfListResult> listItems({
    BookshelfFilter filter = const BookshelfFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    return BookshelfListResult(
      items: [
        _bookshelfItem('item_read', ReadingStatus.read),
        _bookshelfItem('item_reading', ReadingStatus.reading),
      ],
      page: page,
      limit: limit,
      hasNextPage: false,
    );
  }

  @override
  Future<BookshelfItem> addBookItem({
    required String bookId,
    required String editionId,
    required ReadingStatus readingStatus,
  }) => throw UnimplementedError();

  @override
  Future<BookshelfItem> addDraftItem({
    required String userBookDraftId,
    required ReadingStatus readingStatus,
  }) => throw UnimplementedError();

  @override
  Future<void> removeItem({required String bookshelfItemId}) =>
      throw UnimplementedError();

  @override
  Future<BookshelfItem> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
  }) => throw UnimplementedError();

  @override
  Future<BookshelfItem> updateTags({
    required String bookshelfItemId,
    required BookshelfTagsPatch tags,
  }) => throw UnimplementedError();
}

class _FakeReadingRepository implements ReadingRepository {
  @override
  Future<List<ReadingStateSnapshot>> listContinuableReadings() async {
    return [
      ReadingStateSnapshot(
        bookshelfItem: _bookshelfItem('item_reading', ReadingStatus.reading),
        lastProgress: ReadingProgressEntry(
          id: 'progress_1',
          readingSessionId: 'session_1',
          pageNumber: 120,
          createdAt: DateTime.utc(2026, 8, 17),
        ),
        pace: const ReadingPace(canCalculate: false),
      ),
    ];
  }

  @override
  Future<ReadingStateSnapshot> getReadingState({
    required String bookshelfItemId,
  }) => throw UnimplementedError();

  @override
  Future<ReadingProgressResult> registerProgress({
    required String readingSessionId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic = false,
  }) => throw UnimplementedError();

  @override
  Future<ReadingStateSnapshot> removePlan({required String bookshelfItemId}) =>
      throw UnimplementedError();

  @override
  Future<ReadingStateSnapshot> resumeReading({
    required String bookshelfItemId,
  }) => throw UnimplementedError();

  @override
  Future<ReadingStateSnapshot> savePlan({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  }) => throw UnimplementedError();

  @override
  Future<ReadingStateSnapshot> updateReadingStatus({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  }) => throw UnimplementedError();
}

class _FakeGoalRepository implements GoalRepository {
  @override
  Future<List<ReadingGoalSnapshot>> listGoals() async {
    return [
      ReadingGoalSnapshot(
        goal: _goal('goal_pages', GoalMetricType.pagesRead, GoalStatus.active),
        currentValue: 120,
        bonusValue: 0,
        progressPercent: 0.24,
        remainingDays: 10,
        isExpired: false,
        needsAttention: false,
        contributors: const [],
      ),
      ReadingGoalSnapshot(
        goal: _goal(
          'goal_books',
          GoalMetricType.booksRead,
          GoalStatus.completed,
        ),
        currentValue: 3,
        bonusValue: 0,
        progressPercent: 1,
        remainingDays: 0,
        isExpired: false,
        needsAttention: false,
        contributors: const [],
      ),
    ];
  }

  @override
  Future<void> cancelGoal(String readingGoalId) => throw UnimplementedError();

  @override
  Future<ReadingGoalSnapshot> createGoal(ReadingGoalDraft draft) =>
      throw UnimplementedError();

  @override
  Future<ReadingGoalSnapshot> getGoal(String readingGoalId) =>
      throw UnimplementedError();

  @override
  Future<ReadingGoalSnapshot> updateGoal({
    required String readingGoalId,
    required ReadingGoalDraft draft,
  }) => throw UnimplementedError();
}

BookshelfItem _bookshelfItem(String id, ReadingStatus status) {
  return BookshelfItem(
    id: id,
    target: const BookshelfBookTarget(
      bookId: 'book_bras_cubas',
      editionId: 'edition_bras_cubas',
    ),
    readingStatus: status,
    tags: const BookshelfTags(),
    summary: const BookshelfItemSummary(
      title: 'Memórias Póstumas de Brás Cubas',
      authors: ['Machado de Assis'],
      pageCount: 208,
    ),
    addedAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 17),
  );
}

ReadingGoal _goal(String id, GoalMetricType metricType, GoalStatus status) {
  return ReadingGoal(
    id: id,
    periodType: GoalPeriodType.monthly,
    metricType: metricType,
    targetValue: metricType == GoalMetricType.pagesRead ? 500 : 3,
    startDate: DateTime.utc(2026, 8),
    endDate: DateTime.utc(2026, 8, 31),
    isPublic: false,
    status: status,
    createdAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 17),
  );
}
