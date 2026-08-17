import 'package:flutter/material.dart';

import 'luminis_colors.dart';

/// Escala tipográfica aprovada em `docs/ux/design-system.md`.
///
/// O design system recomenda `Inter` como direção inicial, com fallback
/// para fonte nativa quando o pacote de fonte não estiver aprovado/incluído
/// no projeto. Nenhuma fonte customizada está registrada em `pubspec.yaml`
/// hoje, então `fontFamily` fica deliberadamente nulo para usar o fallback
/// nativo já previsto pela documentação.
abstract final class LuminisTypography {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    color: LuminisColors.ink,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
    color: LuminisColors.ink,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w700,
    color: LuminisColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: LuminisColors.ink,
  );

  static const TextStyle metadata = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: LuminisColors.ink,
  );

  static const TextStyle labelChip = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: LuminisColors.ink,
  );

  static TextTheme toTextTheme() {
    return const TextTheme(
      titleLarge: screenTitle,
      titleMedium: sectionTitle,
      titleSmall: cardTitle,
      bodyMedium: body,
      bodySmall: metadata,
      labelMedium: labelChip,
    );
  }
}
