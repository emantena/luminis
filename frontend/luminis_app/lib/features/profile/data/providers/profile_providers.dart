import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/repositories/profile_repository.dart';
import '../repositories/profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});
