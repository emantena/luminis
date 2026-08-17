import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/no_retry.dart';
import '../../data/providers/book_providers.dart';
import '../../domain/entities/book_detail.dart';

/// **API pública para `luminis-flutter-agent`:**
/// - Tipo: `FutureProvider<BookDetail>` com `autoDispose.family<String>`,
///   parametrizado por `bookId` (o mesmo `bookId` de `state.pathParameters`
///   em `/books/:bookId`).
/// - Uso: `ref.watch(bookDetailControllerProvider(bookId))` retorna
///   `AsyncValue<BookDetail>` — tratar `loading`/`data`/`error` diretamente
///   com `AsyncValue` (sem estado "idle" aqui: a tela de detalhe sempre
///   busca ao abrir).
/// - `GET /api/books/{bookId}` — erro de obra não encontrada chega como
///   `ApiNotFoundFailure` (`catalog.book_not_found`) dentro do `AsyncError`.
///
/// `retry: noRetry` desliga o retry automático do Riverpod 3.x — ver
/// `shared/infrastructure/no_retry.dart`.
final bookDetailControllerProvider = FutureProvider.autoDispose
    .family<BookDetail, String>((ref, bookId) {
      final repository = ref.watch(bookCatalogRepositoryProvider);
      return repository.getBookDetail(bookId: bookId);
    }, retry: noRetry);
