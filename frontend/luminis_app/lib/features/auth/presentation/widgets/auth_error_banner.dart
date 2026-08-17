import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';

/// Alerta compacto para erro geral de formulário (não associado a um
/// campo específico), ex.: `auth.invalid_credentials`, `auth.account_locked`
/// ou falha de rede — conforme `docs/ux/prototype-screens.md` ("Erros devem
/// aparecer próximos ao campo ou como alerta compacto, sem expor detalhes
/// sensíveis") e `docs/ux/design-system.md` (`Coral` para estados que
/// precisam de atenção).
///
/// `message` já chega segura para exibição — ver `ApiFailure.message` em
/// `lib/shared/infrastructure/api_exception.dart`.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(LuminisSpacing.listItemGap),
        margin: const EdgeInsets.only(bottom: LuminisSpacing.listItemGap),
        decoration: BoxDecoration(
          color: LuminisColors.coral.withValues(alpha: 0.08),
          border: Border.all(color: LuminisColors.coral),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: LuminisColors.coral,
              size: 20,
            ),
            const SizedBox(width: LuminisSpacing.listItemGap),
            Expanded(
              child: Text(
                message,
                style: LuminisTypography.body.copyWith(
                  color: LuminisColors.coral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
