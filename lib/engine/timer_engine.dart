import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/active_timer_store.dart';
import '../models/active_timer.dart';
import '../models/recipe.dart';
import '../services/alarm_scheduler.dart';

/// Source de l'heure (remplaçable dans les tests).
typedef Clock = DateTime Function();

/// Type d'événement émis quand une étape se termine.
enum TimerEventType { stepEnded, awaitingConfirmation, finished }

/// Événement émis par le moteur (pour vibrer, afficher une alerte…).
class TimerEvent {
  const TimerEvent({
    required this.timerId,
    required this.type,
    required this.stepIndex,
  });

  final String timerId;
  final TimerEventType type;

  /// Index de l'étape qui vient de se terminer.
  final int stepIndex;
}

/// Moteur des minuteurs : lance, enchaîne, met en pause, ajuste, valide.
class TimerEngine extends ChangeNotifier {
  TimerEngine({
    required ActiveTimerStore store,
    required AlarmScheduler scheduler,
    Clock? clock,
  })  : _store = store,
        _scheduler = scheduler,
        _clock = clock ?? DateTime.now;

  final ActiveTimerStore _store;
  final AlarmScheduler _scheduler;
  final Clock _clock;

  final List<ActiveTimer> _timers = [];
  final StreamController<TimerEvent> _events =
      StreamController<TimerEvent>.broadcast(sync: true);
  Timer? _ticker;
  Future<void> _saveChain = Future<void>.value();

  /// Événements de fin d'étape (uniquement ceux vécus en direct).
  Stream<TimerEvent> get events => _events.stream;

  DateTime get now => _clock();

  /// Minuteurs triés : à confirmer, terminés, en cours (par échéance), en pause.
  List<ActiveTimer> get timers {
    final sorted = List<ActiveTimer>.of(_timers)..sort(_compare);
    return List.unmodifiable(sorted);
  }

  int get count => _timers.length;

  ActiveTimer? findById(String id) {
    for (final timer in _timers) {
      if (timer.id == id) return timer;
    }
    return null;
  }

  // ---------- Cycle de vie ----------

  /// Charge les minuteurs enregistrés et rattrape le temps écoulé
  /// pendant que l'application était fermée (sans émettre d'événements).
  Future<void> load() async {
    final loaded = await _store.load();
    _timers
      ..clear()
      ..addAll(loaded);
    _advanceAll(emit: false);
    notifyListeners();
    await _persist();
  }

  /// Rafraîchit l'affichage chaque seconde.
  void startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  void stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Recalcule l'état de tous les minuteurs (fins d'étape, enchaînements).
  Future<void> update() async {
    final changed = _advanceAll(emit: true);
    if (changed || _timers.any((t) => t.status == TimerStatus.running)) {
      notifyListeners();
    }
    if (changed) await _persist();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _events.close();
    super.dispose();
  }

  // ---------- Actions ----------

  /// Lance une recette. Une recette d'une seule étape est toujours
  /// en mode automatique.
  Future<ActiveTimer> launch(
    Recipe recipe, {
    LaunchMode mode = LaunchMode.automatic,
    bool quick = false,
  }) async {
    if (recipe.steps.isEmpty) {
      throw ArgumentError('Une recette sans étape ne peut pas être lancée.');
    }
    final start = _clock();
    final firstMs = recipe.steps.first.durationSeconds * 1000;
    final timer = ActiveTimer(
      id: generateId(),
      recipeId: quick ? null : recipe.id,
      recipe: recipe,
      displayName: _uniqueName(recipe.name),
      mode: recipe.steps.length > 1 ? mode : LaunchMode.automatic,
      stepIndex: 0,
      status: TimerStatus.running,
      stepEndsAt: start.add(Duration(milliseconds: firstMs)),
      stepTotalMs: firstMs,
      statusChangedAt: start,
      launchedAt: start,
    );
    _timers.add(timer);
    notifyListeners();
    await _persist();
    return timer;
  }

  Future<bool> pause(String id) => _modify(id, (t, now) {
        if (t.status != TimerStatus.running) return null;
        return t.copyWith(
          status: TimerStatus.paused,
          pausedRemainingMs: t.remainingAt(now).inMilliseconds,
          clearStepEndsAt: true,
          statusChangedAt: now,
        );
      });

  Future<bool> resume(String id) => _modify(id, (t, now) {
        if (t.status != TimerStatus.paused) return null;
        return t.copyWith(
          status: TimerStatus.running,
          stepEndsAt: now.add(Duration(milliseconds: t.pausedRemainingMs ?? 0)),
          clearPausedRemaining: true,
          statusChangedAt: now,
        );
      });

  /// L'ajustement est-il possible ? (−1 min interdit s'il reste moins d'1 min ;
  /// sur une recette à confirmer ou terminée, seul l'ajout est possible.)
  bool canAdjust(ActiveTimer timer, Duration delta) =>
      _canAdjustAt(timer, delta, _clock());

  /// +1 min / −1 min. Sur une recette à confirmer ou terminée, +1 min
  /// prolonge l'étape à partir de maintenant.
  Future<bool> addTime(String id, Duration delta) => _modify(id, (t, now) {
        if (!_canAdjustAt(t, delta, now)) return null;
        switch (t.status) {
          case TimerStatus.running:
            return t.copyWith(
              stepEndsAt: t.stepEndsAt!.add(delta),
              stepTotalMs: max(1000, t.stepTotalMs + delta.inMilliseconds),
            );
          case TimerStatus.paused:
            return t.copyWith(
              pausedRemainingMs:
                  (t.pausedRemainingMs ?? 0) + delta.inMilliseconds,
              stepTotalMs: max(1000, t.stepTotalMs + delta.inMilliseconds),
            );
          case TimerStatus.awaitingConfirmation:
          case TimerStatus.finished:
            return t.copyWith(
              status: TimerStatus.running,
              stepEndsAt: now.add(delta),
              stepTotalMs: delta.inMilliseconds,
              statusChangedAt: now,
            );
        }
      });

  /// « C'est fait ! » : démarre l'étape suivante d'une recette à confirmer.
  Future<bool> confirm(String id) => _modify(id, (t, now) {
        if (t.status != TimerStatus.awaitingConfirmation || t.isLastStep) {
          return null;
        }
        return _startStep(t, t.stepIndex + 1, now);
      });

  /// « Étape suivante » : termine l'étape en cours tout de suite.
  Future<bool> skip(String id) => _modify(id, (t, now) {
        if (t.status == TimerStatus.finished) return null;
        if (t.isLastStep) {
          return t.copyWith(
            status: TimerStatus.finished,
            clearStepEndsAt: true,
            clearPausedRemaining: true,
            statusChangedAt: now,
          );
        }
        return _startStep(t, t.stepIndex + 1, now);
      });

  /// Arrête (ou retire une recette terminée).
  Future<void> remove(String id) async {
    _timers.removeWhere((t) => t.id == id);
    notifyListeners();
    await _persist();
  }

  // ---------- Mécanique interne ----------

  bool _canAdjustAt(ActiveTimer t, Duration delta, DateTime now) {
    switch (t.status) {
      case TimerStatus.running:
      case TimerStatus.paused:
        return t.remainingAt(now) + delta >= const Duration(seconds: 1);
      case TimerStatus.awaitingConfirmation:
      case TimerStatus.finished:
        return delta > Duration.zero;
    }
  }

  ActiveTimer _startStep(ActiveTimer t, int index, DateTime start) {
    final ms = t.recipe.steps[index].durationSeconds * 1000;
    return t.copyWith(
      stepIndex: index,
      status: TimerStatus.running,
      stepEndsAt: start.add(Duration(milliseconds: ms)),
      clearPausedRemaining: true,
      stepTotalMs: ms,
      statusChangedAt: start,
    );
  }

  /// Fait avancer un minuteur jusqu'à l'instant [now] : fins d'étape,
  /// enchaînements automatiques exacts, passage en attente ou terminé.
  ActiveTimer _advance(ActiveTimer timer, DateTime now, {required bool emit}) {
    var t = timer;
    while (t.status == TimerStatus.running) {
      final endsAt = t.stepEndsAt;
      if (endsAt == null || now.isBefore(endsAt)) break;
      final endedStep = t.stepIndex;

      if (t.isLastStep) {
        t = t.copyWith(
          status: TimerStatus.finished,
          clearStepEndsAt: true,
          statusChangedAt: endsAt,
        );
        _emit(emit, t, TimerEventType.finished, endedStep);
      } else if (t.mode == LaunchMode.confirmation) {
        t = t.copyWith(
          status: TimerStatus.awaitingConfirmation,
          clearStepEndsAt: true,
          statusChangedAt: endsAt,
        );
        _emit(emit, t, TimerEventType.awaitingConfirmation, endedStep);
      } else {
        // Mode automatique : l'étape suivante démarre à l'heure exacte de fin.
        t = _startStep(t, t.stepIndex + 1, endsAt);
        _emit(emit, t, TimerEventType.stepEnded, endedStep);
      }
    }
    return t;
  }

  bool _advanceAll({required bool emit}) {
    final now = _clock();
    var changed = false;
    for (var i = 0; i < _timers.length; i++) {
      final before = _timers[i];
      final after = _advance(before, now, emit: emit);
      if (!identical(before, after)) {
        _timers[i] = after;
        changed = true;
      }
    }
    return changed;
  }

  /// Applique une modification à un minuteur (après l'avoir mis à jour).
  Future<bool> _modify(
    String id,
    ActiveTimer? Function(ActiveTimer timer, DateTime now) change,
  ) async {
    final index = _timers.indexWhere((t) => t.id == id);
    if (index < 0) return false;
    final now = _clock();
    final current = _advance(_timers[index], now, emit: true);
    final updated = change(current, now);
    if (updated == null) {
      if (!identical(current, _timers[index])) {
        _timers[index] = current;
        notifyListeners();
        await _persist();
      }
      return false;
    }
    _timers[index] = _advance(updated, now, emit: true);
    notifyListeners();
    await _persist();
    return true;
  }

  void _emit(bool emit, ActiveTimer t, TimerEventType type, int stepIndex) {
    if (!emit || _events.isClosed) return;
    _events.add(TimerEvent(timerId: t.id, type: type, stepIndex: stepIndex));
  }

  String _uniqueName(String base) {
    final used = _timers.map((t) => t.displayName).toSet();
    if (!used.contains(base)) return base;
    var n = 2;
    while (used.contains('$base ($n)')) {
      n++;
    }
    return '$base ($n)';
  }

  /// Enregistre et transmet au programmateur d'alarmes, dans l'ordre
  /// (jamais deux écritures en même temps).
  Future<void> _persist() {
    final snapshot = List<ActiveTimer>.unmodifiable(_timers);
    _saveChain = _saveChain.then((_) async {
      try {
        await _store.save(snapshot);
        await _scheduler.sync(snapshot);
      } catch (error) {
        debugPrint('Enregistrement des minuteurs impossible : $error');
      }
    });
    return _saveChain;
  }

  static int _rank(ActiveTimer t) => switch (t.status) {
        TimerStatus.awaitingConfirmation => 0,
        TimerStatus.finished => 1,
        TimerStatus.running => 2,
        TimerStatus.paused => 3,
      };

  static DateTime _sortTime(ActiveTimer t) => switch (t.status) {
        TimerStatus.running => t.stepEndsAt ?? t.statusChangedAt,
        TimerStatus.paused => t.launchedAt,
        _ => t.statusChangedAt,
      };

  static int _compare(ActiveTimer a, ActiveTimer b) {
    final byRank = _rank(a).compareTo(_rank(b));
    if (byRank != 0) return byRank;
    return _sortTime(a).compareTo(_sortTime(b));
  }
}