import '../models/recipe.dart';

/// Mode d'enchaînement choisi au lancement.
enum LaunchMode {
  automatic('auto'),
  confirmation('confirm');

  const LaunchMode(this.key);

  final String key;

  static LaunchMode fromKey(String? key) => values.firstWhere(
        (value) => value.key == key,
        orElse: () => LaunchMode.automatic,
      );
}

/// État d'un minuteur en cours.
enum TimerStatus {
  running('running'),
  paused('paused'),
  awaitingConfirmation('awaiting'),
  finished('finished');

  const TimerStatus(this.key);

  final String key;

  static TimerStatus fromKey(String? key) => values.firstWhere(
        (value) => value.key == key,
        orElse: () => TimerStatus.finished,
      );
}

/// Une recette en cours de cuisson.
///
/// Principe : on enregistre l'HEURE DE FIN de l'étape en cours, jamais un
/// compte à rebours. Le temps restant est recalculé à chaque instant, ce qui
/// évite toute dérive, même application fermée.
class ActiveTimer {
  const ActiveTimer({
    required this.id,
    required this.recipeId,
    required this.recipe,
    required this.displayName,
    required this.mode,
    required this.stepIndex,
    required this.status,
    this.stepEndsAt,
    this.pausedRemainingMs,
    required this.stepTotalMs,
    required this.statusChangedAt,
    required this.launchedAt,
  });

  final String id;

  /// Recette d'origine (null pour un minuteur rapide).
  final String? recipeId;

  /// Copie de la recette prise au lancement : la modifier ensuite
  /// n'affecte pas la cuisson en cours.
  final Recipe recipe;

  /// Nom affiché, numéroté si la recette est lancée plusieurs fois.
  final String displayName;

  final LaunchMode mode;
  final int stepIndex;
  final TimerStatus status;

  /// Heure de fin de l'étape en cours (si en cours).
  final DateTime? stepEndsAt;

  /// Temps restant figé (si en pause).
  final int? pausedRemainingMs;

  /// Durée totale effective de l'étape en cours (±1 min compris),
  /// pour la barre de progression.
  final int stepTotalMs;

  /// Moment du dernier changement d'état (fin d'étape, pause…).
  final DateTime statusChangedAt;

  final DateTime launchedAt;

  // ---------- Informations calculées ----------

  RecipeStep get currentStep => recipe.steps[stepIndex];

  bool get isLastStep => stepIndex >= recipe.steps.length - 1;

  RecipeStep? get nextStep =>
      isLastStep ? null : recipe.steps[stepIndex + 1];

  /// Durée cumulée des étapes qui suivent l'étape en cours.
  Duration get durationAfterCurrent {
    var seconds = 0;
    for (var i = stepIndex + 1; i < recipe.steps.length; i++) {
      seconds += recipe.steps[i].durationSeconds;
    }
    return Duration(seconds: seconds);
  }

  /// Temps restant sur l'étape en cours.
  Duration remainingAt(DateTime now) => switch (status) {
        TimerStatus.running => _positive(stepEndsAt!.difference(now)),
        TimerStatus.paused => Duration(milliseconds: pausedRemainingMs ?? 0),
        TimerStatus.awaitingConfirmation || TimerStatus.finished =>
          Duration.zero,
      };

  /// Avancement de l'étape en cours, entre 0 et 1.
  double progressAt(DateTime now) {
    if (status == TimerStatus.awaitingConfirmation ||
        status == TimerStatus.finished ||
        stepTotalMs <= 0) {
      return 1;
    }
    final value = 1 - remainingAt(now).inMilliseconds / stepTotalMs;
    return value.clamp(0.0, 1.0).toDouble();
  }

  /// Heure de fin prévue de toute la recette.
  /// En mode confirmation, c'est une estimation (les validations peuvent tarder).
  DateTime estimatedEndAt(DateTime now) => switch (status) {
        TimerStatus.running => stepEndsAt!.add(durationAfterCurrent),
        TimerStatus.paused => now
            .add(Duration(milliseconds: pausedRemainingMs ?? 0))
            .add(durationAfterCurrent),
        TimerStatus.awaitingConfirmation => now.add(durationAfterCurrent),
        TimerStatus.finished => statusChangedAt,
      };

  /// L'heure de fin est-elle une estimation ?
  bool get endIsEstimate =>
      mode == LaunchMode.confirmation &&
      status != TimerStatus.finished &&
      !isLastStep;

  static Duration _positive(Duration d) => d.isNegative ? Duration.zero : d;

  // ---------- Copie et enregistrement ----------

  ActiveTimer copyWith({
    LaunchMode? mode,
    int? stepIndex,
    TimerStatus? status,
    DateTime? stepEndsAt,
    bool clearStepEndsAt = false,
    int? pausedRemainingMs,
    bool clearPausedRemaining = false,
    int? stepTotalMs,
    DateTime? statusChangedAt,
  }) {
    return ActiveTimer(
      id: id,
      recipeId: recipeId,
      recipe: recipe,
      displayName: displayName,
      mode: mode ?? this.mode,
      stepIndex: stepIndex ?? this.stepIndex,
      status: status ?? this.status,
      stepEndsAt: clearStepEndsAt ? null : (stepEndsAt ?? this.stepEndsAt),
      pausedRemainingMs: clearPausedRemaining
          ? null
          : (pausedRemainingMs ?? this.pausedRemainingMs),
      stepTotalMs: stepTotalMs ?? this.stepTotalMs,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      launchedAt: launchedAt,
    );
  }

  /// Les dates sont enregistrées en millisecondes absolues
  /// (insensibles aux changements de fuseau horaire).
  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'recipe': recipe.toJson(),
        'displayName': displayName,
        'mode': mode.key,
        'stepIndex': stepIndex,
        'status': status.key,
        'stepEndsAt': stepEndsAt?.millisecondsSinceEpoch,
        'pausedRemainingMs': pausedRemainingMs,
        'stepTotalMs': stepTotalMs,
        'statusChangedAt': statusChangedAt.millisecondsSinceEpoch,
        'launchedAt': launchedAt.millisecondsSinceEpoch,
      };

  factory ActiveTimer.fromJson(Map<String, dynamic> json) {
    final recipe =
        Recipe.fromJson(Map<String, dynamic>.from(json['recipe'] as Map));
    final lastIndex = recipe.steps.isEmpty ? 0 : recipe.steps.length - 1;
    final rawIndex = (json['stepIndex'] as num?)?.toInt() ?? 0;
    final stepIndex =
        rawIndex < 0 ? 0 : (rawIndex > lastIndex ? lastIndex : rawIndex);

    DateTime? time(String key) {
      final value = json[key];
      return value is num
          ? DateTime.fromMillisecondsSinceEpoch(value.toInt())
          : null;
    }

    final now = DateTime.now();
    return ActiveTimer(
      id: json['id'] as String? ?? generateId(),
      recipeId: json['recipeId'] as String?,
      recipe: recipe,
      displayName: json['displayName'] as String? ?? recipe.name,
      mode: LaunchMode.fromKey(json['mode'] as String?),
      stepIndex: stepIndex,
      status: TimerStatus.fromKey(json['status'] as String?),
      stepEndsAt: time('stepEndsAt'),
      pausedRemainingMs: (json['pausedRemainingMs'] as num?)?.toInt(),
      stepTotalMs: (json['stepTotalMs'] as num?)?.toInt() ?? 0,
      statusChangedAt: time('statusChangedAt') ?? now,
      launchedAt: time('launchedAt') ?? now,
    );
  }
}