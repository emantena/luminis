import 'package:flutter/material.dart';

import '../../../app/theme/luminis_colors.dart';
import '../../../app/theme/luminis_spacing.dart';
import '../../../app/theme/luminis_typography.dart';

/// Estado vazio reutilizável conforme o design system do Luminis.
class LuminisEmptyState extends StatelessWidget {
  const LuminisEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminisSpacing.sectionGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: LuminisColors.primary),
            const SizedBox(height: LuminisSpacing.listItemGap),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminisTypography.sectionTitle,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminisTypography.body.copyWith(
                color: LuminisColors.ink.withValues(alpha: 0.72),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: LuminisSpacing.listItemGap),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
