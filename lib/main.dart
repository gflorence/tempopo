import 'package:flutter/material.dart';

void main() {
  runApp(const TempopoApp());
}

class TempopoApp extends StatelessWidget {
  const TempopoApp({super.key});

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
      home: const PhaseZeroScreen(),
    );
  }
}

class PhaseZeroScreen extends StatelessWidget {
  const PhaseZeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tempopo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Tempopo', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Phase 0 : la chaîne de fabrication fonctionne ✅',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}