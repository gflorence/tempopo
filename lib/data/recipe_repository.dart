import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/recipe.dart';
import 'sample_recipes.dart';

/// Gère la liste des recettes et leur enregistrement dans un fichier JSON.
class RecipeRepository extends ChangeNotifier {
  static const String _fileName = 'recettes.json';

  /// v1 : phase 1. v2 : ajout de l'illustration et du type d'étape.
  static const int _formatVersion = 2;

  final List<Recipe> _recipes = [];

  /// Recettes triées : la plus récemment utilisée en premier.
  List<Recipe> get recipes {
    final sorted = List<Recipe>.of(_recipes)
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return List.unmodifiable(sorted);
  }

  Recipe? findById(String id) {
    for (final recipe in _recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Charge les recettes. Au tout premier lancement, crée les exemples.
  Future<void> load({required String languageCode}) async {
    final file = await _file();

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final version = (data['version'] as num?)?.toInt() ?? 1;
        final list = data['recipes'] as List<dynamic>? ?? const [];
        _recipes
          ..clear()
          ..addAll(list.map(
              (e) => Recipe.fromJson(Map<String, dynamic>.from(e as Map))));

        if (version < _formatVersion) {
          _upgradeSampleRecipes();
          await _writeToDisk();
        }
        notifyListeners();
        return;
      } catch (error) {
        // Fichier abîmé : on le met de côté au lieu de l'écraser.
        debugPrint('Fichier de recettes illisible : $error');
        final stamp = DateTime.now().millisecondsSinceEpoch;
        await file.copy('${file.path}.illisible-$stamp');
      }
    }

    _recipes
      ..clear()
      ..addAll(buildSampleRecipes(languageCode));
    await _writeToDisk();
    notifyListeners();
  }

  /// Migration v1 → v2 : les recettes d'exemple (reconnues à leur nom exact)
  /// retrouvent leur illustration et les types d'étapes d'origine.
  /// Les autres recettes gardent les valeurs proposées automatiquement.
  void _upgradeSampleRecipes() {
    final samples = [
      ...buildSampleRecipes('fr'),
      ...buildSampleRecipes('en'),
    ];
    for (var i = 0; i < _recipes.length; i++) {
      final recipe = _recipes[i];
      Recipe? sample;
      for (final candidate in samples) {
        if (candidate.name == recipe.name) {
          sample = candidate;
          break;
        }
      }
      if (sample == null) continue;

      final steps = <RecipeStep>[];
      for (var j = 0; j < recipe.steps.length; j++) {
        final kind = j < sample.steps.length
            ? sample.steps[j].kind
            : recipe.steps[j].kind;
        steps.add(recipe.steps[j].copyWith(kind: kind));
      }
      _recipes[i] =
          recipe.copyWith(illustration: sample.illustration, steps: steps);
    }
  }

  /// Ajoute une nouvelle recette ou remplace une recette existante.
  Future<void> saveRecipe(Recipe recipe) async {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index >= 0) {
      _recipes[index] = recipe;
    } else {
      _recipes.add(recipe);
    }
    notifyListeners();
    await _writeToDisk();
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    await _writeToDisk();
  }

  Future<Recipe> duplicate(Recipe recipe, {required String copySuffix}) async {
    final copy = recipe.copyWith(
      id: generateId(),
      name: '${recipe.name} $copySuffix',
      lastUsedAt: DateTime.now(),
    );
    await saveRecipe(copy);
    return copy;
  }

  /// Fait remonter une recette en haut de la liste (utilisé en phase 2).
  Future<void> markUsed(String id) async {
    final recipe = findById(id);
    if (recipe == null) return;
    await saveRecipe(recipe.copyWith(lastUsedAt: DateTime.now()));
  }

  /// Écriture sûre : on écrit dans un fichier temporaire, puis on le renomme.
  Future<void> _writeToDisk() async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    final data = {
      'version': _formatVersion,
      'recipes': _recipes.map((r) => r.toJson()).toList(),
    };
    await temp.writeAsString(jsonEncode(data), flush: true);
    await temp.rename(file.path);
  }
}