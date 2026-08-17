/// Validações client-side mínimas e compartilhadas pelos formulários de
/// `auth`.
///
/// Servem apenas para evitar round-trips óbvios (campo vazio, formato de
/// email claramente inválido) antes de chamar o controller. Regra de
/// negócio (política de senha, credenciais inválidas, email já em uso,
/// token de redefinição inválido etc.) continua vindo do backend mockado
/// via `fieldErrors`/`errorMessage` — nenhuma regra nova é introduzida
/// aqui.
final RegExp authEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Retorna [message] quando [value] está vazio (após `trim`), ou `null`
/// quando preenchido.
String? requiredFieldError(String? value, String message) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

/// Combina verificação de campo obrigatório com formato básico de email.
String? emailFormatError(String? value) {
  final String? requiredError = requiredFieldError(value, 'Informe seu email.');
  if (requiredError != null) {
    return requiredError;
  }
  if (!authEmailPattern.hasMatch(value!.trim())) {
    return 'Informe um email válido.';
  }
  return null;
}
