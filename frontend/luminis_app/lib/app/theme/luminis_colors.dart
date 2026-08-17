import 'package:flutter/widgets.dart';

/// Paleta de cores aprovada em `docs/ux/design-system.md`.
///
/// Os nomes seguem os tokens documentados (Primary, Accent, Ink, Surface,
/// Canvas, Line, Coral, Warm) para manter rastreabilidade com o design
/// system. Não redefinir valores fora deste arquivo.
abstract final class LuminisColors {
  /// Navegação, elementos estruturais e apoio visual.
  static const Color primary = Color(0xFF5F7FA5);

  /// Marca, progresso, conquistas, metas e ações de destaque.
  static const Color accent = Color(0xFFF59F0A);

  /// Texto principal e superfícies escuras.
  static const Color ink = Color(0xFF303744);

  /// Cards e áreas elevadas.
  static const Color surface = Color(0xFFFFFFFF);

  /// Fundo principal do app.
  static const Color canvas = Color(0xFFF3F4F6);

  /// Bordas, divisores e trilhas de progresso.
  static const Color line = Color(0xFFD7DDE6);

  /// Alertas, ações destrutivas e estados que precisam de atenção.
  static const Color coral = Color(0xFFD95F55);

  /// Chips suaves, status de leitura e destaques secundários.
  static const Color warm = Color(0xFFE9CA88);
}
