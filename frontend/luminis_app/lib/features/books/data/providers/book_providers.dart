import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/api_client_provider.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/repositories/book_catalog_repository.dart';
import '../../domain/repositories/book_draft_repository.dart';
import '../repositories/book_catalog_repository_impl.dart';
import '../repositories/book_draft_repository_impl.dart';

/// Implementação de [BookCatalogRepository] usada pelo app.
///
/// `keepAlive`: repository deve sobreviver à navegação entre telas de busca
/// e detalhe, conforme `references/riverpod-3.md`. Testes e widget tests
/// devem sobrescrever este provider com um fake (`overrideWithValue`).
final bookCatalogRepositoryProvider = Provider<BookCatalogRepository>((ref) {
  return BookCatalogRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});

/// Implementação de [BookDraftRepository] usada pelo app.
///
final bookDraftRepositoryProvider = Provider<BookDraftRepository>((ref) {
  return BookDraftRepositoryImpl(
    ref.watch(apiClientProvider),
    bearerToken: ref.watch(currentAccessTokenProvider),
  );
});
