import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/recipe_repository.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/cooking_score.dart';
import '../widgets/illustration_picker.dart';
import '../widgets/step_editor_sheet.dart';

/// Une étape dans l'éditeur, avec une clé stable (nécessaire pour le
/// déplacement et la suppression par glissement).
class _StepEntry {
  _StepEntry(this.key, this.step);

  final int key;
  RecipeStep step;
}

/// Écran de création ou de modification d'une recette.
/// Renvoie le nom de la recette si elle a été enregistrée.
class RecipeEditorScreen extends StatefulWidget {
  const RecipeEditorScreen({super.key, required this.repository, this.recipe});

  final RecipeRepository repository;

  /// Recette à modifier, ou null pour une nouvelle recette.
  final Recipe? recipe;

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _endMessageController;
  final List<_StepEntry> _steps = [];
  int _nextKey = 0;
  late RecipeIllustration _illustration;

  /// Nouvelle recette : l'illustration suit le nom tant qu'on n'en choisit pas.
  late bool _illustrationAuto;

  late final String _initialSnapshot;
  String? _nameError;
  bool _saving = false;

  bool get _isNew => widget.recipe == null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _endMessageController =
        TextEditingController(text: recipe?.endMessage ?? '');
    _illustration = recipe?.illustration ?? RecipeIllustration.casserole;
    _illustrationAuto = recipe == null;
    for (final step in recipe?.steps ?? const <RecipeStep>[]) {
      _steps.add(_StepEntry(_nextKey++, step));
    }
    _initialSnapshot = _snapshot();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _endMessageController.dispose();
    super.dispose();
  }

  /// Photographie du contenu, pour savoir s'il y a des modifications.
  String _snapshot() => jsonEncode({
        'name': _nameController.text,
        'illustration': _illustration.key,
        'endMessage': _endMessageController.text,
        'steps': _steps.map((e) => e.step.toJson()).toList(),
      });

  bool get _hasChanges => _snapshot() != _initialSnapshot;

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  // ---------- Nom et illustration ----------

  void _onNameChanged(String value) {
    setState(() {
      _nameError = null;
      if (_illustrationAuto) {
        _illustration = RecipeIllustration.guessFromName(value);
      }
    });
  }

  void _chooseIllustration(RecipeIllustration value) {
    setState(() {
      _illustration = value;
      _illustrationAuto = false;
    });
  }

  // ---------- Étapes ----------

  Future<void> _addStep() async {
    final result = await showStepEditor(
      context,
      step: const RecipeStep(durationSeconds: 5 * 60),
      stepNumber: _steps.length + 1,
      isLast: true,
      isNew: true,
    );
    if (result == null || !mounted) return;
    setState(() => _steps.add(_StepEntry(_nextKey++, result)));
  }

  Future<void> _editStep(int index) async {
    final entry = _steps[index];
    final result = await showStepEditor(
      context,
      step: entry.step,
      stepNumber: index + 1,
      isLast: index == _steps.length - 1,
    );
    if (result == null || !mounted) return;
    setState(() => entry.step = result);
  }

  void _removeStep(int index) {
    final s = S.of(context);
    final removed = _steps[index];
    setState(() => _steps.removeAt(index));
    _showMessage(
      s.stepDeleted,
      action: SnackBarAction(
        label: s.undo,
        onPressed: () {
          if (!mounted) return;
          final insertAt = index > _steps.length ? _steps.length : index;
          setState(() => _steps.insert(insertAt, removed));
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
  }

  // ---------- Enregistrement et sortie ----------

  Future<void> _save() async {
    final s = S.of(context);
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = s.nameRequired);
      return;
    }
    if (_steps.isEmpty) {
      _showMessage(s.stepsRequired);
      return;
    }

    final steps = <RecipeStep>[];
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i].step;
      final isLast = i == _steps.length - 1;
      steps.add(step.copyWith(
        name: step.name.trim(),
        temperature: step.temperature.trim(),
        // Pas de rappel après la dernière étape : c'est le message de fin.
        reminder: isLast ? '' : step.reminder.trim(),
      ));
    }

    final recipe = Recipe(
      id: widget.recipe?.id ?? generateId(),
      name: name,
      illustration: _illustration,
      steps: steps,
      endMessage: _endMessageController.text.trim(),
      lastUsedAt: DateTime.now(),
    );

    setState(() => _saving = true);
    await widget.repository.saveRecipe(recipe);
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  Future<bool> _confirmDiscard() {
    final s = S.of(context);
    return showConfirmDialog(
      context,
      title: s.discardTitle,
      message: s.discardBody,
      confirmLabel: s.discard,
      cancelLabel: s.keepEditing,
      destructive: true,
    );
  }

  // ---------- Affichage ----------

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasChanges || await _confirmDiscard()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? s.newRecipe : s.editRecipe),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(s.save),
              ),
            ),
          ],
        ),
        body: ReorderableListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          buildDefaultDragHandles: false,
          onReorder: _onReorder,
          header: _buildHeader(s),
          footer: _buildFooter(s),
          children: [
            for (var i = 0; i < _steps.length; i++) _buildStepItem(s, i),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(S s) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: _isNew,
            textCapitalization: TextCapitalization.sentences,
            style: theme.textTheme.titleLarge,
            decoration: InputDecoration(
              labelText: s.recipeName,
              hintText: s.recipeNameHint,
              errorText: _nameError,
            ),
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 24),
          Text(s.illustration, style: theme.textTheme.titleLarge),
          if (_illustrationAuto) ...[
            const SizedBox(height: 4),
            Text(
              s.suggestedIllustration,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: palette.mutedText),
            ),
          ],
          const SizedBox(height: 12),
          IllustrationPicker(
            selected: _illustration,
            onSelected: _chooseIllustration,
          ),
          const SizedBox(height: 28),
          Text(s.cookingScore, style: theme.textTheme.titleLarge),
          if (_steps.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              s.reorderHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: palette.mutedText),
            ),
          ],
          if (_steps.isEmpty) ...[
            const SizedBox(height: 8),
            Text(s.noStepsYet),
          ],
        ],
      ),
    );
  }

  /// Une étape (et son rappel éventuel) : un seul bloc déplaçable.
  Widget _buildStepItem(S s, int index) {
    final entry = _steps[index];
    final step = entry.step;
    final isLast = index == _steps.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => _removeStep(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreRow(
            isFirst: index == 0,
            isLast: false,
            node: ScoreStepNode(number: index + 1),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _editStep(index),
                    child: ScoreStepCard(step: step),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: SizedBox(
                    width: 44,
                    height: 56,
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: palette.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            ScoreRow(
              isFirst: false,
              isLast: false,
              node: step.reminder.isEmpty
                  ? const _AddReminderNode()
                  : const ScoreReminderNode(),
              child: step.reminder.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _editStep(index),
                        icon: const Icon(Icons.add_alert_outlined),
                        label: Text(s.addReminder),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 44),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _editStep(index),
                        child: ScoreReminderCard(text: step.reminder),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  /// Bas de la partition : « Ajouter une étape » puis le message de fin.
  Widget _buildFooter(S s) {
    final lineColor = context.palette.divider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreRow(
          isFirst: _steps.isEmpty,
          isLast: false,
          node: const _AddStepNode(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.addStep),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              height: 42,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    height: 21,
                    child: Container(width: 3, color: lineColor),
                  ),
                  const ScoreEndNode(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _endMessageController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: s.endMessage,
                  hintText: s.endMessageHint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pastille « + » devant le bouton « Ajouter une étape ».
class _AddStepNode extends StatelessWidget {
  const _AddStepNode();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.primary, width: 2),
      ),
      child: Icon(Icons.add_rounded, color: scheme.primary),
    );
  }
}

/// Petite pastille vide devant « Ajouter un rappel ».
class _AddReminderNode extends StatelessWidget {
  const _AddReminderNode();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: palette.divider, width: 2),
        ),
        child: Icon(Icons.add_rounded, size: 16, color: palette.mutedText),
      ),
    );
  }
}