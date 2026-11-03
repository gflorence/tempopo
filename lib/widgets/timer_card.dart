import 'package:flutter/material.dart';

import '../app_services.dart';
import '../l10n/strings.dart';
import '../models/active_timer.dart';
import '../theme/tempopo_colors.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import 'confirm_dialog.dart';
import 'cooking_score.dart';
import 'illustration.dart';

/// Carte d'un minuteur en cours.
class TimerCard extends StatelessWidget {
  const TimerCard({super.key, required this.timer, required this.now});

  final ActiveTimer timer;
  final DateTime now;

  static const Duration _oneMinute = Duration(minutes: 1);

  String _clockTime(BuildContext context, DateTime time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  Future<void> _stop(BuildContext context) async {
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
    if (confirmed) await engine.remove(timer.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final status = timer.status;

    final borderColor = switch (status) {
      TimerStatus.awaitingConfirmation => palette.highlight,
      TimerStatus.finished => TempopoColors.shisoGreen,
      _ => palette.divider,
    };
    final strongBorder = status == TimerStatus.awaitingConfirmation ||
        status == TimerStatus.finished;

    return Card(
      color: status == TimerStatus.awaitingConfirmation
          ? scheme.tertiaryContainer
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: strongBorder ? 3 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            switch (status) {
              TimerStatus.running ||
              TimerStatus.paused =>
                _buildRunning(context),
              TimerStatus.awaitingConfirmation => _buildAwaiting(context),
              TimerStatus.finished => _buildFinished(context),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final step = timer.currentStep;
    final total = timer.recipe.steps.length;

    var stepLine = total > 1
        ? s.stepOf(timer.stepIndex + 1, total)
        : s.duration(timer.recipe.totalSeconds);
    if (step.name.isNotEmpty) stepLine = '$stepLine · ${step.name}';

    return Row(
      children: [
        RecipeIllustrationView(illustration: timer.recipe.illustration, size: 44),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timer.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TempopoTypography.fraunces(19)
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  StepKindIcon(kind: step.kind, size: 16, color: palette.mutedText),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      stepLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TempopoTypography.manrope(13, weight: 600)
                          .copyWith(color: palette.mutedText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusChip(status: timer.status),
      ],
    );
  }

  Widget _buildRunning(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final engine = AppServices.of(context).engine;
    final paused = timer.status == TimerStatus.paused;
    final step = timer.currentStep;
    final next = timer.nextStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  s.countdown(timer.remainingAt(now)),
                  style: TempopoTypography.timer(
                    48,
                    color: paused ? palette.mutedText : scheme.onSurface,
                  ),
                ),
              ),
            ),
            if (step.temperature.isNotEmpty) _TemperatureChip(step.temperature),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: timer.progressAt(now),
            minHeight: 8,
            color: paused ? palette.mutedText : scheme.primary,
            backgroundColor: palette.divider,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.endsAt(
            _clockTime(context, timer.estimatedEndAt(now)),
            estimate: timer.endIsEstimate,
          ),
          style: TempopoTypography.manrope(13, weight: 700)
              .copyWith(color: palette.mutedText),
        ),
        if (next != null) ...[
          const SizedBox(height: 2),
          Text(
            s.next(s.stepSummary(next.durationSeconds, next.temperature)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TempopoTypography.manrope(13)
                .copyWith(color: palette.mutedText),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: paused ? s.resume : s.pause,
              iconSize: 28,
              onPressed: () =>
                  paused ? engine.resume(timer.id) : engine.pause(timer.id),
              icon: Icon(
                paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
            _MinuteButton(
              label: '−1',
              tooltip: s.minusOneMinute,
              onPressed: engine.canAdjust(timer, -_oneMinute)
                  ? () => engine.addTime(timer.id, -_oneMinute)
                  : null,
            ),
            _MinuteButton(
              label: '+1',
              tooltip: s.plusOneMinute,
              onPressed: () => engine.addTime(timer.id, _oneMinute),
            ),
            IconButton(
              tooltip: s.nextStep,
              iconSize: 28,
              onPressed: () => engine.skip(timer.id),
              icon: const Icon(Icons.skip_next_rounded),
            ),
            IconButton(
              tooltip: s.stop,
              iconSize: 28,
              color: scheme.error,
              onPressed: () => _stop(context),
              icon: const Icon(Icons.stop_circle_outlined),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAwaiting(BuildContext context) {
    final s = S.of(context);
    final palette = context.palette;
    final engine = AppServices.of(context).engine;
    final reminder = timer.currentStep.reminder.trim();
    final next = timer.nextStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreReminderCard(text: reminder.isEmpty ? s.nextStepReady : reminder),
        if (next != null) ...[
          const SizedBox(height: 6),
          Text(
            s.next(s.stepSummary(next.durationSeconds, next.temperature)),
            style: TempopoTypography.manrope(14, weight: 600)
                .copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => engine.confirm(timer.id),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  textStyle: TempopoTypography.manrope(17, weight: 800),
                ),
                icon: const Icon(Icons.check_rounded, size: 26),
                label: Text(s.done),
              ),
            ),
            const SizedBox(width: 8),
            _MinuteButton(
              label: '+1',
              tooltip: s.plusOneMinute,
              onPressed: () => engine.addTime(timer.id, _oneMinute),
            ),
            IconButton(
              tooltip: s.stop,
              color: palette.accentText,
              onPressed: () => _stop(context),
              icon: const Icon(Icons.stop_circle_outlined),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinished(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final engine = AppServices.of(context).engine;
    final message = timer.recipe.endMessage.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message.isEmpty ? s.readyDefault : message,
          style: TempopoTypography.fraunces(20, weight: 600)
              .copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => engine.remove(timer.id),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                  textStyle: TempopoTypography.manrope(17, weight: 800),
                ),
                icon: const Icon(Icons.check_rounded, size: 26),
                label: Text(s.finish),
              ),
            ),
            const SizedBox(width: 8),
            _MinuteButton(
              label: '+1',
              tooltip: s.plusOneMinute,
              onPressed: () => engine.addTime(timer.id, _oneMinute),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bouton « −1 » / « +1 » (minute).
class _MinuteButton extends StatelessWidget {
  const _MinuteButton({
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
          minimumSize: const Size(56, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: TempopoTypography.manrope(17, weight: 800, tabular: true),
        ),
        child: Text(label),
      ),
    );
  }
}

class _TemperatureChip extends StatelessWidget {
  const _TemperatureChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TempopoTypography.manrope(14, weight: 800)
              .copyWith(color: scheme.onTertiaryContainer),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (label, background, foreground) = switch (status) {
      TimerStatus.running => (
          s.statusRunning,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      TimerStatus.paused => (
          s.statusPaused,
          TempopoColors.sesameBeige,
          TempopoColors.soyInk,
        ),
      TimerStatus.awaitingConfirmation => (
          s.statusAwaiting,
          TempopoColors.eggYolk,
          TempopoColors.soyInk,
        ),
      TimerStatus.finished => (
          s.statusFinished,
          TempopoColors.shisoGreen,
          Colors.white,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TempopoTypography.manrope(12, weight: 800)
            .copyWith(color: foreground),
      ),
    );
  }
}