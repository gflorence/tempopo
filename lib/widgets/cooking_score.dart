import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_colors.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import 'illustration.dart';

/// Partition de cuisson verticale : étapes, rappels et fin, reliés par une
/// ligne, comme une portée de musique.
class CookingScore extends StatelessWidget {
  const CookingScore({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final steps = recipe.steps;
    final items = <(Widget, Widget)>[];

    for (var i = 0; i < steps.length; i++) {
      items.add((ScoreStepNode(number: i + 1), ScoreStepCard(step: steps[i])));
      final isLast = i == steps.length - 1;
      final reminder = steps[i].reminder.trim();
      if (!isLast && reminder.isNotEmpty) {
        items.add((const ScoreReminderNode(), ScoreReminderCard(text: reminder)));
      }
    }
    items.add((const ScoreEndNode(), ScoreEndCard(message: recipe.endMessage)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var k = 0; k < items.length; k++)
          ScoreRow(
            isFirst: k == 0,
            isLast: k == items.length - 1,
            node: items[k].$1,
            child: items[k].$2,
          ),
      ],
    );
  }
}

/// Une ligne de la partition : la pastille à gauche, le contenu à droite.
class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    required this.node,
    required this.child,
    required this.isFirst,
    required this.isLast,
  });

  final Widget node;
  final Widget child;
  final bool isFirst;
  final bool isLast;

  static const double _railWidth = 52;
  static const double _nodeCenter = 26;

  @override
  Widget build(BuildContext context) {
    final lineColor = context.palette.divider;
    final showLine = !(isFirst && isLast);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _railWidth,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (showLine)
                  Positioned(
                    top: isFirst ? _nodeCenter : 0,
                    bottom: isLast ? null : 0,
                    height: isLast ? _nodeCenter : null,
                    child: Container(width: 3, color: lineColor),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: node,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Pastilles ----------

/// Pastille rouge tomate numérotée d'une étape.
class ScoreStepNode extends StatelessWidget {
  const ScoreStepNode({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: TempopoTypography.fraunces(18, weight: 700)
            .copyWith(color: scheme.onPrimary),
      ),
    );
  }
}

class _IconNode extends StatelessWidget {
  const _IconNode({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: foreground),
      ),
    );
  }
}

/// Pastille jaune d'œuf d'un rappel.
class ScoreReminderNode extends StatelessWidget {
  const ScoreReminderNode({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IconNode(
      icon: Icons.notifications_active_rounded,
      background: TempopoColors.eggYolk,
      foreground: TempopoColors.soyInk,
    );
  }
}

/// Pastille vert shiso de la fin de recette.
class ScoreEndNode extends StatelessWidget {
  const ScoreEndNode({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IconNode(
      icon: Icons.flag_rounded,
      background: TempopoColors.shisoGreen,
      foreground: Colors.white,
    );
  }
}

// ---------- Contenus ----------

/// Carte d'une étape chronométrée : icône du type, durée, nom, température.
/// [highlighted] servira à signaler l'étape en cours (phase 2).
class ScoreStepCard extends StatelessWidget {
  const ScoreStepCard({super.key, required this.step, this.highlighted = false});

  final RecipeStep step;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? scheme.primary : palette.divider,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          StepKindIcon(kind: step.kind, size: 30, color: palette.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.duration(step.durationSeconds),
                  style: TempopoTypography.timer(26, color: scheme.onSurface),
                ),
                if (step.name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.name,
                    style: TempopoTypography.manrope(15, weight: 600)
                        .copyWith(color: palette.mutedText),
                  ),
                ],
              ],
            ),
          ),
          if (step.temperature.isNotEmpty) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  step.temperature,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TempopoTypography.manrope(14, weight: 800)
                      .copyWith(color: scheme.onTertiaryContainer),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rappel entre deux étapes : fond sésame, texte éditorial en Fraunces.
class ScoreReminderCard extends StatelessWidget {
  const ScoreReminderCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: palette.reminderSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.reminder.toUpperCase(),
            style: TempopoTypography.manrope(11, weight: 800, letterSpacing: 1.2)
                .copyWith(color: palette.onReminderSurface),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: TempopoTypography.fraunces(17, weight: 500, height: 1.25)
                .copyWith(color: palette.onReminderSurface),
          ),
        ],
      ),
    );
  }
}

/// Fin de la recette : message de fin, ou « C'est prêt ! » par défaut.
class ScoreEndCard extends StatelessWidget {
  const ScoreEndCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = context.palette;
    final text = message.trim().isEmpty ? s.readyDefault : message.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.toFinish.toUpperCase(),
            style: TempopoTypography.manrope(11, weight: 800, letterSpacing: 1.2)
                .copyWith(color: palette.successText),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: TempopoTypography.fraunces(18, weight: 600)
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}