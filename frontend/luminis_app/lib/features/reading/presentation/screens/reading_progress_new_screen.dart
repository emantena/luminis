import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../../../shared/presentation/widgets/reading_progress_bar.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../controllers/reading_controllers.dart';

enum _ProgressMode { page, percentage }

class ReadingProgressNewScreen extends ConsumerStatefulWidget {
  const ReadingProgressNewScreen({required this.bookshelfItemId, super.key});

  final String bookshelfItemId;

  @override
  ConsumerState<ReadingProgressNewScreen> createState() =>
      _ReadingProgressNewScreenState();
}

class _ReadingProgressNewScreenState
    extends ConsumerState<ReadingProgressNewScreen> {
  final _pageController = TextEditingController();
  final _percentageController = TextEditingController();
  final _noteController = TextEditingController();
  _ProgressMode? _mode;
  bool _isPublic = false;

  @override
  void dispose() {
    _pageController.dispose();
    _percentageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = ref.watch(
      readingStateControllerProvider(widget.bookshelfItemId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar progresso')),
      body: switch (reading) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => const LuminisEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Não foi possível carregar a leitura',
          description: 'Volte e tente novamente.',
        ),
        AsyncData(:final value) => _buildForm(context, value),
      },
    );
  }

  Widget _buildForm(BuildContext context, ReadingStateSnapshot snapshot) {
    final session = snapshot.session;
    if (session == null || session.status != ReadingSessionStatus.active) {
      return const LuminisEmptyState(
        icon: Icons.pause_circle_outline,
        title: 'Retome a leitura primeiro',
        description: 'Progresso só pode ser registrado em uma sessão ativa.',
      );
    }
    final mode =
        _mode ??
        (snapshot.pageCount == null
            ? _ProgressMode.percentage
            : _ProgressMode.page);
    final controllerState = ref.watch(readingProgressControllerProvider);
    final predictedPercent = _predictedPercent(snapshot, mode);

    return ListView(
      padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
      children: [
        Text(snapshot.title, style: LuminisTypography.sectionTitle),
        const SizedBox(height: 4),
        Text(_lastProgressLabel(snapshot), style: LuminisTypography.metadata),
        const SizedBox(height: LuminisSpacing.sectionGap),
        SegmentedButton<_ProgressMode>(
          segments: const [
            ButtonSegment(value: _ProgressMode.page, label: Text('Página')),
            ButtonSegment(
              value: _ProgressMode.percentage,
              label: Text('Percentual'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              setState(() => _mode = selection.single),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        if (mode == _ProgressMode.page)
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Página atual',
              suffixText: snapshot.pageCount == null
                  ? null
                  : 'de ${snapshot.pageCount}',
            ),
            onChanged: (_) => setState(() {}),
          )
        else
          TextField(
            controller: _percentageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Percentual lido',
              suffixText: '%',
            ),
            onChanged: (_) => setState(() {}),
          ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        ReadingProgressBar(percent: predictedPercent),
        const SizedBox(height: 8),
        Text(_deltaLabel(snapshot, mode), style: LuminisTypography.metadata),
        const SizedBox(height: LuminisSpacing.listItemGap),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Anotação opcional',
            alignLabelWithHint: true,
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Publicar progresso'),
          subtitle: const Text('Privado por padrão no MVP'),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
        ),
        if (_willComplete(snapshot, mode))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Este registro concluirá a leitura.',
              style: LuminisTypography.body.copyWith(
                color: LuminisColors.coral,
              ),
            ),
          ),
        if (controllerState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              controllerState.errorMessage!,
              style: LuminisTypography.body.copyWith(
                color: LuminisColors.coral,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controllerState.isSubmitting
                ? null
                : () => _submit(context, snapshot, session, mode),
            child: controllerState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Salvar progresso'),
          ),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    ReadingStateSnapshot snapshot,
    ReadingSession session,
    _ProgressMode mode,
  ) async {
    final result = await ref
        .read(readingProgressControllerProvider.notifier)
        .submit(
          readingSessionId: session.id,
          bookshelfItemId: snapshot.bookshelfItem.id,
          pageNumber: mode == _ProgressMode.page
              ? int.tryParse(_pageController.text)
              : null,
          percentage: mode == _ProgressMode.percentage
              ? int.tryParse(_percentageController.text)
              : null,
          note: _noteController.text,
          isPublic: _isPublic,
        );
    if (!context.mounted || result == null) return;
    context.pop();
  }

  int _predictedPercent(ReadingStateSnapshot snapshot, _ProgressMode mode) {
    if (mode == _ProgressMode.percentage) {
      return int.tryParse(_percentageController.text) ??
          snapshot.progressPercent;
    }
    final page = int.tryParse(_pageController.text) ?? snapshot.currentPage;
    final pageCount = snapshot.pageCount;
    if (page == null || pageCount == null || pageCount <= 0) {
      return snapshot.progressPercent;
    }
    return ((page / pageCount) * 100).round().clamp(0, 100).toInt();
  }

  String _deltaLabel(ReadingStateSnapshot snapshot, _ProgressMode mode) {
    if (mode != _ProgressMode.page) return 'Use 100% para concluir a leitura.';
    final next = int.tryParse(_pageController.text);
    final current = snapshot.currentPage;
    if (next == null || current == null) {
      return 'Informe a página atual para ver o avanço.';
    }
    final delta = next - current;
    if (delta < 0) return 'A página não pode ser menor que a anterior.';
    return '+$delta páginas desde o último registro.';
  }

  bool _willComplete(ReadingStateSnapshot snapshot, _ProgressMode mode) {
    if (mode == _ProgressMode.percentage) {
      return int.tryParse(_percentageController.text) == 100;
    }
    final page = int.tryParse(_pageController.text);
    final pageCount = snapshot.pageCount;
    return page != null && pageCount != null && page >= pageCount;
  }
}

String _lastProgressLabel(ReadingStateSnapshot snapshot) {
  final page = snapshot.currentPage;
  if (page != null) return 'Último ponto: página $page.';
  if (snapshot.progressPercent > 0) {
    return 'Último ponto: ${snapshot.progressPercent}%.';
  }
  return 'Ainda sem progresso registrado.';
}
