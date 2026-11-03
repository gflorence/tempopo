import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import 'illustration.dart';

/// Ouvre la fenêtre d'édition d'une étape.
/// Renvoie l'étape modifiée, ou null si l'utilisateur annule.
/// [isNew] : nouvelle étape, le type est alors proposé automatiquement.
Future<RecipeStep?> showStepEditor(
  BuildContext context, {
  required RecipeStep step,
  required int stepNumber,
  required bool isLast,
  bool isNew = false,
}) {
  return showModalBottomSheet<RecipeStep>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => StepEditorSheet(
      step: step,
      stepNumber: stepNumber,
      isLast: isLast,
      isNew: isNew,
    ),
  );
}

class StepEditorSheet extends StatefulWidget {
  const StepEditorSheet({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.isLast,
    this.isNew = false,
  });

  final RecipeStep step;
  final int stepNumber;

  /// La dernière étape n'a pas de rappel (c'est le message de fin qui s'affiche).
  final bool isLast;
  final bool isNew;

  @override
  State<StepEditorSheet> createState() => _StepEditorSheetState();
}

class _StepEditorSheetState extends State<StepEditorSheet> {
  late Duration _duration;
  late StepKind _kind;

  /// Tant que l'utilisateur n'a pas choisi de type, on le propose.
  late bool _kindAuto;

  late final TextEditingController _nameController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _reminderController;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.step.durationSeconds);
    _kind = widget.step.kind;
    _kindAuto = widget.isNew;
    _nameController = TextEditingController(text: widget.step.name);
    _temperatureController =
        TextEditingController(text: widget.step.temperature);
    _reminderController = TextEditingController(text: widget.step.reminder);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _temperatureController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  bool get _isValid => _duration.inSeconds > 0;

  void _suggestKind() {
    if (!_kindAuto) return;
    final guess = StepKind.guess(
      name: _nameController.text,
      temperature: _temperatureController.text,
    );
    if (guess != _kind) setState(() => _kind = guess);
  }

  void _chooseKind(StepKind kind) {
    setState(() {
      _kind = kind;
      _kindAuto = false;
    });
  }

  void _submit() {
    if (!_isValid) return;
    Navigator.of(context).pop(
      widget.step.copyWith(
        durationSeconds: _duration.inSeconds,
        kind: _kind,
        name: _nameController.text,
        temperature: _temperatureController.text,
        reminder: _reminderController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.stepNumber(widget.stepNumber),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Grande durée, lisible de loin.
            Text(
              s.duration(_duration.inSeconds),
              textAlign: TextAlign.center,
              style: TempopoTypography.timer(
                40,
                color: _isValid ? palette.accentText : theme.colorScheme.error,
              ),
            ),
            SizedBox(
              height: 190,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: _duration,
                onTimerDurationChanged: (value) =>
                    setState(() => _duration = value),
              ),
            ),
            if (!_isValid)
              Text(
                s.durationRequired,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            const SizedBox(height: 16),

            // Type d'étape
            Row(
              children: [
                Text(s.stepType, style: theme.textTheme.titleMedium),
                if (_kindAuto) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '· ${s.suggestedType}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: palette.mutedText),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _KindSelector(selected: _kind, onSelected: _chooseKind),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => _suggestKind(),
              decoration: InputDecoration(
                labelText: s.stepName,
                hintText: s.stepNameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _temperatureController,
              onChanged: (_) => _suggestKind(),
              decoration: InputDecoration(
                labelText: s.temperature,
                hintText: s.temperatureHint,
              ),
            ),
            if (!widget.isLast) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reminderController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: s.reminderAfterStep,
                  hintText: s.reminderHint,
                  prefixIcon: const Icon(Icons.notifications_active_outlined),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isValid ? _submit : null,
                    child: Text(s.validate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur des 5 types d'étape (icône + nom).
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.selected, required this.onSelected});

  final StepKind selected;
  final ValueChanged<StepKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Row(
      children: [
        for (final kind in StepKind.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Semantics(
                button: true,
                selected: kind == selected,
                label: s.stepKindName(kind),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(kind),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: kind == selected
                          ? scheme.primaryContainer
                          : palette.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: kind == selected
                            ? scheme.primary
                            : palette.divider,
                        width: kind == selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StepKindIcon(
                          kind: kind,
                          size: 28,
                          color: kind == selected
                              ? scheme.onPrimaryContainer
                              : palette.mutedText,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s.stepKindName(kind),
                            style: TempopoTypography.manrope(12, weight: 700)
                                .copyWith(
                              color: kind == selected
                                  ? scheme.onPrimaryContainer
                                  : palette.mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}