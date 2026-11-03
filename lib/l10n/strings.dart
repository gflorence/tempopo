import 'package:flutter/widgets.dart';

/// Tous les textes de l'application, en français et en anglais.
class S {
  const S._(this._fr);

  final bool _fr;

  static S of(BuildContext context) =>
      S._(Localizations.localeOf(context).languageCode == 'fr');

  String _t(String fr, String en) => _fr ? fr : en;

  // Général
  String get appTitle => 'Tempopo';
  String get tagline => _t('La cuisine a son rythme.', 'Cooking has a rhythm.');
  String get cancel => _t('Annuler', 'Cancel');
  String get save => _t('Enregistrer', 'Save');
  String get validate => _t('Valider', 'OK');
  String get undo => _t('Annuler', 'Undo');
  String get moreOptions => _t('Plus d’options', 'More options');

  // Bibliothèque de recettes
  String get myRecipes => _t('Mes recettes', 'My recipes');
  String recipeCount(int n) => _fr
      ? (n <= 1 ? '$n recette' : '$n recettes')
      : (n == 1 ? '1 recipe' : '$n recipes');
  String get newRecipe => _t('Nouvelle recette', 'New recipe');
  String get noRecipes => _t(
        'Aucune recette pour l’instant.\nTouchez « Nouvelle recette » pour commencer.',
        'No recipes yet.\nTap “New recipe” to get started.',
      );
  String get edit => _t('Modifier', 'Edit');
  String get duplicate => _t('Dupliquer', 'Duplicate');
  String get delete => _t('Supprimer', 'Delete');
  String get copySuffix => _t('(copie)', '(copy)');
  String deleteRecipeTitle(String name) =>
      _t('Supprimer « $name » ?', 'Delete “$name”?');
  String get deleteRecipeBody =>
      _t('Cette action est définitive.', 'This cannot be undone.');
  String recipeDeleted(String name) =>
      _t('« $name » supprimée', '“$name” deleted');
  String recipeDuplicated(String name) =>
      _t('« $name » créée', '“$name” created');
  String recipeSaved(String name) =>
      _t('« $name » enregistrée', '“$name” saved');

  // Lancement (phase 2)
  String get startCooking => _t('Lancer la cuisson', 'Start cooking');
  String launchRecipe(String name) =>
      _t('Lancer « $name »', 'Start “$name”');
  String get launchComingSoon => _t(
        'Le lancement des minuteurs arrive à la phase 2 🙂',
        'Timers are coming in phase 2 🙂',
      );

  // Détail d'une recette
  String get cookingScore => _t('Partition de cuisson', 'Cooking score');
  String get reminder => _t('Rappel', 'Reminder');
  String get toFinish => _t('Pour finir', 'To finish');
  String get readyDefault => _t('C’est prêt !', 'Ready!');

  // Éditeur de recette
  String get editRecipe => _t('Modifier la recette', 'Edit recipe');
  String get recipeName => _t('Nom de la recette', 'Recipe name');
  String get recipeNameHint => _t('ex. Poulet rôti', 'e.g. Roast chicken');
  String get nameRequired =>
      _t('Donnez un nom à la recette', 'Please name the recipe');
  String get steps => _t('Étapes', 'Steps');
  String get noStepsYet => _t(
        'Aucune étape pour l’instant. Ajoutez-en une ci-dessous.',
        'No steps yet. Add one below.',
      );
  String get stepsRequired =>
      _t('Ajoutez au moins une étape', 'Add at least one step');
  String get reorderHint => _t(
        'Maintenez ≡ pour déplacer une étape. Glissez-la vers la gauche pour la supprimer.',
        'Hold ≡ to move a step. Swipe it left to delete it.',
      );
  String get addStep => _t('Ajouter une étape', 'Add a step');
  String get addReminder => _t('Ajouter un rappel', 'Add a reminder');
  String get stepDeleted => _t('Étape supprimée', 'Step deleted');
  String get endMessage =>
      _t('Message de fin (facultatif)', 'End message (optional)');
  String get endMessageHint =>
      _t('ex. Laisser reposer 10 min', 'e.g. Let rest for 10 min');
  String get discardTitle =>
      _t('Abandonner les modifications ?', 'Discard changes?');
  String get discardBody => _t(
        'Les modifications non enregistrées seront perdues.',
        'Unsaved changes will be lost.',
      );
  String get discard => _t('Abandonner', 'Discard');
  String get keepEditing => _t('Continuer', 'Keep editing');

  // Fenêtre d'édition d'une étape
  String stepNumber(int n) => _t('Étape $n', 'Step $n');
  String get stepName => _t('Nom de l’étape (facultatif)', 'Step name (optional)');
  String get stepNameHint => _t('ex. Saisie', 'e.g. Searing');
  String get temperature => _t('Température (facultatif)', 'Temperature (optional)');
  String get temperatureHint =>
      _t('ex. 210 °C, feu doux', 'e.g. 210 °C, low heat');
  String get reminderAfterStep => _t(
        'Rappel à la fin de l’étape (facultatif)',
        'Reminder at the end of the step (optional)',
      );
  String get reminderHint =>
      _t('ex. Baisser le four à 190 °C', 'e.g. Lower the oven to 190 °C');
  String get durationRequired => _t(
        'La durée doit être supérieure à 0',
        'Duration must be greater than 0',
      );

  // Nombres et durées
  String stepCount(int n) => _fr
      ? (n <= 1 ? '$n étape' : '$n étapes')
      : (n == 1 ? '1 step' : '$n steps');

  /// Exemples : « 6 min », « 6 min 30 s », « 1 h 05 », « 45 s ».
  String duration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final sec = totalSeconds % 60;
    if (h > 0) {
      if (m == 0 && sec == 0) return '$h h';
      final mm = m.toString().padLeft(2, '0');
      return sec == 0 ? '$h h $mm' : '$h h $mm min $sec s';
    }
    if (m > 0) return sec == 0 ? '$m min' : '$m min $sec s';
    return '$sec s';
  }
}