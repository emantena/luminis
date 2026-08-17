import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/repositories/goal_repository.dart';
import '../repositories/goal_repository_impl.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});
