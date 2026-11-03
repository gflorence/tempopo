import '../models/active_timer.dart';

/// Programmateur d'alarmes système.
///
/// Le moteur lui transmet la liste complète des minuteurs après chaque
/// changement ; le programmateur (re)programme les alarmes correspondantes.
/// Cette couche est isolée pour pouvoir écrire plus tard une version iOS.
abstract class AlarmScheduler {
  Future<void> sync(List<ActiveTimer> timers);
}

/// Phase 2 : aucun programmateur (les alarmes arrivent en phase 3).
class NoopAlarmScheduler implements AlarmScheduler {
  const NoopAlarmScheduler();

  @override
  Future<void> sync(List<ActiveTimer> timers) async {}
}