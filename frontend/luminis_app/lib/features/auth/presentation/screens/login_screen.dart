import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Tela pública de login por email/senha (`/auth/login`).
///
/// Consome `loginControllerProvider` (estado do formulário) e delega a
/// navegação pós-sucesso ao redirect do `go_router`, que observa
/// `sessionControllerProvider` — este widget nunca navega manualmente para
/// a estante em caso de sucesso.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  Map<String, String> _localErrors = const {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final Map<String, String> localErrors = {};
    final String? emailError = emailFormatError(_emailController.text);
    if (emailError != null) {
      localErrors['email'] = emailError;
    }
    final String? passwordError = requiredFieldError(
      _passwordController.text,
      'Informe sua senha.',
    );
    if (passwordError != null) {
      localErrors['password'] = passwordError;
    }

    setState(() => _localErrors = localErrors);
    if (localErrors.isNotEmpty) {
      return;
    }

    await ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final LoginFormState formState = ref.watch(loginControllerProvider);

    return AuthScaffold(
      title: 'Entrar',
      children: [
        if (formState.errorMessage != null)
          AuthErrorBanner(message: formState.errorMessage!),
        Text(
          'Entre com seu email e senha para continuar.',
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
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: authInputDecoration(
            label: 'Email',
            errorText:
                formState.fieldErrors['email']?.first ?? _localErrors['email'],
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
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
          decoration: authInputDecoration(
            label: 'Senha',
            errorText:
                formState.fieldErrors['password']?.first ??
                _localErrors['password'],
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: formState.isSubmitting
                ? null
                : () => context.pushNamed(AppRouteNames.authForgotPassword),
            child: const Text('Esqueci minha senha'),
          ),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        AuthPrimaryButton(
          label: 'Entrar',
          isLoading: formState.isSubmitting,
          onPressed: _submit,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ainda não tem conta?', style: LuminisTypography.body),
            TextButton(
              onPressed: formState.isSubmitting
                  ? null
                  : () => context.pushNamed(AppRouteNames.authRegister),
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ],
    );
  }
}
