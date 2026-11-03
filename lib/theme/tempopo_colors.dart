import 'package:flutter/material.dart';

/// Palette officielle de Tempopo et variantes dérivées.
///
/// Les 6 couleurs de la charte sont la base de l'identité. Les variantes
/// « Deep » et « Text » sont des déclinaisons plus foncées (ou plus claires
/// en mode sombre) pour garantir la lisibilité des petits textes
/// (contraste WCAG ≥ 4,5:1).
class TempopoColors {
  TempopoColors._();

  // ---------- Les 6 couleurs de la charte ----------
  static const Color tomatoRed = Color(0xFFC94F35); // signature, CTA
  static const Color noodleCream = Color(0xFFF4EBD9); // fond principal
  static const Color soyInk = Color(0xFF292C25); // texte, mode sombre
  static const Color eggYolk = Color(0xFFD7A747); // accents, minuteurs
  static const Color shisoGreen = Color(0xFF71816A); // terminé, confirmé
  static const Color sesameBeige = Color(0xFFD8C5A8); // surfaces, séparateurs

  // ---------- Variantes, thème clair ----------
  /// Papier des cartes, un peu plus clair que le fond.
  static const Color paperLight = Color(0xFFFBF6EC);

  /// Rouge tomate foncé pour les petits textes (≈ 5,3:1 sur Noodle Cream).
  static const Color tomatoText = Color(0xFFA63D26);

  /// Vert shiso foncé pour les petits textes (≈ 5,4:1 sur Noodle Cream).
  static const Color shisoDeep = Color(0xFF55634F);

  /// Texte secondaire (≈ 5,9:1 sur Noodle Cream).
  static const Color mutedLight = Color(0xFF5A5A4E);

  /// Contour des champs (≈ 3,5:1 sur Noodle Cream).
  static const Color outlineLight = Color(0xFF8C7B62);

  // ---------- Variantes, thème sombre ----------
  /// Papier des cartes en mode sombre.
  static const Color paperDark = Color(0xFF33372E);

  /// Rouge tomate éclairci pour les boutons en mode sombre (≈ 4,8:1 avec Soy Ink).
  static const Color tomatoBright = Color(0xFFE8765A);

  /// Rouge tomate clair pour les petits textes en mode sombre (≈ 5:1).
  static const Color tomatoTextDark = Color(0xFFEE8A70);

  /// Vert shiso clair pour le mode sombre.
  static const Color shisoLight = Color(0xFFA9B8A0);

  /// Surface des rappels en mode sombre (Sesame assombri).
  static const Color reminderDark = Color(0xFF4A4637);

  static const Color outlineDark = Color(0xFF9A8F7C);
  static const Color dividerDark = Color(0xFF4A4E43);
}