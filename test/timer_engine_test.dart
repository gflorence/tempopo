import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tempopo/data/active_timer_store.dart';
import 'package:tempopo/engine/timer_engine.dart';
import 'package:tempopo/models/active_timer.dart';
import 'package:tempopo/models/recipe.dart';
import 'package:tempopo/services/alarm_scheduler.dart';

/// Enregistrement en mémoire, qui passe quand même par le format JSON.
class MemoryTimerStore implements ActiveTimerStore {
  String? saved;

  @override
  Future<List<ActiveTimer>> load() async {
    final data = saved;
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .map((e) => ActiveTimer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> save(List<ActiveTimer> timers) async {
    saved = jsonEncode(timers.map((t) => t.toJson()).toList());
  }
}

Recipe chicken() => Recipe(
      id: 'poulet',
      name: 'Poulet rôti',
      lastUsedAt: DateTime(2025),
      steps: const [
        RecipeStep(durationSeconds: 15 * 60, reminder: 'Baisser le four'),
        RecipeStep(durationSeconds: 25 * 60, reminder: 'Arroser'),
        RecipeStep(durationSeconds: 25 * 60),
      ],
    );

Recipe eggs() => Recipe(
      id: 'oeufs',
      name: 'Œufs mollets',
      lastUsedAt: DateTime(2025),
      steps: const [RecipeStep(durationSeconds: 6 * 60)],
    );

void main() {
  late DateTime now;
  late MemoryTimerStore store;
  late TimerEngine engine;

  TimerEngine newEngine() => TimerEngine(
        store: store,
        scheduler: const NoopAlarmScheduler(),
        clock: () => now,
      );

  void wait(Duration duration) => now = now.add(duration);

  setUp(() {
    now = DateTime(2025, 1, 1, 12);
    store = MemoryTimerStore();
    engine = newEngine();
  });

  tearDown(() => engine.dispose());

  group('Mode automatique', () {
    test('lancement : étape 1, 15 min restantes, fin prévue à 13 h 05',
        () async {
      final t = await engine.launch(chicken());
      expect(t.status, TimerStatus.running);
      expect(t.stepIndex, 0);
      expect(t.remainingAt(now), const Duration(minutes: 15));
      expect(t.estimatedEndAt(now), DateTime(2025, 1, 1, 13, 5));
    });

    test('enchaînement exact des étapes, puis fin', () async {
      final t = await engine.launch(chicken());
      wait(const Duration(minutes: 15));
      await engine.update();
      var current = engine.findById(t.id)!;
      expect(current.stepIndex, 1);
      expect(current.remainingAt(now), const Duration(minutes: 25));

      wait(const Duration(minutes: 50));
      await engine.update();
      current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.finished);
      expect(current.statusChangedAt, DateTime(2025, 1, 1, 13, 5));
    });

    test('rattrapage après 30 min sans mise à jour', () async {
      final t = await engine.launch(chicken());
      wait(const Duration(minutes: 30));
      await engine.update();
      final current = engine.findById(t.id)!;
      expect(current.stepIndex, 1);
      expect(current.remainingAt(now), const Duration(minutes: 10));
    });

    test('un événement est émis à la fin de l’étape 1', () async {
      final events = <TimerEvent>[];
      engine.events.listen(events.add);
      await engine.launch(chicken());
      wait(const Duration(minutes: 15));
      await engine.update();
      expect(events, hasLength(1));
      expect(events.single.type, TimerEventType.stepEnded);
      expect(events.single.stepIndex, 0);
    });

    test('progression de l’étape', () async {
      final t = await engine.launch(eggs());
      wait(const Duration(minutes: 3));
      expect(engine.findById(t.id)!.progressAt(now), closeTo(0.5, 0.001));
    });
  });

  group('Mode confirmation', () {
    test('attente à la fin de l’étape, puis validation', () async {
      final t = await engine.launch(chicken(), mode: LaunchMode.confirmation);
      wait(const Duration(minutes: 15));
      await engine.update();
      var current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.awaitingConfirmation);
      expect(current.stepIndex, 0);

      // On prend 2 minutes pour baisser le four : la recette attend.
      wait(const Duration(minutes: 2));
      await engine.update();
      expect(engine.findById(t.id)!.status, TimerStatus.awaitingConfirmation);

      await engine.confirm(t.id);
      current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.running);
      expect(current.stepIndex, 1);
      expect(current.remainingAt(now), const Duration(minutes: 25));
    });

    test('+1 min pendant l’attente prolonge l’étape', () async {
      final t = await engine.launch(chicken(), mode: LaunchMode.confirmation);
      wait(const Duration(minutes: 15));
      await engine.update();
      await engine.addTime(t.id, const Duration(minutes: 1));
      var current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.running);
      expect(current.stepIndex, 0);
      expect(current.remainingAt(now), const Duration(minutes: 1));

      wait(const Duration(minutes: 1));
      await engine.update();
      current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.awaitingConfirmation);
    });

    test('une recette d’une seule étape est toujours automatique', () async {
      final t = await engine.launch(eggs(), mode: LaunchMode.confirmation);
      expect(t.mode, LaunchMode.automatic);
      wait(const Duration(minutes: 6));
      await engine.update();
      expect(engine.findById(t.id)!.status, TimerStatus.finished);
    });
  });

  group('Commandes', () {
    test('la pause fige le temps restant', () async {
      final t = await engine.launch(chicken());
      wait(const Duration(minutes: 5));
      await engine.pause(t.id);
      wait(const Duration(minutes: 10));
      await engine.update();
      var current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.paused);
      expect(current.remainingAt(now), const Duration(minutes: 10));

      await engine.resume(t.id);
      wait(const Duration(minutes: 10));
      await engine.update();
      current = engine.findById(t.id)!;
      expect(current.stepIndex, 1);
      expect(current.status, TimerStatus.running);
    });

    test('+1 min, et −1 min refusé s’il reste moins d’une minute', () async {
      final t = await engine.launch(eggs());
      await engine.addTime(t.id, const Duration(minutes: 1));
      expect(
        engine.findById(t.id)!.remainingAt(now),
        const Duration(minutes: 7),
      );

      wait(const Duration(minutes: 6, seconds: 30));
      await engine.update();
      final accepted =
          await engine.addTime(t.id, const Duration(minutes: -1));
      expect(accepted, isFalse);
      expect(
        engine.findById(t.id)!.remainingAt(now),
        const Duration(seconds: 30),
      );
    });

    test('étape suivante, jusqu’à la fin', () async {
      final t = await engine.launch(chicken());
      wait(const Duration(minutes: 3));
      await engine.skip(t.id);
      var current = engine.findById(t.id)!;
      expect(current.stepIndex, 1);
      expect(current.remainingAt(now), const Duration(minutes: 25));

      await engine.skip(t.id);
      await engine.skip(t.id);
      current = engine.findById(t.id)!;
      expect(current.status, TimerStatus.finished);
    });

    test('numérotation des lancements multiples', () async {
      final a = await engine.launch(chicken());
      final b = await engine.launch(chicken());
      expect(a.displayName, 'Poulet rôti');
      expect(b.displayName, 'Poulet rôti (2)');

      await engine.remove(a.id);
      final c = await engine.launch(chicken());
      expect(c.displayName, 'Poulet rôti');
      expect(engine.count, 2);
    });

    test('tri : à confirmer en tête, puis par prochaine échéance', () async {
      final a = await engine.launch(eggs()); // fin 12 h 06
      final b = await engine.launch(chicken(), mode: LaunchMode.confirmation);
      wait(const Duration(minutes: 5));
      final c = await engine.launch(eggs()); // fin 12 h 11
      expect(engine.timers.map((t) => t.id), [a.id, c.id, b.id]);

      wait(const Duration(minutes: 10)); // 12 h 15 : b attend une validation
      await engine.update();
      expect(engine.timers.first.id, b.id);
    });
  });

  group('Enregistrement', () {
    test('reprise après redémarrage de l’application', () async {
      final t = await engine.launch(chicken(), mode: LaunchMode.confirmation);
      wait(const Duration(minutes: 5));
      await engine.pause(t.id);

      final restarted = newEngine();
      await restarted.load();
      final reloaded = restarted.findById(t.id)!;
      expect(reloaded.status, TimerStatus.paused);
      expect(reloaded.mode, LaunchMode.confirmation);
      expect(reloaded.displayName, 'Poulet rôti');
      expect(reloaded.remainingAt(now), const Duration(minutes: 10));
      restarted.dispose();
    });

    test('rattrapage du temps écoulé application fermée', () async {
      final t = await engine.launch(chicken());
      wait(const Duration(minutes: 20));

      final restarted = newEngine();
      await restarted.load();
      final reloaded = restarted.findById(t.id)!;
      expect(reloaded.stepIndex, 1);
      expect(reloaded.remainingAt(now), const Duration(minutes: 20));
      restarted.dispose();
    });
  });
}