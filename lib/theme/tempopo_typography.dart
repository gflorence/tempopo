import 'package:flutter/material.dart';

/// Typographie de Tempopo.
/// - Fraunces : titres et éléments de personnalité (réglage « Soft » arrondi).
/// - Manrope : interface, boutons, formulaires.
/// Les deux polices sont « variables » : la graisse est réglée par
/// fontVariations, en plus de fontWeight.
class TempopoTypography {
  TempopoTypography._();

  static const String serif = 'Fraunces';
  static const String sans = 'Manrope';

  static FontWeight _weight(int weight) =>
      FontWeight.values[(weight ~/ 100).clamp(1, 9) - 1];

  /// Style Fraunces. [wonky] active les lettres « penchées » de Fraunces,
  /// à réserver aux grands titres.
  static TextStyle fraunces(
    double size, {
    int weight = 600,
    bool wonky = false,
    double height = 1.15,
  }) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      height: height,
      fontWeight: _weight(weight),
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation('opsz', size.clamp(9, 144).toDouble()),
        FontVariation('SOFT', 100),
        FontVariation('WONK', wonky ? 1 : 0),
      ],
    );
  }

  /// Style Manrope. [tabular] active les chiffres de largeur fixe.
  static TextStyle manrope(
    double size, {
    int weight = 500,
    double height = 1.35,
    double letterSpacing = 0,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: _weight(weight),
      fontVariations: [FontVariation('wght', weight.toDouble())],
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// Chiffres des comptes à rebours : très gras, largeur fixe (aucun
  /// tremblement pendant le décompte).
  static TextStyle timer(double size, {Color? color}) {
    return manrope(size, weight: 800, height: 1.0, letterSpacing: -0.5, tabular: true)
        .copyWith(color: color);
  }

  /// Échelle complète des textes de l'application.
  static TextTheme textTheme(Color ink) {
    final theme = TextTheme(
      displayLarge: fraunces(57, wonky: true),
      displayMedium: fraunces(45, wonky: true),
      displaySmall: fraunces(36, wonky: true),
      headlineLarge: fraunces(32),
      headlineMedium: fraunces(28),
      headlineSmall: fraunces(24),
      titleLarge: fraunces(22),
      titleMedium: manrope(16, weight: 700),
      titleSmall: manrope(14, weight: 700),
      bodyLarge: manrope(16),
      bodyMedium: manrope(15),
      bodySmall: manrope(13),
      labelLarge: manrope(15, weight: 700),
      labelMedium: manrope(13, weight: 700),
      labelSmall: manrope(12, weight: 700),
    );
    return theme.apply(bodyColor: ink, displayColor: ink);
  }
}