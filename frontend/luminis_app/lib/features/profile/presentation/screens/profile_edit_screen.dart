import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Edição de perfil (`/profile/edit`), dentro da branch Perfil.
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo formulário real. Sem preview visual dedicado (ver
/// `docs/ux/flutter-prototype-handoff.md`, seção "Pendências assumidas").
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoutePlaceholderScreen(routeLabel: 'Editar perfil');
  }
}
