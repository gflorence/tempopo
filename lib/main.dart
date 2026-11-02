import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/recipe_repository.dart';
import 'screens/recipe_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = RecipeRepository();
  final languageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  await repository.load(languageCode: languageCode);

  runApp(TempopoApp(repository: repository));
}

class TempopoApp extends StatelessWidget {
  const TempopoApp({super.key, required this.repository});

  final RecipeRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempopo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('en')],
      // Français si le téléphone est en français, sinon anglais.
      localeResolutionCallback: (locale, supportedLocales) =>
          locale?.languageCode == 'fr' ? const Locale('fr') : const Locale('en'),
      home: RecipeListScreen(repository: repository),
    );
  }
}