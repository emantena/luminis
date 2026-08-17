import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../../../shared/presentation/widgets/luminis_empty_state.dart';
import '../../domain/entities/reading_state_snapshot.dart';
import '../controllers/reading_controllers.dart';

class ReadingPlanScreen extends ConsumerStatefulWidget {
  const ReadingPlanScreen({required this.bookshelfItemId, super.key});

  final String bookshelfItemId;

  @override
  ConsumerState<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends ConsumerState<ReadingPlanScreen> {
  DateTime? _targetDate;

  @override
  Widget build(BuildContext context) {
    final reading = ref.watch(
      readingStateControllerProvider(widget.bookshelfItemId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Plano de leitura')),
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
    final controllerState = ref.watch(readingPlanControllerProvider);
    final selected =
        _targetDate ??
        snapshot.activePlan?.targetFinishDate ??
        DateTime.now().add(const Duration(days: 30));
    final preview = _pacePreview(snapshot, selected);

    return ListView(
      padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
      children: [
        Text(snapshot.title, style: LuminisTypography.sectionTitle),
        const SizedBox(height: 4),
        Text(_progressLabel(snapshot), style: LuminisTypography.metadata),
        const SizedBox(height: LuminisSpacing.sectionGap),
        OutlinedButton.icon(
          onPressed: () => _pickDate(context, selected),
          icon: const Icon(Icons.event),
          label: Text('Data alvo: ${_formatDate(selected)}'),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ritmo sugerido', style: LuminisTypography.sectionTitle),
                const SizedBox(height: 8),
                Text(preview, style: LuminisTypography.body),
              ],
            ),
          ),
        ),
        if (_isDemanding(snapshot, selected))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'O ritmo está alto. Ajustar a data pode deixar o plano mais leve.',
              style: LuminisTypography.body.copyWith(
                color: LuminisColors.coral,
              ),
            ),
          ),
        if (controllerState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controllerState.errorMessage!,
              style: LuminisTypography.body.copyWith(
                color: LuminisColors.coral,
              ),
            ),
          ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controllerState.isSubmitting
                ? null
                : () => _save(context, snapshot, selected),
            child: controllerState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Salvar plano'),
          ),
        ),
        if (snapshot.activePlan != null) ...[
          const SizedBox(height: LuminisSpacing.listItemGap),
          TextButton(
            onPressed: controllerState.isSubmitting
                ? null
                : () => _confirmRemove(context, snapshot),
            style: TextButton.styleFrom(foregroundColor: LuminisColors.coral),
            child: const Text('Remover plano'),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime selected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _targetDate = picked);
  }

  Future<void> _save(
    BuildContext context,
    ReadingStateSnapshot snapshot,
    DateTime selected,
  ) async {
    final success = await ref
        .read(readingPlanControllerProvider.notifier)
        .save(
          bookshelfItemId: snapshot.bookshelfItem.id,
          targetFinishDate: selected,
        );
    if (!context.mounted || !success) return;
    context.pop();
  }

  Future<void> _confirmRemove(
    BuildContext context,
    ReadingStateSnapshot snapshot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover plano?'),
        content: const Text('A data alvo será removida desta leitura.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: LuminisColors.coral),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await ref
        .read(readingPlanControllerProvider.notifier)
        .remove(bookshelfItemId: snapshot.bookshelfItem.id);
    if (!context.mounted || !success) return;
    context.pop();
  }
}

String _pacePreview(ReadingStateSnapshot snapshot, DateTime targetDate) {
  final pageCount = snapshot.pageCount;
  final currentPage = snapshot.currentPage;
  if (pageCount == null) {
    return 'A data alvo pode ser salva, mas esta edição não tem total de páginas para calcular páginas por dia.';
  }
  if (currentPage == null) {
    return 'Registre uma página para calcular páginas por dia.';
  }
  final today = DateTime.now();
  final days = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (days <= 0) return 'Escolha uma data futura.';
  final remaining = (pageCount - currentPage).clamp(0, pageCount).toInt();
  final perDay = (remaining / days).ceil();
  return '$remaining páginas em $days dias: $perDay páginas por dia.';
}

bool _isDemanding(ReadingStateSnapshot snapshot, DateTime targetDate) {
  final pageCount = snapshot.pageCount;
  final currentPage = snapshot.currentPage;
  if (pageCount == null || currentPage == null) return false;
  final today = DateTime.now();
  final days = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (days <= 0) return true;
  return ((pageCount - currentPage) / days).ceil() >= 45;
}

String _progressLabel(ReadingStateSnapshot snapshot) {
  final page = snapshot.currentPage;
  final pageCount = snapshot.pageCount;
  if (page != null && pageCount != null) return 'Página $page de $pageCount.';
  if (snapshot.progressPercent > 0) return '${snapshot.progressPercent}% lido.';
  return 'Ainda sem progresso registrado.';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
