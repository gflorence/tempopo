import 'dart:math';

import 'catalog.dart';

export 'catalog.dart';

/// Une étape de recette : une durée, un type (icône), un nom et une
/// température facultatifs, et le rappel affiché à la fin de l'étape
/// (ignoré pour la dernière étape).
class RecipeStep {
  const RecipeStep({
    required this.durationSeconds,
    this.kind = StepKind.other,
    this.name = '',
    this.temperature = '',
    this.reminder = '',
  });

  final int durationSeconds;
  final StepKind kind;
  final String name;
  final String temperature;
  final String reminder;

  RecipeStep copyWith({
    int? durationSeconds,
    StepKind? kind,
    String? name,
    String? temperature,
    String? reminder,
  }) {
    return RecipeStep(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      temperature: temperature ?? this.temperature,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toJson() => {
        'durationSeconds': durationSeconds,
        'kind': kind.key,
        'name': name,
        'temperature': temperature,
        'reminder': reminder,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final temperature = json['temperature'] as String? ?? '';
    final rawKind = json['kind'] as String?;
    return RecipeStep(
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      // Anciennes données (format v1) : type proposé automatiquement.
      kind: rawKind != null
          ? StepKind.fromKey(rawKind)
          : StepKind.guess(name: name, temperature: temperature),
      name: name,
      temperature: temperature,
      reminder: json['reminder'] as String? ?? '',
    );
  }
}

/// Une recette : un nom, une illustration, des étapes et un message de fin.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    this.illustration = RecipeIllustration.casserole,
    required this.steps,
    this.endMessage = '',
    required this.lastUsedAt,
  });

  final String id;
  final String name;
  final RecipeIllustration illustration;
  final List<RecipeStep> steps;
  final String endMessage;

  /// Date de dernière utilisation (création, modification, lancement).
  final DateTime lastUsedAt;

  int get totalSeconds =>
      steps.fold<int>(0, (sum, step) => sum + step.durationSeconds);

  Recipe copyWith({
    String? id,
    String? name,
    RecipeIllustration? illustration,
    List<RecipeStep>? steps,
    String? endMessage,
    DateTime? lastUsedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      illustration: illustration ?? this.illustration,
      steps: steps ?? this.steps,
      endMessage: endMessage ?? this.endMessage,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'illustration': illustration.key,
        'steps': steps.map((step) => step.toJson()).toList(),
        'endMessage': endMessage,
        'lastUsedAt': lastUsedAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final rawSteps = json['steps'] as List<dynamic>? ?? const [];
    final rawIllustration = json['illustration'] as String?;
    return Recipe(
      id: json['id'] as String? ?? generateId(),
      name: name,
      // Anciennes données (format v1) : illustration proposée d'après le nom.
      illustration: rawIllustration != null
          ? RecipeIllustration.fromKey(rawIllustration)
          : RecipeIllustration.guessFromName(name),
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