import 'package:flutter/material.dart';

import 'luminis_colors.dart';
import 'luminis_spacing.dart';
import 'luminis_typography.dart';

/// Monta o `ThemeData` do Luminis a partir dos tokens de
/// `docs/ux/design-system.md` (paleta, tipografia e espaçamento).
///
/// O MVP não define tema escuro; apenas o tema claro é fornecido aqui.
abstract final class LuminisTheme {
  static ThemeData light() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: LuminisColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: LuminisColors.primary,
          onPrimary: LuminisColors.surface,
          secondary: LuminisColors.accent,
          onSecondary: LuminisColors.ink,
          surface: LuminisColors.surface,
          onSurface: LuminisColors.ink,
          error: LuminisColors.coral,
          onError: LuminisColors.surface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LuminisColors.canvas,
      textTheme: LuminisTypography.toTextTheme(),
      dividerColor: LuminisColors.line,
      dividerTheme: const DividerThemeData(
        color: LuminisColors.line,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: LuminisColors.surface,
        surfaceTintColor: LuminisColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminisRadii.card),
          side: const BorderSide(color: LuminisColors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LuminisColors.accent,
          foregroundColor: LuminisColors.ink,
          minimumSize: const Size.fromHeight(LuminisSpacing.minTouchTarget + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminisRadii.card),
          ),
          textStyle: LuminisTypography.body.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LuminisColors.ink,
          side: const BorderSide(color: LuminisColors.line),
          minimumSize: const Size.fromHeight(LuminisSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminisRadii.card),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LuminisColors.surface,
        selectedItemColor: LuminisColors.accent,
        unselectedItemColor: LuminisColors.ink.withValues(alpha: 0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
