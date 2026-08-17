import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Aba raiz Perfil (`/profile`).
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo conteúdo real (incluindo logout, via
/// `sessionControllerProvider.notifier.logout()`), seguindo
/// `docs/ux/prototypes/profile-screen-preview.png`.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoutePlaceholderScreen(routeLabel: 'Perfil');
  }
}
