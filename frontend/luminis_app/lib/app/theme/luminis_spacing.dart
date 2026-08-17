/// Tokens de espaçamento, raio e área mínima de toque aprovados em
/// `docs/ux/design-system.md`.
abstract final class LuminisSpacing {
  static const double screenMargin = 16;
  static const double sectionGap = 24;
  static const double listItemGap = 12;
  static const double minTouchTarget = 44;
}

/// Tokens de raio de borda aprovados em `docs/ux/design-system.md`.
abstract final class LuminisRadii {
  static const double card = 8;
  static const double cover = 6;

  /// Raio total (pill), usado em chips e botões pequenos.
  static const double pill = 999;
}
