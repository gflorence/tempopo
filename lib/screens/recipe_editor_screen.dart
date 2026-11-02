import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/recipe_repository.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
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
        'endMessage': _endMessageController.text,
        'steps': _steps.map((e) => e.step.toJson()).toList(),
      });

  bool get _hasChanges => _snapshot() != _initialSnapshot;

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  // ---------- Étapes ----------

  Future<void> _addStep() async {
    final result = await showStepEditor(
      context,
      step: const RecipeStep(durationSeconds: 5 * 60),
      stepNumber: _steps.length + 1,
      isLast: true,
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
      steps: steps,
      endMessage: _endMessageController.text.trim(),
      lastUsedAt: DateTime.now(),
    );

    setState(() => _saving = true);
    await widget.repository.saveRecipe(recipe);
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  Future<bool> _confirmDiscard() async {
    final s = S.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.discardTitle),
        content: Text(s.discardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.discard),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ---------- Affichage ----------

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

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
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(s.save),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ReorderableListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          buildDefaultDragHandles: false,
          onReorder: _onReorder,
          header: _buildHeader(s, theme),
          footer: _buildFooter(s),
          children: [
            for (var i = 0; i < _steps.length; i++)
              _buildStepTile(s, theme, i),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(S s, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: _isNew,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: s.recipeName,
              hintText: s.recipeNameHint,
              errorText: _nameError,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 20),
          Text(s.steps, style: theme.textTheme.titleMedium),
          if (_steps.length > 1) ...[
            const SizedBox(height: 4),
            Text(s.reorderHint, style: theme.textTheme.bodySmall),
          ],
          if (_steps.isEmpty) ...[
            const SizedBox(height: 8),
            Text(s.noStepsYet),
          ],
        ],
      ),
    );
  }

  Widget _buildStepTile(S s, ThemeData theme, int index) {
    final entry = _steps[index];
    final step = entry.step;
    final isLast = index == _steps.length - 1;

    final title = step.name.isEmpty
        ? s.stepNumber(index + 1)
        : '${s.stepNumber(index + 1)} · ${step.name}';
    final details = [
      s.duration(step.durationSeconds),
      if (step.temperature.isNotEmpty) step.temperature,
    ].join(' · ');

    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => _removeStep(index),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
              title: Text(title),
              subtitle: Text(details),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editStep(index),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: step.reminder.isEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _editStep(index),
                          icon: const Icon(Icons.add_alert_outlined),
                          label: Text(s.addReminder),
                        ),
                      )
                    : InkWell(
                        onTap: () => _editStep(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step.reminder,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(S s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: Text(s.addStep),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _endMessageController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            decoration: InputDecoration(
              labelText: s.endMessage,
              hintText: s.endMessageHint,
              prefixIcon: const Icon(Icons.flag_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}