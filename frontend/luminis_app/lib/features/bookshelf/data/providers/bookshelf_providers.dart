import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/repositories/bookshelf_repository.dart';
import '../repositories/bookshelf_repository_impl.dart';

/// Implementação de [BookshelfRepository] usada pelo app.
///
/// `keepAlive`: a estante deve sobreviver à navegação entre abas do shell
/// autenticado, conforme `references/riverpod-3.md`. Testes e widget tests
/// devem sobrescrever este provider com um fake (`overrideWithValue`).
final bookshelfRepositoryProvider = Provider<BookshelfRepository>((ref) {
  return BookshelfRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});
