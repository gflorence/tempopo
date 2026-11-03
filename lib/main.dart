import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_services.dart';
import 'data/active_timer_store.dart';
import 'data/recipe_repository.dart';
import 'data/settings_store.dart';
import 'engine/timer_engine.dart';
import 'screens/home_shell.dart';
import 'services/alarm_scheduler.dart';
import 'theme/tempopo_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  final repository = RecipeRepository();
  final settings = SettingsStore();
  final engine = TimerEngine(
    store: FileActiveTimerStore(),
    scheduler: const NoopAlarmScheduler(),
  );

  await repository.load(languageCode: languageCode);
  await settings.load();
  await engine.load();
  engine.startTicker();

  runApp(TempopoApp(
    repository: repository,
    settings: settings,
    engine: engine,
    navigatorKey: GlobalKey<NavigatorState>(),
    // Des cuissons en cours ? On ouvre directement « En cours ».
    tabIndex: ValueNotifier<int>(
      engine.count > 0 ? AppServices.runningTab : AppServices.recipesTab,
    ),
  ));
}

class TempopoApp extends StatelessWidget {
  const TempopoApp({
    super.key,
    required this.repository,
    required this.settings,
    required this.engine,
    required this.navigatorKey,
    required this.tabIndex,
  });

  final RecipeRepository repository;
  final SettingsStore settings;
  final TimerEngine engine;
  final GlobalKey<NavigatorState> navigatorKey;
  final ValueNotifier<int> tabIndex;

  @override
  Widget build(BuildContext context) {
    return AppServices(
      repository: repository,
      engine: engine,
      settings: settings,
      navigatorKey: navigatorKey,
      tabIndex: tabIndex,
      child: MaterialApp(
        title: 'Tempopo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: TempopoTheme.light(),
        darkTheme: TempopoTheme.dark(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr'), Locale('en')],
        // Français si le téléphone est en français, sinon anglais.
        localeResolutionCallback: (locale, supportedLocales) =>
            locale?.languageCode == 'fr'
                ? const Locale('fr')
                : const Locale('en'),
        home: const HomeShell(),
      ),
    );
  }
}