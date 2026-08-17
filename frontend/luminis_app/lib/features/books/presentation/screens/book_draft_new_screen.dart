import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../bookshelf/domain/entities/reading_status.dart';
import '../../../bookshelf/presentation/controllers/add_to_bookshelf_controller.dart';
import '../../domain/entities/user_book_draft.dart';
import '../controllers/book_draft_controller.dart';

/// Cadastro local privado de livro (`/book-drafts/new`).
///
/// Fluxo global fora do shell autenticado (abre sobre a bottom navigation,
/// via `parentNavigatorKey` raiz — ver `lib/app/router/app_router.dart`).
///
class BookDraftNewScreen extends ConsumerStatefulWidget {
  const BookDraftNewScreen({super.key});

  @override
  ConsumerState<BookDraftNewScreen> createState() => _BookDraftNewScreenState();
}

class _BookDraftNewScreenState extends ConsumerState<BookDraftNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _languageController = TextEditingController(text: 'pt-BR');
  final _formatController = TextEditingController(text: 'paperback');
  final _pageCountController = TextEditingController();
  ReadingStatus _readingStatus = ReadingStatus.wantToRead;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _languageController.dispose();
    _formatController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftState = ref.watch(bookDraftControllerProvider);
    final addState = ref.watch(addToBookshelfControllerProvider);
    final isSubmitting = draftState.isSubmitting || addState.isSubmitting;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro local')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
            children: [
              const _PrivateDraftNotice(),
              const SizedBox(height: LuminisSpacing.sectionGap),
              _CoverFallback(title: _titleController.text),
              const SizedBox(height: LuminisSpacing.sectionGap),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Título',
                  errorText: _firstError(draftState.fieldErrors, 'title'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título.'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: LuminisSpacing.listItemGap),
              TextFormField(
                controller: _authorController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Autor',
                  errorText: _firstError(draftState.fieldErrors, 'authors'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe ao menos um autor.'
                    : null,
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Dados opcionais', style: LuminisTypography.sectionTitle),
              const SizedBox(height: LuminisSpacing.listItemGap),
              TextFormField(
                controller: _publisherController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Editora'),
              ),
              const SizedBox(height: LuminisSpacing.listItemGap),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ano'),
                      validator: _validateOptionalPositiveNumber,
                    ),
                  ),
                  const SizedBox(width: LuminisSpacing.listItemGap),
                  Expanded(
                    child: TextFormField(
                      controller: _pageCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Páginas'),
                      validator: _validateOptionalPositiveNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LuminisSpacing.listItemGap),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _languageController,
                      decoration: const InputDecoration(labelText: 'Idioma'),
                    ),
                  ),
                  const SizedBox(width: LuminisSpacing.listItemGap),
                  Expanded(
                    child: TextFormField(
                      controller: _formatController,
                      decoration: const InputDecoration(labelText: 'Formato'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LuminisSpacing.sectionGap),
              Text('Status inicial', style: LuminisTypography.sectionTitle),
              const SizedBox(height: 8),
              SegmentedButton<ReadingStatus>(
                segments: const [
                  ButtonSegment(
                    value: ReadingStatus.wantToRead,
                    label: Text('Quero ler'),
                  ),
                  ButtonSegment(
                    value: ReadingStatus.reading,
                    label: Text('Lendo'),
                  ),
                  ButtonSegment(value: ReadingStatus.read, label: Text('Lido')),
                ],
                selected: {_readingStatus},
                onSelectionChanged: isSubmitting
                    ? null
                    : (selection) =>
                          setState(() => _readingStatus = selection.single),
              ),
              if (draftState.errorMessage != null ||
                  addState.errorMessage != null) ...[
                const SizedBox(height: LuminisSpacing.listItemGap),
                Text(
                  addState.errorMessage ?? draftState.errorMessage!,
                  style: LuminisTypography.body.copyWith(
                    color: LuminisColors.coral,
                  ),
                ),
              ],
              const SizedBox(height: LuminisSpacing.sectionGap),
              ElevatedButton(
                onPressed: isSubmitting ? null : _saveAndAdd,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar e adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndAdd() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final edition = _buildEdition();
    await ref
        .read(bookDraftControllerProvider.notifier)
        .submit(
          title: _titleController.text,
          authors: [_authorController.text],
          edition: edition,
        );
    final draftState = ref.read(bookDraftControllerProvider);
    final draft = draftState.createdDraft;
    if (!draftState.isSuccess || draft == null) return;

    await ref
        .read(addToBookshelfControllerProvider.notifier)
        .addFromDraft(userBookDraftId: draft.id, readingStatus: _readingStatus);
    final addState = ref.read(addToBookshelfControllerProvider);
    final item = addState.createdItem;
    if (!mounted || !addState.isSuccess || item == null) return;
    if (_readingStatus == ReadingStatus.reading) {
      context.goNamed(
        AppRouteNames.readingState,
        pathParameters: {'bookshelfItemId': item.id},
      );
    } else {
      context.goNamed(AppRouteNames.bookshelf);
    }
  }

  UserBookDraftEdition? _buildEdition() {
    final publisher = _emptyToNull(_publisherController.text);
    final language = _emptyToNull(_languageController.text);
    final format = _emptyToNull(_formatController.text);
    final publishedYear = int.tryParse(_yearController.text.trim());
    final pageCount = int.tryParse(_pageCountController.text.trim());
    if (publisher == null &&
        language == null &&
        format == null &&
        publishedYear == null &&
        pageCount == null) {
      return null;
    }
    return UserBookDraftEdition(
      publisher: publisher,
      publishedYear: publishedYear,
      language: language,
      format: format,
      pageCount: pageCount,
    );
  }
}

class _PrivateDraftNotice extends StatelessWidget {
  const _PrivateDraftNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(LuminisSpacing.listItemGap),
    decoration: BoxDecoration(
      color: LuminisColors.warm.withValues(alpha: 0.35),
      border: Border.all(color: LuminisColors.accent),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Livro privado no MVP'),
        SizedBox(height: 4),
        Text(
          'Ele será usado apenas na sua estante e não entrará no catálogo global.',
        ),
      ],
    ),
  );
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Capa opcional. Será usado um visual de fallback.',
    child: Container(
      height: 92,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(LuminisSpacing.listItemGap),
      decoration: BoxDecoration(
        color: LuminisColors.surface,
        border: Border.all(color: LuminisColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 64,
            color: LuminisColors.primary,
            alignment: Alignment.center,
            child: const Icon(Icons.menu_book, color: LuminisColors.surface),
          ),
          const SizedBox(width: LuminisSpacing.listItemGap),
          Expanded(
            child: Text(
              title.trim().isEmpty
                  ? 'Capa opcional'
                  : 'Usaremos uma capa de fallback para “${title.trim()}”.',
              style: LuminisTypography.metadata,
            ),
          ),
        ],
      ),
    ),
  );
}

String? _firstError(Map<String, List<String>> errors, String field) =>
    errors[field]?.firstOrNull;

String? _validateOptionalPositiveNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final number = int.tryParse(value.trim());
  return number == null || number <= 0 ? 'Informe um número positivo.' : null;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
