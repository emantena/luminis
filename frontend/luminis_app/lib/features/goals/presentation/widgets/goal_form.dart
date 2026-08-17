import 'package:flutter/material.dart';

import '../../../../app/theme/luminis_spacing.dart';
import '../../../../app/theme/luminis_typography.dart';
import '../../domain/entities/reading_goal.dart';
import 'goal_ui.dart';

class GoalForm extends StatefulWidget {
  const GoalForm({
    required this.submitLabel,
    required this.isSubmitting,
    required this.onSubmit,
    this.canEditGoalShape = true,
    this.initialGoal,
    this.errorMessage,
    super.key,
  });

  final String submitLabel;
  final bool isSubmitting;
  final String? errorMessage;
  final bool canEditGoalShape;
  final ReadingGoal? initialGoal;
  final Future<void> Function({
    required GoalPeriodType periodType,
    required GoalMetricType metricType,
    required int targetValue,
    required bool isPublic,
  })
  onSubmit;

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  late GoalPeriodType _periodType;
  late GoalMetricType _metricType;
  late bool _isPublic;
  late final TextEditingController _targetController;
  String? _targetError;

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;
    _periodType = goal?.periodType ?? GoalPeriodType.monthly;
    _metricType = goal?.metricType ?? GoalMetricType.booksRead;
    _isPublic = goal?.isPublic ?? false;
    _targetController = TextEditingController(
      text: goal?.targetValue.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = int.tryParse(_targetController.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LuminisSpacing.screenMargin,
        LuminisSpacing.listItemGap,
        LuminisSpacing.screenMargin,
        LuminisSpacing.sectionGap,
      ),
      children: [
        Text('Período', style: LuminisTypography.sectionTitle),
        const SizedBox(height: 8),
        SegmentedButton<GoalPeriodType>(
          segments: const [
            ButtonSegment(value: GoalPeriodType.monthly, label: Text('Mensal')),
            ButtonSegment(value: GoalPeriodType.yearly, label: Text('Anual')),
          ],
          selected: {_periodType},
          onSelectionChanged: widget.canEditGoalShape
              ? (selection) => setState(() => _periodType = selection.first)
              : null,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        Text('Métrica', style: LuminisTypography.sectionTitle),
        const SizedBox(height: 8),
        SegmentedButton<GoalMetricType>(
          segments: const [
            ButtonSegment(
              value: GoalMetricType.booksRead,
              label: Text('Livros'),
            ),
            ButtonSegment(
              value: GoalMetricType.pagesRead,
              label: Text('Páginas'),
            ),
          ],
          selected: {_metricType},
          onSelectionChanged: widget.canEditGoalShape
              ? (selection) => setState(() => _metricType = selection.first)
              : null,
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor alvo',
            suffixText: metricUnit(_metricType),
            errorText: _targetError,
          ),
          onChanged: (_) {
            if (_targetError != null) setState(() => _targetError = null);
          },
        ),
        const SizedBox(height: LuminisSpacing.listItemGap),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Meta pública'),
          subtitle: const Text('Privada por padrão'),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
        ),
        const SizedBox(height: LuminisSpacing.sectionGap),
        Text(_summaryFor(target), style: LuminisTypography.body),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: LuminisSpacing.listItemGap),
          Text(
            widget.errorMessage!,
            style: LuminisTypography.body.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: LuminisSpacing.sectionGap),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submit,
            child: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }

  String _summaryFor(int? target) {
    final value = target == null || target <= 0 ? '...' : target.toString();
    final metric = metricUnit(_metricType);
    final period = _periodType == GoalPeriodType.monthly
        ? 'neste mês'
        : 'em ${DateTime.now().year}';
    return 'Ler $value $metric $period.';
  }

  Future<void> _submit() async {
    final target = int.tryParse(_targetController.text);
    if (target == null || target <= 0) {
      setState(() => _targetError = 'Informe um alvo maior que zero.');
      return;
    }
    await widget.onSubmit(
      periodType: _periodType,
      metricType: _metricType,
      targetValue: target,
      isPublic: _isPublic,
    );
  }
}
