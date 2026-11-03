import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_services.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';

/// Minuteur rapide : une durée, un nom facultatif, sans enregistrer de recette.
Future<void> startQuickTimer(BuildContext context) async {
  final services = AppServices.of(context);
  final s = S.of(context);

  final result = await showModalBottomSheet<(Duration, String)>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _QuickTimerSheet(),
  );
  if (result == null) return;

  final (duration, name) = result;
  final recipe = Recipe(
    id: generateId(),
    name: name.trim().isEmpty ? s.quickTimer : name.trim(),
    illustration: RecipeIllustration.minuteur,
    steps: [RecipeStep(durationSeconds: duration.inSeconds)],
    lastUsedAt: DateTime.now(),
  );
  await services.engine.launch(recipe, quick: true);
  HapticFeedback.mediumImpact();
  services.openRunning();
}

class _QuickTimerSheet extends StatefulWidget {
  const _QuickTimerSheet();

  @override
  State<_QuickTimerSheet> createState() => _QuickTimerSheetState();
}

class _QuickTimerSheetState extends State<_QuickTimerSheet> {
  Duration _duration = const Duration(minutes: 5);
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _duration.inSeconds > 0;

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
            Text(s.quickTimer, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
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
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.quickTimerName,
                hintText: s.quickTimerNameHint,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isValid
                  ? () => Navigator.of(context)
                      .pop((_duration, _nameController.text))
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                textStyle: TempopoTypography.manrope(18, weight: 800),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 30),
              label: Text(s.start),
            ),
          ],
        ),
      ),
    );
  }
}