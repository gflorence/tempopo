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
  String get cancel => _t('Annuler', 'Cancel');

  // Liste des recettes
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
  String get editorComingSoon => _t(
        'L’éditeur arrive à l’étape 1b 🙂',
        'The editor is coming in step 1b 🙂',
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