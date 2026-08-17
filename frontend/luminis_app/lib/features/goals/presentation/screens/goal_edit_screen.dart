import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Edição de meta ativa (`/goals/:readingGoalId/edit`), dentro da branch
/// Metas.
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo formulário real, seguindo
/// `docs/ux/prototypes/edit-goal-screen-preview.png`. O `readingGoalId`
/// chega via `state.pathParameters['readingGoalId']` no `GoRoute` (ver
/// `lib/app/router/app_router.dart`).
class GoalEditScreen extends StatelessWidget {
  const GoalEditScreen({required this.readingGoalId, super.key});

  final String readingGoalId;

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(routeLabel: 'Editar meta · $readingGoalId');
  }
}
