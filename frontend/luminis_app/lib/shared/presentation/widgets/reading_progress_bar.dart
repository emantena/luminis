import 'package:flutter/material.dart';

import '../../../app/theme/luminis_colors.dart';

class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    required this.percent,
    this.semanticLabel,
    super.key,
  });

  final int percent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100).toDouble() / 100;
    return Semantics(
      label: semanticLabel ?? 'Progresso de leitura: $percent%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 10,
          value: value,
          backgroundColor: LuminisColors.line,
          valueColor: const AlwaysStoppedAnimation<Color>(LuminisColors.accent),
        ),
      ),
    );
  }
}
