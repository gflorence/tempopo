import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Vibration d'alerte : trois impulsions d'une demi-seconde.
/// (En phase 3, les alertes passeront par le canal « alarme » d'Android.)
Future<void> vibrateAlert() async {
  try {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;
    await Vibration.vibrate(pattern: [0, 500, 250, 500, 250, 500]);
  } catch (error) {
    debugPrint('Vibration impossible : $error');
  }
}