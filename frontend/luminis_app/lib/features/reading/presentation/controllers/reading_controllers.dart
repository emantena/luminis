import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_exception.dart';
import '../../../../shared/infrastructure/no_retry.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../../bookshelf/presentation/controllers/bookshelf_controller.dart';
import '../../data/providers/reading_providers.dart';
import '../../domain/entities/reading_progress_entry.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../../domain/repositories/reading_repository.dart';

final readingHubControllerProvider = FutureProvider<List<ReadingStateSnapshot>>(
  (ref) {
    final repository = ref.watch(readingRepositoryProvider);
    return repository.listContinuableReadings();
  },
  retry: noRetry,
);

final readingStateControllerProvider = FutureProvider.autoDispose
    .family<ReadingStateSnapshot, String>((ref, bookshelfItemId) {
      final repository = ref.watch(readingRepositoryProvider);
      return repository.getReadingState(bookshelfItemId: bookshelfItemId);
    }, retry: noRetry);

final readingProgressControllerProvider =
    NotifierProvider.autoDispose<
      ReadingProgressController,
      ReadingProgressFormState
    >(ReadingProgressController.new);

final readingPlanControllerProvider =
    NotifierProvider.autoDispose<ReadingPlanController, ReadingPlanFormState>(
      ReadingPlanController.new,
    );

final readingStatusControllerProvider =
    NotifierProvider.autoDispose<
      ReadingStatusController,
      ReadingStatusCommandState
    >(ReadingStatusController.new);

class ReadingProgressController extends Notifier<ReadingProgressFormState> {
  @override
  ReadingProgressFormState build() => const ReadingProgressFormState();

  Future<ReadingProgressResult?> submit({
    required String readingSessionId,
    required String bookshelfItemId,
    int? pageNumber,
    int? percentage,
    String? note,
    bool isPublic = false,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      final result = await ref
          .read(readingRepositoryProvider)
          .registerProgress(
            readingSessionId: readingSessionId,
            pageNumber: pageNumber,
            percentage: percentage,
            note: note,
            isPublic: isPublic,
          );
      _invalidateReading(bookshelfItemId);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return result;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return null;
    }
  }

  void _invalidateReading(String bookshelfItemId) {
    ref.invalidate(readingHubControllerProvider);
    ref.invalidate(readingStateControllerProvider(bookshelfItemId));
    ref.invalidate(bookshelfControllerProvider);
  }
}

class ReadingPlanController extends Notifier<ReadingPlanFormState> {
  @override
  ReadingPlanFormState build() => const ReadingPlanFormState();

  Future<bool> save({
    required String bookshelfItemId,
    required DateTime targetFinishDate,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      await ref
          .read(readingRepositoryProvider)
          .savePlan(
            bookshelfItemId: bookshelfItemId,
            targetFinishDate: targetFinishDate,
          );
      _invalidateReading(bookshelfItemId);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  Future<bool> remove({required String bookshelfItemId}) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      await ref
          .read(readingRepositoryProvider)
          .removePlan(bookshelfItemId: bookshelfItemId);
      _invalidateReading(bookshelfItemId);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  void _invalidateReading(String bookshelfItemId) {
    ref.invalidate(readingHubControllerProvider);
    ref.invalidate(readingStateControllerProvider(bookshelfItemId));
  }
}

class ReadingStatusController extends Notifier<ReadingStatusCommandState> {
  @override
  ReadingStatusCommandState build() => const ReadingStatusCommandState();

  Future<bool> update({
    required String bookshelfItemId,
    required ReadingStatus readingStatus,
    WantToReadSessionAction? sessionAction,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      isSuccess: false,
      clearError: true,
    );
    try {
      await ref
          .read(readingRepositoryProvider)
          .updateReadingStatus(
            bookshelfItemId: bookshelfItemId,
            readingStatus: readingStatus,
            sessionAction: sessionAction,
          );
      ref.invalidate(readingHubControllerProvider);
      ref.invalidate(readingStateControllerProvider(bookshelfItemId));
      ref.invalidate(bookshelfControllerProvider);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }
}

String _messageFor(ApiFailure error) {
  if (error is ApiValidationFailure && error.fieldErrors.isNotEmpty) {
    return error.fieldErrors.values.first.first;
  }
  return error.message;
}

class ReadingProgressFormState {
  const ReadingProgressFormState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  ReadingProgressFormState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReadingProgressFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReadingPlanFormState {
  const ReadingPlanFormState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  ReadingPlanFormState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReadingPlanFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReadingStatusCommandState {
  const ReadingStatusCommandState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  ReadingStatusCommandState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReadingStatusCommandState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
