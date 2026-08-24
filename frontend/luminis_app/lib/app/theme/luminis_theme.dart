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
          onSecondary: LuminisColors.onAccent,
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
      appBarTheme: AppBarTheme(
        backgroundColor: LuminisColors.canvas,
        foregroundColor: LuminisColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: LuminisTypography.screenTitle,
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
          backgroundColor: LuminisColors.action,
          foregroundColor: LuminisColors.onAction,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(LuminisSpacing.minTouchTarget + 4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminisRadii.card),
          ),
          textStyle: LuminisTypography.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
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
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? LuminisColors.warm.withValues(alpha: 0.72)
                : LuminisColors.surface;
          }),
          foregroundColor: const WidgetStatePropertyAll(LuminisColors.ink),
          side: WidgetStateProperty.resolveWith((states) {
            return BorderSide(
              color: states.contains(WidgetState.selected)
                  ? LuminisColors.accent
                  : LuminisColors.line,
            );
          }),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LuminisColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: LuminisColors.accent.withValues(alpha: 0.22),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminisRadii.card),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? LuminisColors.onAccent
                : LuminisColors.ink.withValues(alpha: 0.58),
            size: selected ? 27 : 25,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return LuminisTypography.labelChip.copyWith(
            color: selected
                ? LuminisColors.ink
                : LuminisColors.ink.withValues(alpha: 0.62),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
      ),
    );
  }
}
