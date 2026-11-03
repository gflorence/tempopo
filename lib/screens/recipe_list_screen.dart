import 'package:flutter/material.dart';

import '../data/recipe_repository.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/illustration.dart';
import '../widgets/launch_mode_sheet.dart';
import '../widgets/quick_timer_sheet.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'recipe_editor_screen.dart';

/// Onglet « Recettes » : la bibliothèque.
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key, required this.repository, this.bottomBar});

  final RecipeRepository repository;
  final Widget? bottomBar;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDetail(BuildContext context, Recipe recipe) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            RecipeDetailScreen(repository: repository, recipeId: recipe.id),
      ),
    );
    if (message == null || !context.mounted) return;
    _showMessage(context, message);
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
    final confirmed = await showConfirmDialog(
      context,
      title: s.deleteRecipeTitle(recipe.name),
      message: s.deleteRecipeBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await repository.deleteRecipe(recipe.id);
    if (!context.mounted) return;
    _showMessage(context, s.recipeDeleted(recipe.name));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      bottomNavigationBar: bottomBar,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.newRecipe),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: repository,
          builder: (builderContext, _) {
            final recipes = repository.recipes;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _LibraryHeader(count: recipes.length),
                ),
                if (recipes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyLibrary(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                    sliver: SliverList.builder(
                      itemCount: recipes.length,
                      itemBuilder: (itemContext, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () => _openDetail(context, recipe),
                          onLaunch: () => startRecipe(context, recipe),
                          onMenuAction: (action) {
                            switch (action) {
                              case RecipeMenuAction.edit:
                                _openEditor(context, recipe);
                              case RecipeMenuAction.duplicate:
                                _duplicate(context, recipe);
                              case RecipeMenuAction.delete:
                                _confirmDelete(context, recipe);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// En-tête : logo, signature, minuteur rapide, titre de section.
class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.appTitle,
                      style: TempopoTypography.fraunces(
                        44,
                        weight: 700,
                        wonky: true,
                      ).copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.tagline,
                      style: TempopoTypography.fraunces(17, weight: 400)
                          .copyWith(color: palette.mutedText),
                    ),
                  ],
                ),
              ),
              MotifView(
                motif: TempopoMotif.steam,
                width: 48,
                height: 62,
                color: palette.highlight,
                opacity: 0.9,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => startQuickTimer(context),
            icon: const Icon(Icons.timer_outlined),
            label: Text(s.quickTimer),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(s.myRecipes, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  s.recipeCount(count),
                  style: TempopoTypography.manrope(14, weight: 600)
                      .copyWith(color: palette.mutedText),
                ),
              ),
              const Spacer(),
              const MotifView(motif: TempopoMotif.waves, width: 76, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bibliothèque vide : casserole fumante et invitation à créer.
class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RecipeIllustrationView(
            illustration: RecipeIllustration.casserole,
            size: 140,
          ),
          const SizedBox(height: 20),
          Text(
            s.noRecipes,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}