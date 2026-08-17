import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Criação de meta mensal/anual (`/goals/new`), dentro da branch Metas.
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo formulário real, seguindo
/// `docs/ux/prototypes/create-goal-screen-preview.png`.
class GoalNewScreen extends StatelessWidget {
  const GoalNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoutePlaceholderScreen(routeLabel: 'Criar meta');
  }
}
