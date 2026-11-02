import 'package:flutter/material.dart';

import '../data/recipe_repository.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import 'recipe_editor_screen.dart';

enum _RecipeAction { edit, duplicate, delete }

/// Écran d'accueil : la liste des recettes.
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key, required this.repository});

  final RecipeRepository repository;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditor(BuildContext context, Recipe? recipe) async {
    final s = S.of(context);
    final savedName = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            RecipeEditorScreen(repository: repository, recipe: recipe),
      ),
    );
    if (savedName == null || !context.mounted) return;
    _showMessage(context, s.recipeSaved(savedName));
  }

  Future<void> _duplicate(BuildContext context, Recipe recipe) async {
    final s = S.of(context);
    final copy = await repository.duplicate(recipe, copySuffix: s.copySuffix);
    if (!context.mounted) return;
    _showMessage(context, s.recipeDuplicated(copy.name));
  }

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteRecipeTitle(recipe.name)),
        content: Text(s.deleteRecipeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.deleteRecipe(recipe.id);
    if (!context.mounted) return;
    _showMessage(context, s.recipeDeleted(recipe.name));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        icon: const Icon(Icons.add),
        label: Text(s.newRecipe),
      ),
      body: ListenableBuilder(
        listenable: repository,
        builder: (builderContext, _) {
          final recipes = repository.recipes;

          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(s.noRecipes, textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: recipes.length,
            itemBuilder: (itemContext, index) {
              final recipe = recipes[index];
              return Card(
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${s.stepCount(recipe.steps.length)} · '
                    '${s.duration(recipe.totalSeconds)}',
                  ),
                  onTap: () => _openEditor(context, recipe),
                  trailing: PopupMenuButton<_RecipeAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _RecipeAction.edit:
                          _openEditor(context, recipe);
                        case _RecipeAction.duplicate:
                          _duplicate(context, recipe);
                        case _RecipeAction.delete:
                          _confirmDelete(context, recipe);
                      }
                    },
                    itemBuilder: (menuContext) => [
                      PopupMenuItem(
                        value: _RecipeAction.edit,
                        child: Text(s.edit),
                      ),
                      PopupMenuItem(
                        value: _RecipeAction.duplicate,
                        child: Text(s.duplicate),
                      ),
                      PopupMenuItem(
                        value: _RecipeAction.delete,
                        child: Text(s.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}