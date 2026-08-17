import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_spacing.dart';

/// Layout compartilhado das telas públicas de formulário de `auth`
/// (login, cadastro, esqueci senha, redefinir senha).
///
/// Mantém `AppBar` com título e ação de voltar padrão do Flutter, corpo
/// rolável (evita overflow com teclado) e margem lateral consistente com
/// `docs/ux/design-system.md` (`LuminisSpacing.screenMargin`).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LuminisSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
