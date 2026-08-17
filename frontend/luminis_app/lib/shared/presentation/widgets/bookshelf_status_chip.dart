import 'package:flutter/material.dart';

import '../../../app/theme/luminis_spacing.dart';
import '../../../app/theme/luminis_typography.dart';
import '../../../features/bookshelf/domain/entities/reading_status.dart';

/// Pill de status de leitura, conforme componente `BookshelfStatusChip` e o
/// mapeamento de cores de `docs/ux/design-system.md`.
///
/// As cores de status são valores fixos do mapeamento aprovado (fora da
/// paleta base de `LuminisColors`), por isso ficam declaradas aqui em vez de
/// promovidas a token compartilhado.
class BookshelfStatusChip extends StatelessWidget {
  const BookshelfStatusChip({required this.status, super.key});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style = _styleFor(status);
    return Semantics(
      label: 'Status de leitura: ${style.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminisSpacing.listItemGap,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(LuminisRadii.pill),
        ),
        child: Text(
          style.label,
          style: LuminisTypography.labelChip.copyWith(color: style.foreground),
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_StatusStyle _styleFor(ReadingStatus status) {
  const Color surface = Color(0xFFFFFFFF);
  const Color ink = Color(0xFF303744);
  return switch (status) {
    ReadingStatus.read => const _StatusStyle(
      label: 'Lido',
      background: Color(0xFF4FB38A),
      foreground: surface,
    ),
    ReadingStatus.reading => const _StatusStyle(
      label: 'Lendo',
      background: Color(0xFFF59F0A),
      foreground: ink,
    ),
    ReadingStatus.paused => const _StatusStyle(
      label: 'Pausado',
      background: Color(0xFF596574),
      foreground: surface,
    ),
    ReadingStatus.wantToRead => const _StatusStyle(
      label: 'Quero ler',
      background: Color(0xFF2F80D1),
      foreground: surface,
    ),
    ReadingStatus.rereading => const _StatusStyle(
      label: 'Relendo',
      background: Color(0xFFD95F55),
      foreground: surface,
    ),
    ReadingStatus.abandoned => const _StatusStyle(
      label: 'Abandonei',
      background: ink,
      foreground: surface,
    ),
  };
}
