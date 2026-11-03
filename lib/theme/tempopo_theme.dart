import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tempopo_colors.dart';
import 'tempopo_typography.dart';

/// Couleurs propres à Tempopo, en plus du ColorScheme de Material.
/// Accès dans un écran : `context.palette.reminderSurface`.
@immutable
class TempopoPalette extends ThemeExtension<TempopoPalette> {
  const TempopoPalette({
    required this.paper,
    required this.accentText,
    required this.successText,
    required this.highlight,
    required this.reminderSurface,
    required this.onReminderSurface,
    required this.mutedText,
    required this.divider,
  });

  /// Fond des cartes, dialogues et fenêtres.
  final Color paper;

  /// Rouge tomate lisible pour les petits textes et boutons texte.
  final Color accentText;

  /// Vert shiso lisible (actions terminées, confirmations).
  final Color successText;

  /// Jaune d'œuf (accents, minuteurs, alertes).
  final Color highlight;

  /// Fond des rappels entre étapes.
  final Color reminderSurface;
  final Color onReminderSurface;

  /// Texte secondaire.
  final Color mutedText;

  /// Séparateurs et contours discrets.
  final Color divider;

  static const TempopoPalette light = TempopoPalette(
    paper: TempopoColors.paperLight,
    accentText: TempopoColors.tomatoText,
    successText: TempopoColors.shisoDeep,
    highlight: TempopoColors.eggYolk,
    reminderSurface: TempopoColors.sesameBeige,
    onReminderSurface: TempopoColors.soyInk,
    mutedText: TempopoColors.mutedLight,
    divider: TempopoColors.sesameBeige,
  );

  static const TempopoPalette dark = TempopoPalette(
    paper: TempopoColors.paperDark,
    accentText: TempopoColors.tomatoTextDark,
    successText: TempopoColors.shisoLight,
    highlight: TempopoColors.eggYolk,
    reminderSurface: TempopoColors.reminderDark,
    onReminderSurface: TempopoColors.noodleCream,
    mutedText: TempopoColors.sesameBeige,
    divider: TempopoColors.dividerDark,
  );

  @override
  TempopoPalette copyWith({
    Color? paper,
    Color? accentText,
    Color? successText,
    Color? highlight,
    Color? reminderSurface,
    Color? onReminderSurface,
    Color? mutedText,
    Color? divider,
  }) {
    return TempopoPalette(
      paper: paper ?? this.paper,
      accentText: accentText ?? this.accentText,
      successText: successText ?? this.successText,
      highlight: highlight ?? this.highlight,
      reminderSurface: reminderSurface ?? this.reminderSurface,
      onReminderSurface: onReminderSurface ?? this.onReminderSurface,
      mutedText: mutedText ?? this.mutedText,
      divider: divider ?? this.divider,
    );
  }

  @override
  TempopoPalette lerp(covariant ThemeExtension<TempopoPalette>? other, double t) {
    if (other is! TempopoPalette) return this;
    return TempopoPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      reminderSurface: Color.lerp(reminderSurface, other.reminderSurface, t)!,
      onReminderSurface:
          Color.lerp(onReminderSurface, other.onReminderSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Raccourci : `context.palette`.
extension TempopoThemeContext on BuildContext {
  TempopoPalette get palette =>
      Theme.of(this).extension<TempopoPalette>() ?? TempopoPalette.light;
}

/// Thèmes clair et sombre de Tempopo.
class TempopoTheme {
  TempopoTheme._();

  static ThemeData light() => _build(_lightScheme, TempopoPalette.light);
  static ThemeData dark() => _build(_darkScheme, TempopoPalette.dark);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: TempopoColors.tomatoRed,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFF6D9CE),
    onPrimaryContainer: Color(0xFF5E1F11),
    secondary: TempopoColors.shisoDeep,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDDE2D3),
    onSecondaryContainer: TempopoColors.soyInk,
    tertiary: TempopoColors.eggYolk,
    onTertiary: TempopoColors.soyInk,
    tertiaryContainer: Color(0xFFF3E1B5),
    onTertiaryContainer: Color(0xFF4A3608),
    error: Color(0xFF9E2B1F),
    onError: Colors.white,
    errorContainer: Color(0xFFF3D3CB),
    onErrorContainer: Color(0xFF5C1A10),
    surface: TempopoColors.noodleCream,
    onSurface: TempopoColors.soyInk,
    onSurfaceVariant: TempopoColors.mutedLight,
    surfaceContainerLowest: Color(0xFFFFFBF4),
    surfaceContainerLow: TempopoColors.paperLight,
    surfaceContainer: Color(0xFFF0E6D2),
    surfaceContainerHigh: Color(0xFFEBDFC8),
    surfaceContainerHighest: Color(0xFFE5D7BD),
    outline: TempopoColors.outlineLight,
    outlineVariant: TempopoColors.sesameBeige,
    inverseSurface: TempopoColors.soyInk,
    onInverseSurface: TempopoColors.noodleCream,
    inversePrimary: TempopoColors.eggYolk,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: TempopoColors.tomatoBright,
    onPrimary: TempopoColors.soyInk,
    primaryContainer: Color(0xFF6E2A1A),
    onPrimaryContainer: Color(0xFFF8D6CB),
    secondary: TempopoColors.shisoLight,
    onSecondary: TempopoColors.soyInk,
    secondaryContainer: Color(0xFF3F4A3A),
    onSecondaryContainer: Color(0xFFDDE5D5),
    tertiary: TempopoColors.eggYolk,
    onTertiary: TempopoColors.soyInk,
    tertiaryContainer: Color(0xFF5A4513),
    onTertiaryContainer: Color(0xFFF3E1B5),
    error: Color(0xFFF2A08C),
    onError: Color(0xFF4A140B),
    errorContainer: Color(0xFF6E2A1A),
    onErrorContainer: Color(0xFFF8D6CB),
    surface: TempopoColors.soyInk,
    onSurface: TempopoColors.noodleCream,
    onSurfaceVariant: TempopoColors.sesameBeige,
    surfaceContainerLowest: Color(0xFF23261F),
    surfaceContainerLow: Color(0xFF2E3129),
    surfaceContainer: TempopoColors.paperDark,
    surfaceContainerHigh: Color(0xFF3B3F35),
    surfaceContainerHighest: Color(0xFF44483D),
    outline: TempopoColors.outlineDark,
    outlineVariant: TempopoColors.dividerDark,
    inverseSurface: TempopoColors.noodleCream,
    onInverseSurface: TempopoColors.soyInk,
    inversePrimary: TempopoColors.tomatoText,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(ColorScheme scheme, TempopoPalette palette) {
    final text = TempopoTypography.textTheme(scheme.onSurface);
    final radius = BorderRadius.circular(14);
    final buttonShape = RoundedRectangleBorder(borderRadius: radius);
    final buttonText = TempopoTypography.manrope(16, weight: 700, height: 1.2);
    final pickerText = TempopoTypography.manrope(22, weight: 600, tabular: true)
        .copyWith(color: scheme.onSurface);

    OutlineInputBorder inputBorder(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      fontFamily: TempopoTypography.sans,
      textTheme: text,
      extensions: [palette],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TempopoTypography.fraunces(26, wonky: true)
            .copyWith(color: scheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: palette.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.divider),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: palette.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle:
            TempopoTypography.fraunces(22).copyWith(color: scheme.onSurface),
        contentTextStyle:
            TempopoTypography.manrope(16).copyWith(color: scheme.onSurface),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.paper,
        modalBackgroundColor: palette.paper,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accentText,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: scheme.outline, width: 1.5),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accentText,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: buttonText,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 22),
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 60),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
        labelStyle:
            TempopoTypography.manrope(16).copyWith(color: palette.mutedText),
        floatingLabelStyle: TempopoTypography.manrope(16, weight: 700)
            .copyWith(color: palette.accentText),
        hintStyle:
            TempopoTypography.manrope(16).copyWith(color: palette.mutedText),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TempopoTypography.manrope(15, weight: 600)
            .copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: palette.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TempopoTypography.manrope(16, weight: 600)
            .copyWith(color: scheme.onSurface),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: palette.mutedText,
        titleTextStyle: TempopoTypography.manrope(17, weight: 700)
            .copyWith(color: scheme.onSurface),
        subtitleTextStyle:
            TempopoTypography.manrope(14).copyWith(color: palette.mutedText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: palette.divider,
      ),

      // Roulettes h/min/s : police Manrope à chiffres fixes.
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: scheme.brightness,
        primaryColor: scheme.primary,
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: pickerText,
          dateTimePickerTextStyle: pickerText,
        ),
      ),
    );
  }
}