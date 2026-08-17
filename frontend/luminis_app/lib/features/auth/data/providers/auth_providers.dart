import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

/// Implementação de [AuthRepository] usada pelo app.
///
/// `keepAlive` porque o repository (assim como [apiClientProvider]) deve
/// sobreviver à navegação entre telas de auth. Testes e widget tests devem
/// sobrescrever este provider com um fake (`overrideWithValue`) — nunca
/// alterar este arquivo para alternar mock/API real, conforme
/// `references/riverpod-3.md`.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});
