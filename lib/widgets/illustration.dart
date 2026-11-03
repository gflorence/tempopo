import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/catalog.dart';
import '../theme/tempopo_colors.dart';

/// Disque beige derrière les illustrations (thème clair).
const Color _backdropLight = Color(0xFFEADCC2);

/// Illustration d'une recette, posée sur un disque beige façon étiquette.
class RecipeIllustrationView extends StatelessWidget {
  const RecipeIllustrationView({
    super.key,
    required this.illustration,
    this.size = 96,
    this.backdrop = true,
  });

  final RecipeIllustration illustration;
  final double size;

  /// Affiche le disque beige (recommandé, surtout en mode sombre).
  final bool backdrop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picture = SvgPicture.asset(
      illustration.assetPath,
      fit: BoxFit.contain,
    );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: backdrop
            ? DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? TempopoColors.sesameBeige : _backdropLight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(size * 0.08),
                  child: picture,
                ),
              )
            : picture,
      ),
    );
  }
}

/// Icône du type d'une étape (four, feu, eau, repos, autre), d'une seule couleur.
class StepKindIcon extends StatelessWidget {
  const StepKindIcon({
    super.key,
    required this.kind,
    this.size = 24,
    this.color,
  });

  final StepKind kind;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        kind.assetPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
}

/// Motif décoratif discret (vapeur, vagues, fleurs).
class MotifView extends StatelessWidget {
  const MotifView({
    super.key,
    required this.motif,
    required this.width,
    required this.height,
    this.color,
    this.opacity = 0.35,
  });

  final TempopoMotif motif;
  final double width;
  final double height;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Theme.of(context).colorScheme.outline;
    final alpha = (opacity.clamp(0, 1) * 255).round();
    return ExcludeSemantics(
      child: SvgPicture.asset(
        motif.assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(base.withAlpha(alpha), BlendMode.srcIn),
      ),
    );
  }
}