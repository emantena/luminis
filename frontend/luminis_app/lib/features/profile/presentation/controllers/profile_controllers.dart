import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/infrastructure/no_retry.dart';
import '../../../bookshelf/data/providers/bookshelf_providers.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../../bookshelf/domain/value_objects/bookshelf_filter.dart';
import '../../../goals/data/providers/goal_providers.dart';
import '../../../goals/domain/entities/reading_goal.dart';
import '../../../reading/data/providers/reading_providers.dart';
import '../../../reading/domain/entities/reading_state_snapshot.dart';
import '../../data/providers/profile_providers.dart';
import '../../domain/entities/user_profile.dart';

final profileControllerProvider = FutureProvider<ProfileOverview>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final bookshelfRepository = ref.watch(bookshelfRepositoryProvider);
  final readingRepository = ref.watch(readingRepositoryProvider);
  final goalRepository = ref.watch(goalRepositoryProvider);

  final profile = await profileRepository.getCurrentProfile();
  final bookshelf = await bookshelfRepository.listItems(
    filter: const BookshelfFilter(),
    limit: 50,
  );
  final readings = await readingRepository.listContinuableReadings();
  final goals = await goalRepository.listGoals();

  final booksRead = bookshelf.items
      .where((item) => item.readingStatus == ReadingStatus.read)
      .length;
  final currentlyReading = bookshelf.items
      .where(
        (item) =>
            item.readingStatus == ReadingStatus.reading ||
            item.readingStatus == ReadingStatus.rereading,
      )
      .length;
  final pagesRead = goals
      .where((snapshot) => snapshot.goal.metricType == GoalMetricType.pagesRead)
      .fold<int>(0, (total, snapshot) => total + snapshot.currentValue);
  final completedGoals = goals
      .where((snapshot) => snapshot.goal.status == GoalStatus.completed)
      .length;

  return ProfileOverview(
    profile: profile,
    stats: ProfileStats(
      booksRead: booksRead,
      currentlyReading: currentlyReading,
      pagesRead: pagesRead,
      completedGoals: completedGoals,
    ),
    currentReading: readings.firstOrNull,
  );
}, retry: noRetry);

final profileEditControllerProvider =
    NotifierProvider.autoDispose<ProfileEditController, ProfileEditState>(
      ProfileEditController.new,
    );

class ProfileOverview {
  const ProfileOverview({
    required this.profile,
    required this.stats,
    this.currentReading,
  });

  final UserProfile profile;
  final ProfileStats stats;
  final ReadingStateSnapshot? currentReading;
}

class ProfileEditController extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  Future<UserProfile?> save({
    required String displayName,
    required String? photoUrl,
    required String? bio,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            ProfileEditDraft(
              displayName: displayName.trim(),
              photoUrl: _blankToNull(photoUrl),
              bio: _blankToNull(bio),
            ),
          );
      ref.invalidate(profileControllerProvider);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return profile;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return null;
    }
  }
}

class ProfileEditState {
  const ProfileEditState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  ProfileEditState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileEditState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _messageFor(ApiFailure error) {
  if (error is ApiValidationFailure && error.fieldErrors.isNotEmpty) {
    return error.fieldErrors.values.first.first;
  }
  return error.message;
}
