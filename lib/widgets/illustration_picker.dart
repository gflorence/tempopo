import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/catalog.dart';
import 'illustration.dart';

/// Grille de choix de l'illustration d'une recette.
class IllustrationPicker extends StatelessWidget {
  const IllustrationPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RecipeIllustration selected;
  final ValueChanged<RecipeIllustration> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in RecipeIllustration.values)
          Semantics(
            button: true,
            selected: item == selected,
            label: s.illustrationName(item),
            child: Tooltip(
              message: s.illustrationName(item),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelected(item),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item == selected
                          ? scheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      RecipeIllustrationView(illustration: item, size: 60),
                      if (item == selected)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}