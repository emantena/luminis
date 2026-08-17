import 'package:flutter/material.dart';

import '../../../app/theme/luminis_colors.dart';
import '../../../app/theme/luminis_spacing.dart';
import '../../../app/theme/luminis_typography.dart';

/// Capa de livro/edição reutilizada na estante, busca, detalhe e cadastro
/// local, conforme componente `BookCover` de `docs/ux/design-system.md`.
///
/// Proporção 2:3, raio 6px. Sem capa (ou falha de rede), cai no fallback em
/// `Primary` com o título abreviado — nunca aparenta erro.
class BookCover extends StatelessWidget {
  const BookCover({
    required this.title,
    this.coverUrl,
    this.width = 56,
    this.height = 84,
    super.key,
  });

  final String title;
  final String? coverUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? url = coverUrl;
    return Semantics(
      image: true,
      label: url == null || url.isEmpty
          ? 'Capa indisponível para $title'
          : 'Capa de $title',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LuminisRadii.cover),
        child: SizedBox(
          width: width,
          height: height,
          child: url == null || url.isEmpty
              ? _Fallback(title: title)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _Fallback(title: title),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const _Fallback(title: null);
                  },
                ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        color: LuminisColors.primary,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(LuminisSpacing.listItemGap / 2),
        child: title == null
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LuminisColors.surface,
                  ),
                ),
              )
            : Text(
                _abbreviate(title!),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: LuminisTypography.labelChip.copyWith(
                  color: LuminisColors.surface,
                ),
              ),
      ),
    );
  }
}

String _abbreviate(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.length <= 60 ? trimmed : '${trimmed.substring(0, 57)}…';
}
