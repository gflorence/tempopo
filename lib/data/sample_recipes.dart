import '../models/recipe.dart';

/// Les 3 recettes d'exemple créées au tout premier lancement.
List<Recipe> buildSampleRecipes(String languageCode) {
  final fr = languageCode == 'fr';
  final now = DateTime.now();

  return [
    Recipe(
      id: generateId(),
      name: fr ? 'Œufs mollets' : 'Soft-boiled eggs',
      steps: [
        RecipeStep(
          durationSeconds: 6 * 60,
          name: fr ? 'Cuisson' : 'Cooking',
        ),
      ],
      lastUsedAt: now,
    ),
    Recipe(
      id: generateId(),
      name: fr ? 'Poulet rôti' : 'Roast chicken',
      steps: [
        RecipeStep(
          durationSeconds: 15 * 60,
          name: fr ? 'Saisie' : 'Searing',
          temperature: '210 °C',
          reminder: fr ? 'Baisser le four à 190 °C' : 'Lower the oven to 190 °C',
        ),
        RecipeStep(
          durationSeconds: 25 * 60,
          name: fr ? 'Rôtissage' : 'Roasting',
          temperature: '190 °C',
          reminder:
              fr ? 'Arroser et retourner le poulet' : 'Baste and turn the chicken',
        ),
        RecipeStep(
          durationSeconds: 25 * 60,
          name: fr ? 'Fin de cuisson' : 'Final roasting',
          temperature: '190 °C',
        ),
      ],
      endMessage: fr ? 'Laisser reposer 10 min' : 'Let rest for 10 min',
      lastUsedAt: now.subtract(const Duration(seconds: 1)),
    ),
    Recipe(
      id: generateId(),
      name: fr ? 'Riz basmati' : 'Basmati rice',
      steps: [
        RecipeStep(
          durationSeconds: 10 * 60,
          name: fr ? 'Cuisson' : 'Cooking',
          temperature: fr ? 'feu doux' : 'low heat',
          reminder: fr
              ? 'Couper le feu, laisser couvert'
              : 'Turn off the heat, keep covered',
        ),
        RecipeStep(
          durationSeconds: 5 * 60,
          name: fr ? 'Repos' : 'Resting',
        ),
      ],
      endMessage: fr ? 'Égrener à la fourchette' : 'Fluff with a fork',
      lastUsedAt: now.subtract(const Duration(seconds: 2)),
    ),
  ];
}