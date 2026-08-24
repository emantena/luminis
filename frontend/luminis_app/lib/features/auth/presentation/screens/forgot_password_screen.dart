import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Tela pública de solicitação de recuperação de senha
/// (`/auth/forgot-password`).
///
/// Consome `forgotPasswordControllerProvider`. Este fluxo nunca autentica
/// o usuário: em sucesso, exibe mensagem neutra — sem confirmar ou negar
/// se o email existe (`docs/ux/prototype-screens.md`,
/// `docs/architecture/backend-contracts.md`) — e oferece um caminho para
/// digitar o código/token recebido.
///
/// Decisão mínima deste agente sobre a transição para `/auth/reset-password`:
/// `docs/ux/prototype-screens.md` não especifica a navegação exata entre
/// as duas telas de recuperação; como o protótipo mockado não envia email
/// de fato, o caminho mais curto é oferecer um atalho explícito ("Já tenho
/// um código") a partir da mensagem de sucesso, em vez de redirecionar
/// automaticamente.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String? emailError = emailFormatError(_emailController.text);
    setState(() => _localError = emailError);
    if (emailError != null) {
      return;
    }

    await ref
        .read(forgotPasswordControllerProvider.notifier)
        .submit(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordFormState formState = ref.watch(
      forgotPasswordControllerProvider,
    );

    if (formState.isSuccess) {
      return AuthScaffold(
        title: 'Esqueci minha senha',
        children: [
          Text('Verifique seu email', style: LuminisTypography.sectionTitle),
          const SizedBox(height: LuminisSpacing.listItemGap),
          Text(
            'Se o email informado existir em nossa base, enviaremos '
            'instruções para redefinir sua senha.',
            style: LuminisTypography.body,
          ),
          const SizedBox(height: LuminisSpacing.sectionGap),
          AuthPrimaryButton(
            label: 'Já tenho um código',
            isLoading: false,
            onPressed: () => context.pushNamed(AppRouteNames.authResetPassword),
          ),
          const SizedBox(height: LuminisSpacing.listItemGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.pushReplacementNamed(AppRouteNames.authLogin),
              child: const Text('Voltar para login'),
            ),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Esqueci minha senha',
      children: [
        if (formState.errorMessage != null)
          AuthErrorBanner(message: formState.errorMessage!),
        Text(
          'Informe o email da sua conta para receber instruções de '
          'redefinição de senha.',
          style: LuminisTypography.body,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        TextField(
          controller: _emailController,
          enabled: !formState.isSubmitting,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _submit(),
          decoration: authInputDecoration(
            label: 'Email',
            errorText: formState.fieldErrors['email']?.first ?? _localError,
          ),
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        AuthPrimaryButton(
          label: 'Enviar instruções',
          isLoading: formState.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
