import 'package:flutter/material.dart';

import '../../../app/theme/luminis_spacing.dart';
import '../../../app/theme/luminis_typography.dart';
import 'book_cover.dart';

/// Item de estante ou resultado de busca, conforme componente `BookCard` de
/// `docs/ux/design-system.md`.
///
/// Layout horizontal fixo: capa à esquerda, título/metadado/status no
/// centro, ação opcional à direita.
class BookCard extends StatelessWidget {
  const BookCard({
    required this.title,
    this.coverUrl,
    this.metadata,
    this.status,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String? coverUrl;

  /// Autor, edição/idioma ou outro metadado principal (uma ou duas linhas).
  final String? metadata;

  /// Status/contexto (ex.: `BookshelfStatusChip`), exibido apenas quando
  /// ajuda a decisão do usuário.
  final Widget? status;

  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? title,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(LuminisRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(LuminisSpacing.listItemGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: BookCover(title: title, coverUrl: coverUrl),
                ),
                const SizedBox(width: LuminisSpacing.listItemGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: LuminisTypography.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metadata != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          metadata!,
                          style: LuminisTypography.metadata,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (status != null) ...[
                        const SizedBox(height: 8),
                        status!,
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
