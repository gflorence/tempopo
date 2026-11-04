import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_services.dart';
import '../l10n/strings.dart';
import '../models/active_timer.dart';
import '../models/recipe.dart';
import '../screens/active_timer_screen.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import 'illustration.dart';

/// Lance une recette : choix du mode (si plusieurs étapes), démarrage,
/// puis affichage de l'onglet « En cours ».
Future<void> startRecipe(BuildContext context, Recipe recipe) async {
  final services = AppServices.of(context);
  var mode = LaunchMode.automatic;

  if (recipe.steps.length > 1) {
    final chosen = await showModalBottomSheet<LaunchMode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => LaunchModeSheet(
        recipe: recipe,
        initial: services.settings.settings.lastLaunchMode,
      ),
    );
    if (chosen == null) return;
    mode = chosen;
    await services.settings.update(
      services.settings.settings.copyWith(lastLaunchMode: chosen),
    );
  }

  final timer = await services.engine.launch(recipe, mode: mode);
  await services.repository.markUsed(recipe.id);
  HapticFeedback.mediumImpact();
  openActiveTimer(services, timer.id);
}

/// Écran D : choix du mode d'enchaînement.
class LaunchModeSheet extends StatefulWidget {
  const LaunchModeSheet({super.key, required this.recipe, required this.initial});

  final Recipe recipe;
  final LaunchMode initial;

  @override
  State<LaunchModeSheet> createState() => _LaunchModeSheetState();
}

class _LaunchModeSheetState extends State<LaunchModeSheet> {
  late LaunchMode _mode = widget.initial;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final recipe = widget.recipe;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RecipeIllustrationView(illustration: recipe.illustration, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: theme.textTheme.headlineSmall),
                    Text(
                      '${s.stepCount(recipe.steps.length)} · '
                      '${s.duration(recipe.totalSeconds)}',
                      style: TempopoTypography.manrope(14, weight: 600)
                          .copyWith(color: palette.mutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(s.launchModeQuestion, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _ModeOption(
            icon: Icons.fast_forward_rounded,
            title: s.modeAutoTitle,
            body: s.modeAutoBody,
            selected: _mode == LaunchMode.automatic,
            onTap: () => setState(() => _mode = LaunchMode.automatic),
          ),
          const SizedBox(height: 10),
          _ModeOption(
            icon: Icons.touch_app_rounded,
            title: s.modeConfirmTitle,
            body: s.modeConfirmBody,
            selected: _mode == LaunchMode.confirmation,
            onTap: () => setState(() => _mode = LaunchMode.confirmation),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(_mode),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              textStyle: TempopoTypography.manrope(18, weight: 800),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 30),
            label: Text(s.startCooking),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final foreground = selected ? scheme.onPrimaryContainer : scheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : palette.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? scheme.primary : palette.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: selected ? scheme.onPrimaryContainer : palette.accentText,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TempopoTypography.manrope(17, weight: 800)
                          .copyWith(color: foreground),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: TempopoTypography.manrope(14)
                          .copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? scheme.primary : palette.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}