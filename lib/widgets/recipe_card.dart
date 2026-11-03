import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import 'illustration.dart';

/// Actions du menu ⋮ d'une recette.
enum RecipeMenuAction { edit, duplicate, delete }

/// Carte illustrée d'une recette dans la bibliothèque.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onLaunch,
    required this.onMenuAction,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onLaunch;
  final ValueChanged<RecipeMenuAction> onMenuAction;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              RecipeIllustrationView(
                illustration: recipe.illustration,
                size: 72,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TempopoTypography.fraunces(20)
                          .copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          s.duration(recipe.totalSeconds),
                          style: TempopoTypography.manrope(
                            16,
                            weight: 800,
                            tabular: true,
                          ).copyWith(color: palette.accentText),
                        ),
                        Text('·', style: TextStyle(color: palette.mutedText)),
                        Text(
                          s.stepCount(recipe.steps.length),
                          style: TempopoTypography.manrope(14, weight: 600)
                              .copyWith(color: palette.mutedText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: s.launchRecipe(recipe.name),
                onPressed: onLaunch,
                style: IconButton.styleFrom(
                  minimumSize: const Size(56, 56),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
              ),
              PopupMenuButton<RecipeMenuAction>(
                tooltip: s.moreOptions,
                onSelected: onMenuAction,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: RecipeMenuAction.edit,
                    child: Text(s.edit),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}