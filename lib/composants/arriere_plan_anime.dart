import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../config/couleurs_application.dart';

/// Arrière-plan animé réutilisable, basé sur l'animation Rive `shapes.riv`.
///
/// Un léger flou et un voile translucide sont appliqués par-dessus l'animation
/// pour garantir la lisibilité du contenu affiché en surimpression (effet
/// « verre dépoli » repris du template d'origine).
class ArrierePlanAnime extends StatelessWidget {
  const ArrierePlanAnime({super.key, this.intensiteVoile = 0.82});

  /// Opacité du voile clair posé sur l'animation (0 = animation nette,
  /// 1 = voile opaque).
  final double intensiteVoile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RiveAnimation.asset(
            'assets/animations/shapes.riv',
            fit: BoxFit.cover,
            placeHolder: const ColoredBox(
              color: CouleursApplication.primaireClair,
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: CouleursApplication.fond.withValues(alpha: intensiteVoile),
            ),
          ),
        ),
      ],
    );
  }
}
