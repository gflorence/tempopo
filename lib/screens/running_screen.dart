import 'package:flutter/material.dart';

import '../app_services.dart';
import '../l10n/strings.dart';
import '../models/recipe.dart';
import '../theme/tempopo_theme.dart';
import '../theme/tempopo_typography.dart';
import '../widgets/illustration.dart';
import '../widgets/quick_timer_sheet.dart';
import '../widgets/timer_card.dart';
import 'active_timer_screen.dart';

/// Écran « En cours » : une carte par minuteur actif.
/// Toucher une carte (hors boutons) ouvre le minuteur en grand.
class RunningScreen extends StatelessWidget {
  const RunningScreen({super.key, this.bottomBar});

  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final engine = services.engine;

    return Scaffold(
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: engine,
          builder: (builderContext, _) {
            final timers = engine.timers;
            final now = engine.now;

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _RunningHeader()),
                if (timers.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyRunning(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: timers.length,
                      itemBuilder: (itemContext, index) {
                        final timer = timers[index];
                        return GestureDetector(
                          key: ValueKey(timer.id),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openActiveTimer(services, timer.id),
                          child: TimerCard(timer: timer, now: now),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RunningHeader extends StatelessWidget {
  const _RunningHeader();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              s.runningTitle,
              style: TempopoTypography.fraunces(36, weight: 700, wonky: true)
                  .copyWith(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          MotifView(
            motif: TempopoMotif.steam,
            width: 40,
            height: 52,
            color: palette.highlight,
            opacity: 0.9,
          ),
        ],
      ),
    );
  }
}

class _EmptyRunning extends StatelessWidget {
  const _EmptyRunning();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RecipeIllustrationView(
            illustration: RecipeIllustration.minuteur,
            size: 140,
          ),
          const SizedBox(height: 20),
          Text(
            s.noRunning,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => startQuickTimer(context),
            icon: const Icon(Icons.timer_outlined),
            label: Text(s.quickTimer),
          ),
        ],
      ),
    );
  }
}