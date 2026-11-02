import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/recipe.dart';

/// Ouvre la fenêtre d'édition d'une étape.
/// Renvoie l'étape modifiée, ou null si l'utilisateur annule.
Future<RecipeStep?> showStepEditor(
  BuildContext context, {
  required RecipeStep step,
  required int stepNumber,
  required bool isLast,
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
    ),
  );
}

class StepEditorSheet extends StatefulWidget {
  const StepEditorSheet({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.isLast,
  });

  final RecipeStep step;
  final int stepNumber;

  /// La dernière étape n'a pas de rappel (c'est le message de fin qui s'affiche).
  final bool isLast;

  @override
  State<StepEditorSheet> createState() => _StepEditorSheetState();
}

class _StepEditorSheetState extends State<StepEditorSheet> {
  late Duration _duration;
  late final TextEditingController _nameController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _reminderController;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.step.durationSeconds);
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

  void _submit() {
    if (!_isValid) return;
    Navigator.of(context).pop(
      widget.step.copyWith(
        durationSeconds: _duration.inSeconds,
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
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
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
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.stepName,
                hintText: s.stepNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _temperatureController,
              decoration: InputDecoration(
                labelText: s.temperature,
                hintText: s.temperatureHint,
                border: const OutlineInputBorder(),
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
                  prefixIcon: const Icon(Icons.notifications_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(s.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isValid ? _submit : null,
                  child: Text(s.validate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}