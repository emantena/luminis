import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_colors.dart';
import '../../../../app/theme/luminis_logo.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';

/// Tela pública de boas-vindas (`/auth/welcome`).
///
/// Entrada pública do app (`docs/ux/prototype-screens.md`): apresenta a
/// marca e as duas ações principais do fluxo mockado — entrar com
/// email/senha e criar conta.
///
/// `Entrar com Google` é citado no mesmo documento como prioridade para
/// Android, e `SessionController.loginWithGoogle` já existe para suportar
/// esse fluxo. Fica fora desta entrega porque exigiria uma dependência
/// nativa de Sign-In ainda não avaliada por
/// `docs/architecture/flutter-dependencies.md`/ADR — decisão fora do
/// escopo deste agente; recomendado para `luminis-product-agent`/decisão
/// de dependência antes de implementar o botão real.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
          child: Column(
            children: [
              const Spacer(),
              // O asset oficial inclui margens transparentes; esta altura
              // mantém a marca legível sem repetir seu nome em texto.
              const LuminisLogo(height: 200),
              const SizedBox(height: 4),
              Text(
                'Organize sua estante, acompanhe seu progresso e cumpra '
                'suas metas de leitura.',
                style: LuminisTypography.body.copyWith(
                  color: LuminisColors.ink.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushNamed(AppRouteNames.authLogin),
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: LuminisSpacing.listItemGap),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      context.pushNamed(AppRouteNames.authRegister),
                  child: const Text('Criar conta'),
                ),
              ),
              const SizedBox(height: LuminisSpacing.screenMargin),
            ],
          ),
        ),
      ),
    );
  }
}
