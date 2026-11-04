import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app_services.dart';
import '../l10n/strings.dart';
import '../models/active_timer.dart';
import '../theme/tempopo_colors.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/illustration.dart';

/// Ouvre l'écran du minuteur actif, par-dessus l'onglet « En cours ».
void openActiveTimer(AppServices services, String timerId) {
  services.openRunning();
  services.navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => ActiveTimerScreen(timerId: timerId)),
  );
}

/// Écran F : un minuteur en grand, toujours en thème sombre,
/// lisible de loin. L'écran reste allumé tant qu'il est affiché.
class ActiveTimerScreen extends StatefulWidget {
  const ActiveTimerScreen({super.key, required this.timerId});

  final String timerId;

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  static const Duration _oneMinute = Duration(minutes: 1);
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  String _clockTime(BuildContext context, DateTime time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  Future<void> _stop(BuildContext context, ActiveTimer timer) async {
    final s = S.of(context);
    final engine = AppServices.of(context).engine;
    final confirmed = await showConfirmDialog(
      context,
      title: s.stopTitle(timer.displayName),
      message: s.stopBody,
      confirmLabel: s.stop,
      cancelLabel: s.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await engine.remove(timer.id);
    _close();
  }

  Future<void> _finish(BuildContext context, ActiveTimer timer) async {
    await AppServices.of(context).engine.remove(timer.id);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final engine = AppServices.of(context).engine;

    return Theme(
      data: TempopoTheme.dark(),
      child: ListenableBuilder(
        listenable: engine,
        builder: (context, _) {
          final timer = engine.findById(widget.timerId);
          if (timer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _close());
            return const Scaffold(backgroundColor: TempopoColors.soyInk);
          }
          return _buildScreen(context, timer, engine.now);
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, ActiveTimer timer, DateTime now) {
    final s = S.of(context);
    final step = timer.currentStep;
    final total = timer.recipe.steps.length;

    var stepLine = total > 1
        ? s.stepOf(timer.stepIndex + 1, total)
        : s.duration(timer.recipe.totalSeconds);
    if (step.name.isNotEmpty) stepLine = '$stepLine · ${step.name}';

    return Scaffold(
      backgroundColor: TempopoColors.soyInk,
      appBar: AppBar(
        backgroundColor: TempopoColors.soyInk,
        title: Text(
          timer.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StepKindIcon(
                          kind: step.kind,
                          size: 26,
                          color: TempopoColors.eggYolk,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            stepLine,
                            textAlign: TextAlign.center,
                            style: TempopoTypography.manrope(19, weight: 700)
                                .copyWith(color: TempopoColors.noodleCream),
                          ),
                        ),
                      ],
                    ),
                    if (step.temperature.isNotEmpty &&
                        timer.status != TimerStatus.finished) ...[
                      const SizedBox(height: 14),
                      Center(child: _TemperatureBadge(step.temperature)),
                    ],
                    const Spacer(),
                    ..._buildCenter(context, timer, now),
                    const Spacer(),
                    ..._buildPreview(context, timer),
                    const SizedBox(height: 24),
                    ..._buildControls(context, timer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Partie centrale ----------

  List<Widget> _buildCenter(
    BuildContext context,
    ActiveTimer timer,
    DateTime now,
  ) {
    final s = S.of(context);

    switch (timer.status) {
      case TimerStatus.running:
      case TimerStatus.paused:
        final paused = timer.status == TimerStatus.paused;
        return [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              s.countdown(timer.remainingAt(now)),
              style: TempopoTypography.timer(
                120,
                color: paused
                    ? TempopoColors.sesameBeige
                    : TempopoColors.noodleCream,
              ),
            ),
          ),
          if (paused)
            Text(
              s.statusPaused.toUpperCase(),
              textAlign: TextAlign.center,
              style: TempopoTypography.manrope(16, weight: 800, letterSpacing: 2)
                  .copyWith(color: TempopoColors.eggYolk),
            ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: timer.progressAt(now),
              minHeight: 12,
              color: paused ? TempopoColors.sesameBeige : TempopoColors.eggYolk,
              backgroundColor: TempopoColors.dividerDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.endsAt(
              _clockTime(context, timer.estimatedEndAt(now)),
              estimate: timer.endIsEstimate,
            ),
            textAlign: TextAlign.center,
            style: TempopoTypography.manrope(18, weight: 700)
                .copyWith(color: TempopoColors.sesameBeige),
          ),
        ];

      case TimerStatus.awaitingConfirmation:
        final reminder = timer.currentStep.reminder.trim();
        return [
          Text(
            s.statusAwaiting.toUpperCase(),
            textAlign: TextAlign.center,
            style: TempopoTypography.manrope(16, weight: 800, letterSpacing: 2)
                .copyWith(color: TempopoColors.eggYolk),
          ),
          const SizedBox(height: 12),
          Text(
            reminder.isEmpty ? s.nextStepReady : reminder,
            textAlign: TextAlign.center,
            style: TempopoTypography.fraunces(34, weight: 600, height: 1.2)
                .copyWith(color: TempopoColors.noodleCream),
          ),
        ];

      case TimerStatus.finished:
        final message = timer.recipe.endMessage.trim();
        return [
          Center(
            child: RecipeIllustrationView(
              illustration: timer.recipe.illustration,
              size: 150,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.statusFinished.toUpperCase(),
            textAlign: TextAlign.center,
            style: TempopoTypography.manrope(16, weight: 800, letterSpacing: 2)
                .copyWith(color: TempopoColors.shisoLight),
          ),
          const SizedBox(height: 8),
          Text(
            message.isEmpty ? s.readyDefault : message,
            textAlign: TextAlign.center,
            style: TempopoTypography.fraunces(34, weight: 600, height: 1.2)
                .copyWith(color: TempopoColors.noodleCream),
          ),
        ];
    }
  }

  // ---------- Aperçu de la suite ----------

  List<Widget> _buildPreview(BuildContext context, ActiveTimer timer) {
    final s = S.of(context);
    if (timer.status == TimerStatus.finished) return const [];

    final next = timer.nextStep;
    final reminder = timer.currentStep.reminder.trim();
    final showReminder =
        timer.status != TimerStatus.awaitingConfirmation && reminder.isNotEmpty;
    final label = next == null ? s.lastStep : s.upNext;

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TempopoColors.paperDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TempopoTypography.manrope(12, weight: 800, letterSpacing: 1.2)
                  .copyWith(color: TempopoColors.sesameBeige),
            ),
            const SizedBox(height: 8),
            if (showReminder && next != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    size: 22,
                    color: TempopoColors.eggYolk,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reminder,
                      style: TempopoTypography.fraunces(18, weight: 500)
                          .copyWith(color: TempopoColors.noodleCream),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (next != null)
              Row(
                children: [
                  StepKindIcon(
                    kind: next.kind,
                    size: 22,
                    color: TempopoColors.sesameBeige,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      next.name.isEmpty
                          ? s.stepSummary(next.durationSeconds, next.temperature)
                          : '${s.stepSummary(next.durationSeconds, next.temperature)} · ${next.name}',
                      style: TempopoTypography.manrope(17, weight: 700)
                          .copyWith(color: TempopoColors.noodleCream),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    size: 22,
                    color: TempopoColors.shisoLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      timer.recipe.endMessage.trim().isEmpty
                          ? s.readyDefault
                          : timer.recipe.endMessage.trim(),
                      style: TempopoTypography.fraunces(18, weight: 500)
                          .copyWith(color: TempopoColors.noodleCream),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ];
  }

  // ---------- Commandes ----------

  List<Widget> _buildControls(BuildContext context, ActiveTimer timer) {
    final s = S.of(context);
    final engine = AppServices.of(context).engine;

    final stopButton = OutlinedButton.icon(
      onPressed: () => _stop(context, timer),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: TempopoColors.tomatoTextDark,
        side: const BorderSide(color: TempopoColors.tomatoTextDark, width: 1.5),
      ),
      icon: const Icon(Icons.stop_circle_outlined),
      label: Text(s.stop),
    );

    final plusOneButton = OutlinedButton(
      onPressed: () => engine.addTime(timer.id, _oneMinute),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: TempopoColors.noodleCream,
        side: const BorderSide(color: TempopoColors.sesameBeige, width: 1.5),
      ),
      child: Text(s.plusOneMinute),
    );

    switch (timer.status) {
      case TimerStatus.running:
      case TimerStatus.paused:
        final paused = timer.status == TimerStatus.paused;
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundMinuteButton(
                label: '−1',
                tooltip: s.minusOneMinute,
                onPressed: engine.canAdjust(timer, -_oneMinute)
                    ? () => engine.addTime(timer.id, -_oneMinute)
                    : null,
              ),
              Tooltip(
                message: paused ? s.resume : s.pause,
                child: FilledButton(
                  onPressed: () => paused
                      ? engine.resume(timer.id)
                      : engine.pause(timer.id),
                  style: FilledButton.styleFrom(
                    fixedSize: const Size(96, 96),
                    minimumSize: const Size(96, 96),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    backgroundColor: TempopoColors.tomatoRed,
                    foregroundColor: Colors.white,
                  ),
                  child: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 52,
                  ),
                ),
              ),
              _RoundMinuteButton(
                label: '+1',
                tooltip: s.plusOneMinute,
                onPressed: () => engine.addTime(timer.id, _oneMinute),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => engine.skip(timer.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: TempopoColors.noodleCream,
                    side: const BorderSide(
                      color: TempopoColors.sesameBeige,
                      width: 1.5,
                    ),
                  ),
                  icon: const Icon(Icons.skip_next_rounded),
                  label: Text(
                    s.nextStep,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: stopButton),
            ],
          ),
        ];

      case TimerStatus.awaitingConfirmation:
        return [
          FilledButton.icon(
            onPressed: () => engine.confirm(timer.id),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(76),
              backgroundColor: TempopoColors.tomatoRed,
              foregroundColor: Colors.white,
              textStyle: TempopoTypography.manrope(22, weight: 800),
            ),
            icon: const Icon(Icons.check_rounded, size: 32),
            label: Text(s.done),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: plusOneButton),
              const SizedBox(width: 12),
              Expanded(child: stopButton),
            ],
          ),
        ];

      case TimerStatus.finished:
        return [
          FilledButton.icon(
            onPressed: () => _finish(context, timer),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(76),
              backgroundColor: TempopoColors.shisoGreen,
              foregroundColor: Colors.white,
              textStyle: TempopoTypography.manrope(22, weight: 800),
            ),
            icon: const Icon(Icons.check_rounded, size: 32),
            label: Text(s.finish),
          ),
          const SizedBox(height: 12),
          plusOneButton,
        ];
    }
  }
}

/// Grand bouton rond « −1 » / « +1 ».
class _RoundMinuteButton extends StatelessWidget {
  const _RoundMinuteButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          fixedSize: const Size(76, 76),
          minimumSize: const Size(76, 76),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          foregroundColor: TempopoColors.noodleCream,
          side: BorderSide(
            color: onPressed == null
                ? TempopoColors.dividerDark
                : TempopoColors.noodleCream,
            width: 2,
          ),
          textStyle: TempopoTypography.manrope(24, weight: 800, tabular: true),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Température en grand, sur fond jaune d'œuf.
class _TemperatureBadge extends StatelessWidget {
  const _TemperatureBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: TempopoColors.eggYolk,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TempopoTypography.manrope(22, weight: 800)
            .copyWith(color: TempopoColors.soyInk),
      ),
    );
  }
}