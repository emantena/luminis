import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';

/// Decoração de campo compartilhada pelos formulários de `auth`.
///
/// `LuminisTheme` não define um `InputDecorationTheme` próprio; esta
/// função aplica os tokens de `docs/ux/design-system.md` diretamente
/// (raio de card 8px, borda `Line`, foco `Primary`, erro `Coral`) para
/// manter os campos de texto consistentes com o restante do app.
InputDecoration authInputDecoration({
  required String label,
  String? errorText,
  Widget? suffixIcon,
}) {
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(LuminisRadii.card),
    borderSide: const BorderSide(color: LuminisColors.line),
  );

  return InputDecoration(
    labelText: label,
    errorText: errorText,
    errorMaxLines: 3,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: LuminisColors.surface,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.primary, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.coral),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: LuminisColors.coral, width: 2),
    ),
  );
}
