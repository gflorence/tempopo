import 'dart:math';

/// Une étape de recette : une durée, un nom et une température facultatifs,
/// et le rappel affiché à la fin de l'étape (ignoré pour la dernière étape).
class RecipeStep {
  const RecipeStep({
    required this.durationSeconds,
    this.name = '',
    this.temperature = '',
    this.reminder = '',
  });

  final int durationSeconds;
  final String name;
  final String temperature;
  final String reminder;

  RecipeStep copyWith({
    int? durationSeconds,
    String? name,
    String? temperature,
    String? reminder,
  }) {
    return RecipeStep(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      name: name ?? this.name,
      temperature: temperature ?? this.temperature,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toJson() => {
        'durationSeconds': durationSeconds,
        'name': name,
        'temperature': temperature,
        'reminder': reminder,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      temperature: json['temperature'] as String? ?? '',
      reminder: json['reminder'] as String? ?? '',
    );
  }
}

/// Une recette : un nom, une liste d'étapes et un message de fin facultatif.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.steps,
    this.endMessage = '',
    required this.lastUsedAt,
  });

  final String id;
  final String name;
  final List<RecipeStep> steps;
  final String endMessage;

  /// Date de dernière utilisation (création, modification, lancement).
  final DateTime lastUsedAt;

  int get totalSeconds =>
      steps.fold<int>(0, (sum, step) => sum + step.durationSeconds);

  Recipe copyWith({
    String? id,
    String? name,
    List<RecipeStep>? steps,
    String? endMessage,
    DateTime? lastUsedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      endMessage: endMessage ?? this.endMessage,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'steps': steps.map((step) => step.toJson()).toList(),
        'endMessage': endMessage,
        'lastUsedAt': lastUsedAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? const [];
    return Recipe(
      id: json['id'] as String? ?? generateId(),
      name: json['name'] as String? ?? '',
      steps: rawSteps
          .map((e) => RecipeStep.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      endMessage: json['endMessage'] as String? ?? '',
      lastUsedAt: DateTime.tryParse(json['lastUsedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

final Random _random = Random();

/// Génère un identifiant unique pour une recette.
String generateId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1000000)}';