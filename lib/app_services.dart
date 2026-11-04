import 'package:flutter/material.dart';

import 'data/recipe_repository.dart';
import 'data/settings_store.dart';
import 'engine/timer_engine.dart';

/// Services partagés par toute l'application.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.repository,
    required this.engine,
    required this.settings,
    required this.navigatorKey,
    required this.tabIndex,
    required super.child,
  });

  final RecipeRepository repository;
  final TimerEngine engine;
  final SettingsStore settings;
  final GlobalKey<NavigatorState> navigatorKey;

  /// Onglet affiché : 0 = Recettes, 1 = En cours.
  final ValueNotifier<int> tabIndex;

  static const int recipesTab = 0;
  static const int runningTab = 1;

  static AppServices of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppServices>()!;

  /// Revient à l'écran principal et affiche l'onglet « En cours ».
  void openRunning() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    tabIndex.value = runningTab;
  }

  @override
  bool updateShouldNotify(covariant AppServices oldWidget) => false;
}