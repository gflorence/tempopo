import 'package:flutter/material.dart';

import '../data/recipe_repository.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/cooking_score.dart';
import '../widgets/illustration.dart';
import '../widgets/recipe_card.dart';
import 'recipe_editor_screen.dart';

/// Écran Détail d'une recette : illustration, résumé, partition de cuisson.
/// Renvoie un message à afficher dans la liste (ex. après suppression).
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({
    super.key,
    required this.repository,
    required this.recipeId,
  });

  final RecipeRepository repository;
  final String recipeId;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _launch(BuildContext context) {
    // Branché sur le moteur de minuteurs en phase 2.
    _showMessage(context, S.of(context).launchComingSoon);
  }

  Future<void> _edit(BuildContext context, Recipe recipe) async {
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

  Future<void> _delete(BuildContext context, Recipe recipe) async {
    final s = S.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteRecipeTitle(recipe.name),
      message: s.deleteRecipeBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    // On revient d'abord à la liste, puis on supprime.
    Navigator.of(context).pop(s.recipeDeleted(recipe.name));
    await repository.deleteRecipe(recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final recipe = repository.findById(recipeId);
        if (recipe == null) return const Scaffold();
        return _buildScaffold(context, recipe);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Recipe recipe) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: s.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context, recipe),
          ),
          PopupMenuButton<RecipeMenuAction>(
            tooltip: s.moreOptions,
            onSelected: (action) {
              switch (action) {
                case RecipeMenuAction.edit:
                  _edit(context, recipe);
                case RecipeMenuAction.duplicate:
                  _duplicate(context, recipe);
                case RecipeMenuAction.delete:
                  _delete(context, recipe);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: RecipeMenuAction.duplicate,
                child: Text(s.duplicate),
              ),
              PopupMenuItem(
                value: RecipeMenuAction.delete,
                child: Text(s.delete),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _DetailHero(recipe: recipe),
          const SizedBox(height: 16),
          Text(
            recipe.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          _DetailSummary(recipe: recipe),
          const SizedBox(height: 28),
          Row(
            children: [
              Flexible(
                child: Text(s.cookingScore, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(width: 12),
              const MotifView(
                motif: TempopoMotif.waves,
                width: 76,
                height: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CookingScore(recipe: recipe),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: () => _launch(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              textStyle: TempopoTypography.manrope(18, weight: 800),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 30),
            label: Text(s.startCooking),
          ),
        ),
      ),
    );
  }
}

/// Grande illustration entourée de motifs discrets.
class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 8,
            top: 8,
            child: MotifView(
              motif: TempopoMotif.flowers,
              width: 72,
              height: 72,
              opacity: 0.3,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 4,
            child: MotifView(
              motif: TempopoMotif.steam,
              width: 52,
              height: 66,
              color: context.palette.highlight,
              opacity: 0.8,
            ),
          ),
          RecipeIllustrationView(illustration: recipe.illustration, size: 176),
        ],
      ),
    );
  }
}

/// Pastilles « durée totale » et « nombre d'étapes ».
class _DetailSummary extends StatelessWidget {
  const _DetailSummary({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    Widget pill(IconData icon, String text, TextStyle style) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: palette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: palette.accentText),
            const SizedBox(width: 8),
            Text(text, style: style),
          ],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        pill(
          Icons.schedule_rounded,
          s.duration(recipe.totalSeconds),
          TempopoTypography.manrope(18, weight: 800, tabular: true)
              .copyWith(color: scheme.onSurface),
        ),
        pill(
          Icons.format_list_numbered_rounded,
          s.stepCount(recipe.steps.length),
          TempopoTypography.manrope(16, weight: 700)
              .copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}