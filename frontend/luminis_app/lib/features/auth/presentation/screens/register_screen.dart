import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../controllers/register_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Tela pública de cadastro (`/auth/register`).
///
/// Consome `registerControllerProvider` e delega a navegação pós-sucesso
/// ao redirect do `go_router` (observa `sessionControllerProvider`) — este
/// widget nunca navega manualmente para a estante em caso de sucesso.
///
/// `confirmPassword` existe apenas nesta tela, para capturar erro de
/// digitação antes de enviar; não é enviado ao controller/backend
/// (`RegisterController.submit` não tem esse parâmetro).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, String> _localErrors = const {};

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final Map<String, String> localErrors = {};

    final String? nameError = requiredFieldError(
      _displayNameController.text,
      'Informe seu nome de exibição.',
    );
    if (nameError != null) {
      localErrors['displayName'] = nameError;
    }

    final String? emailError = emailFormatError(_emailController.text);
    if (emailError != null) {
      localErrors['email'] = emailError;
    }

    final String? passwordError = requiredFieldError(
      _passwordController.text,
      'Informe uma senha.',
    );
    if (passwordError != null) {
      localErrors['password'] = passwordError;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      localErrors['confirmPassword'] = 'As senhas não coincidem.';
    }

    setState(() => _localErrors = localErrors);
    if (localErrors.isNotEmpty) {
      return;
    }

    await ref
        .read(registerControllerProvider.notifier)
        .submit(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final RegisterFormState formState = ref.watch(registerControllerProvider);

    return AuthScaffold(
      title: 'Criar conta',
      children: [
        if (formState.errorMessage != null)
          AuthErrorBanner(message: formState.errorMessage!),
        Text(
          'Crie sua conta com nome, email e senha.',
          style: LuminisTypography.body,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        TextField(
          controller: _displayNameController,
          enabled: !formState.isSubmitting,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: authInputDecoration(
            label: 'Nome de exibição',
            errorText:
                formState.fieldErrors['displayName']?.first ??
                _localErrors['displayName'],
          ),
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        TextField(
          controller: _emailController,
          enabled: !formState.isSubmitting,
          keyboardType: TextInputType.emailAddress,
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
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
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
        const SizedBox(height: LuminisSpacing.listItemGap),
        TextField(
          controller: _confirmPasswordController,
          enabled: !formState.isSubmitting,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: authInputDecoration(
            label: 'Confirmar senha',
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
          label: 'Criar conta',
          isLoading: formState.isSubmitting,
          onPressed: _submit,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Já tem conta?', style: LuminisTypography.body),
            TextButton(
              onPressed: formState.isSubmitting
                  ? null
                  : () => _goToLogin(context),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Volta para o login: usa `pop` quando o cadastro foi empilhado a partir
/// de `/auth/login` (caso comum, ver `WelcomeScreen`/`LoginScreen`); usa
/// `pushReplacementNamed` como fallback para acesso direto a `/auth/register`
/// sem histórico, evitando empilhar cadastro sobre login indefinidamente.
void _goToLogin(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.pushReplacementNamed(AppRouteNames.authLogin);
  }
}
