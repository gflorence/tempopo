/// Catalogues prédéfinis de Tempopo : illustrations, types d'étapes, motifs.
/// Les clés (« key ») sont enregistrées dans recettes.json : ne jamais les
/// renommer. Les fichiers SVG portent le même nom que la clé.
library;

/// Illustrations disponibles pour les recettes (aucune photo, jamais).
enum RecipeIllustration {
  casserole('casserole'), // illustration générique par défaut
  oeuf('oeuf'),
  poulet('poulet'),
  riz('riz'),
  ramen('ramen'),
  cocotte('cocotte'),
  poisson('poisson'),
  legumes('legumes'),
  ustensiles('ustensiles'),
  minuteur('minuteur');

  const RecipeIllustration(this.key);

  final String key;

  String get assetPath => 'assets/illustrations/$key.svg';

  static RecipeIllustration fromKey(String? key) => values.firstWhere(
        (value) => value.key == key,
        orElse: () => RecipeIllustration.casserole,
      );

  /// Propose une illustration d'après le nom de la recette.
  static RecipeIllustration guessFromName(String name) {
    final text = name.toLowerCase();
    bool has(List<String> words) => words.any((w) => text.contains(w));

    if (has(['œuf', 'oeuf', 'egg'])) return RecipeIllustration.oeuf;
    if (has(['poulet', 'chicken', 'volaille', 'poultry', 'dinde', 'turkey'])) {
      return RecipeIllustration.poulet;
    }
    if (has(['riz', 'rice', 'risotto'])) return RecipeIllustration.riz;
    if (has(['ramen', 'nouille', 'noodle', 'udon', 'soba', 'pho'])) {
      return RecipeIllustration.ramen;
    }
    if (has(['poisson', 'fish', 'saumon', 'salmon', 'cabillaud', 'cod', 'thon', 'tuna'])) {
      return RecipeIllustration.poisson;
    }
    if (has(['cocotte', 'ragoût', 'ragout', 'stew', 'bœuf', 'boeuf', 'beef', 'pot-au-feu', 'mijoté'])) {
      return RecipeIllustration.cocotte;
    }
    if (has(['légume', 'legume', 'vegetable', 'carotte', 'carrot', 'oignon', 'onion', 'champignon', 'mushroom'])) {
      return RecipeIllustration.legumes;
    }
    return RecipeIllustration.casserole;
  }
}

/// Type d'une étape : détermine son icône dans la partition de cuisson.
enum StepKind {
  oven('four'),
  fire('feu'),
  water('eau'),
  rest('repos'),
  other('autre');

  const StepKind(this.key);

  final String key;

  String get assetPath => 'assets/step_icons/$key.svg';

  static StepKind fromKey(String? key) => values.firstWhere(
        (value) => value.key == key,
        orElse: () => StepKind.other,
      );

  /// Propose un type d'après le nom et la température de l'étape.
  static StepKind guess({String name = '', String temperature = ''}) {
    final text = '$name $temperature'.toLowerCase();
    bool has(List<String> words) => words.any((w) => text.contains(w));

    if (has(['repos', 'reposer', 'rest'])) return StepKind.rest;
    if (has(['°', 'four', 'oven', 'thermostat', 'th.', 'grill', 'rôti', 'roast', 'bake'])) {
      return StepKind.oven;
    }
    if (has(['bouill', 'boil', 'eau', 'water', 'vapeur', 'steam', 'poch', 'poach'])) {
      return StepKind.water;
    }
    if (has(['feu', 'heat', 'flamme', 'flame', 'poêle', 'plaque', 'mijot', 'simmer', 'saisi', 'sear', 'fry', 'frire'])) {
      return StepKind.fire;
    }
    return StepKind.other;
  }
}

/// Motifs décoratifs (utilisés avec parcimonie, en arrière-plan).
enum TempopoMotif {
  steam('vapeur'),
  waves('vagues'),
  flowers('fleurs');

  const TempopoMotif(this.key);

  final String key;

  String get assetPath => 'assets/patterns/$key.svg';
}