import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_colors.dart';

/// Ação primária compartilhada pelos formulários de `auth`.
///
/// Usa o estilo já definido em `LuminisTheme.light()`
/// (`elevatedButtonTheme`: fundo `Accent`, texto `Ink`, altura mínima 48,
/// raio 8 — ver `docs/ux/design-system.md`, componente `PrimaryButton`) e
/// troca o rótulo por um indicador de progresso durante `isLoading`, sem
/// desabilitar visualmente o botão além do necessário.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(LuminisColors.ink),
              ),
            )
          : Text(label),
    );
  }
}
