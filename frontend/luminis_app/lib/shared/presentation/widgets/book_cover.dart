import 'package:flutter/material.dart';

import '../../../app/theme/luminis_spacing.dart';
import '../../../app/theme/luminis_typography.dart';

/// Capa de livro/edição reutilizada na estante, busca, detalhe e cadastro
/// local, conforme componente `BookCover` de `docs/ux/design-system.md`.
///
/// Proporção 2:3, raio 6px. Sem capa (ou falha de rede), cai em uma capa
/// editorial determinística pelo título — nunca aparenta erro nem repete uma
/// única cor em toda a biblioteca.
class BookCover extends StatelessWidget {
  const BookCover({
    required this.title,
    this.coverUrl,
    this.width = 56,
    this.height = 84,
    this.overlay,
    super.key,
  });

  final String title;
  final String? coverUrl;
  final double width;
  final double height;

  /// Elemento opcional sobre a capa, como o marcador de status da estante.
  /// A informação textual equivalente deve continuar visível fora da capa.
  final Widget? overlay;

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
          child: Stack(
            fit: StackFit.expand,
            children: [
              url == null || url.isEmpty
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
              ?overlay,
            ],
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
    final palette = _paletteFor(title);
    return ExcludeSemantics(
      child: Container(
        decoration: BoxDecoration(color: palette.background),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 7,
                height: double.infinity,
                color: palette.accent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              child: title == null
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.foreground,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _abbreviate(title!),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: LuminisTypography.cardTitle.copyWith(
                          color: palette.foreground,
                          height: 1.12,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPalette {
  const _CoverPalette({
    required this.background,
    required this.accent,
    required this.foreground,
  });

  final Color background;
  final Color accent;
  final Color foreground;
}

_CoverPalette _paletteFor(String? title) {
  const palettes = [
    _CoverPalette(
      background: Color(0xFF5F7FA5),
      accent: Color(0xFFE9CA88),
      foreground: Color(0xFFF8FAFD),
    ),
    _CoverPalette(
      background: Color(0xFF8F514A),
      accent: Color(0xFFF0C36B),
      foreground: Color(0xFFF8FAFD),
    ),
    _CoverPalette(
      background: Color(0xFF3F6E61),
      accent: Color(0xFFE9CA88),
      foreground: Color(0xFFF8FAFD),
    ),
    _CoverPalette(
      background: Color(0xFF6A5A8D),
      accent: Color(0xFFF0C36B),
      foreground: Color(0xFFF8FAFD),
    ),
    _CoverPalette(
      background: Color(0xFF4D5969),
      accent: Color(0xFFD95F55),
      foreground: Color(0xFFF8FAFD),
    ),
  ];
  final normalized = title?.trim() ?? '';
  final hash = normalized.codeUnits.fold<int>(0, (value, unit) {
    return (value * 31 + unit) & 0x7fffffff;
  });
  return palettes[hash % palettes.length];
}

String _abbreviate(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.length <= 60 ? trimmed : '${trimmed.substring(0, 57)}…';
}
