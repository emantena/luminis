import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bookshelf/data/providers/bookshelf_providers.dart';
import '../../domain/repositories/reading_repository.dart';
import '../repositories/reading_repository_impl.dart';

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepositoryImpl(
    bookshelfRepository: ref.watch(bookshelfRepositoryProvider),
  );
});
