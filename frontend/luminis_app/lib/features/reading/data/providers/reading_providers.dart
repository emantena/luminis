import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/repositories/reading_repository.dart';
import '../repositories/reading_repository_impl.dart';

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});
