import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../controllers/reset_password_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Tela pública de redefinição de senha (`/auth/reset-password`).
///
/// Consome `resetPasswordControllerProvider`. Este fluxo nunca autentica o
/// usuário automaticamente; em sucesso, oferece uma ação explícita para
/// seguir a `/auth/login` com a nova senha.
///
/// Decisão mínima deste agente sobre o campo de código: a rota declarada
/// em `app_router.dart` não tem segmento `:token` (path fixo
/// `/auth/reset-password`), então o token — quando presente — chega por
/// query parameter (`?token=...`, formato do link mockado de recuperação)
/// e pré-preenche o campo; o usuário também pode digitar/colar o código
/// manualmente, já que `docs/ux/prototype-screens.md` não detalha esse
/// mecanismo de entrega para o protótipo.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _tokenPrefilledFromRoute = false;
  Map<String, String> _localErrors = const {};

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tokenPrefilledFromRoute) {
      final String? queryToken = GoRouterState.of(
        context,
      ).uri.queryParameters['token'];
      if (queryToken != null && queryToken.isNotEmpty) {
        _tokenController.text = queryToken;
      }
      _tokenPrefilledFromRoute = true;
    }
  }

  Future<void> _submit() async {
    final Map<String, String> localErrors = {};

    final String? tokenError = requiredFieldError(
      _tokenController.text,
      'Informe o código de redefinição.',
    );
    if (tokenError != null) {
      localErrors['token'] = tokenError;
    }

    final String? passwordError = requiredFieldError(
      _passwordController.text,
      'Informe a nova senha.',
    );
    if (passwordError != null) {
      localErrors['newPassword'] = passwordError;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      localErrors['confirmPassword'] = 'As senhas não coincidem.';
    }

    setState(() => _localErrors = localErrors);
    if (localErrors.isNotEmpty) {
      return;
    }

    await ref
        .read(resetPasswordControllerProvider.notifier)
        .submit(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ResetPasswordFormState formState = ref.watch(
      resetPasswordControllerProvider,
    );

    if (formState.isSuccess) {
      return AuthScaffold(
        title: 'Redefinir senha',
        children: [
          Text('Senha redefinida', style: LuminisTypography.sectionTitle),
          const SizedBox(height: LuminisSpacing.listItemGap),
          Text(
            'Sua senha foi redefinida. Entre com sua nova senha para '
            'continuar.',
            style: LuminisTypography.body,
          ),
          const SizedBox(height: LuminisSpacing.sectionGap),
          AuthPrimaryButton(
            label: 'Ir para login',
            isLoading: false,
            onPressed: () => context.goNamed(AppRouteNames.authLogin),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Redefinir senha',
      children: [
        if (formState.errorMessage != null)
          AuthErrorBanner(message: formState.errorMessage!),
        Text(
          'Informe o código recebido e escolha uma nova senha.',
          style: LuminisTypography.body,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        TextField(
          controller: _tokenController,
          enabled: !formState.isSubmitting,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          decoration: authInputDecoration(
            label: 'Código de redefinição',
            errorText:
                formState.fieldErrors['token']?.first ?? _localErrors['token'],
          ),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        TextField(
          controller: _passwordController,
          enabled: !formState.isSubmitting,
          autocorrect: false,
          enableSuggestions: false,
          obscureText: _obscurePassword,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          decoration: authInputDecoration(
            label: 'Nova senha',
            errorText:
                formState.fieldErrors['newPassword']?.first ??
                _localErrors['newPassword'],
            suffixIcon: IconButton(
              tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        TextField(
          controller: _confirmPasswordController,
          enabled: !formState.isSubmitting,
          autocorrect: false,
          enableSuggestions: false,
          obscureText: _obscureConfirmPassword,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: authInputDecoration(
            label: 'Confirmar nova senha',
            errorText: _localErrors['confirmPassword'],
            suffixIcon: IconButton(
              tooltip: _obscureConfirmPassword
                  ? 'Mostrar senha'
                  : 'Ocultar senha',
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        AuthPrimaryButton(
          label: 'Salvar nova senha',
          isLoading: formState.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
