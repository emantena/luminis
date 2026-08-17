import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Aba raiz Metas (`/goals`).
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo conteúdo real, seguindo
/// `docs/ux/prototypes/goals-screen-preview.png`.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoutePlaceholderScreen(routeLabel: 'Metas');
  }
}
