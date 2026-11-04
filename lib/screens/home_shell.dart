import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_services.dart';
import '../engine/timer_engine.dart';
import '../l10n/strings.dart';
import '../models/active_timer.dart';
import '../services/vibration_service.dart';
import '../theme/tempopo_colors.dart';
import '../theme/tempopo_theme.dart';
import 'recipe_list_screen.dart';
import 'running_screen.dart';

/// Écran principal : onglets « Recettes » et « En cours ».
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  AppServices? _services;
  StreamSubscription<TimerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services == null) {
      final services = AppServices.of(context);
      _services = services;
      _subscription = services.engine.events.listen(_onTimerEvent);
    }
  }

  /// Fin d'étape vécue en direct : vibration et affichage de « En cours ».
  /// (Les vraies sonneries et alertes arrivent en phase 3.)
  void _onTimerEvent(TimerEvent event) {
    vibrateAlert();
    _services?.tabIndex.value = AppServices.runningTab;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _services?.engine.update();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: services.tabIndex,
      builder: (context, index, _) {
        final bar = _TempopoNavigationBar(
          index: index,
          onSelected: (value) => services.tabIndex.value = value,
        );
        return IndexedStack(
          index: index,
          children: [
            RecipeListScreen(repository: services.repository, bottomBar: bar),
            RunningScreen(bottomBar: bar),
          ],
        );
      },
    );
  }
}

class _TempopoNavigationBar extends StatelessWidget {
  const _TempopoNavigationBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final engine = AppServices.of(context).engine;

    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        final count = engine.count;
        final attention = engine.timers.any(
          (t) =>
              t.status == TimerStatus.awaitingConfirmation ||
              t.status == TimerStatus.finished,
        );

        Widget badged(IconData icon) => Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              backgroundColor:
                  attention ? TempopoColors.eggYolk : scheme.primary,
              textColor: attention ? TempopoColors.soyInk : scheme.onPrimary,
              child: Icon(icon),
            );

        return NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onSelected,
          backgroundColor: palette.paper,
          surfaceTintColor: Colors.transparent,
          indicatorColor: scheme.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: s.recipesTab,
            ),
            NavigationDestination(
              icon: badged(Icons.timer_outlined),
              selectedIcon: badged(Icons.timer_rounded),
              label: s.runningTab,
            ),
          ],
        );
      },
    );
  }
}