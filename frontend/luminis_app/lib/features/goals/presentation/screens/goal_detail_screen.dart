import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/route_placeholder_screen.dart';

/// Detalhe de meta (`/goals/:readingGoalId`), dentro da branch Metas.
///
/// Placeholder provisório: `luminis-flutter-agent` deve substituir o
/// `build` pelo conteúdo real, seguindo
/// `docs/ux/prototypes/goal-detail-screen-preview.png`. O `readingGoalId`
/// chega via `state.pathParameters['readingGoalId']` no `GoRoute` (ver
/// `lib/app/router/app_router.dart`).
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({required this.readingGoalId, super.key});

  final String readingGoalId;

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholderScreen(routeLabel: 'Meta · $readingGoalId');
  }
}
