import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// Carte de contenu standard de MediConnect.
///
/// Surface blanche à coins arrondis avec une bordure discrète. Peut être
/// rendue cliquable via [onTap] (effet d'encre Material).
class CarteApplication extends StatelessWidget {
  const CarteApplication({
    super.key,
    required this.enfant,
    this.rembourrage,
    this.onTap,
  });

  final Widget enfant;
  final EdgeInsetsGeometry? rembourrage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(DimensionsApplication.rayonGrand);

    return Material(
      color: CouleursApplication.surface,
      borderRadius: rayon,
      child: InkWell(
        onTap: onTap,
        borderRadius: rayon,
        child: Container(
          padding: rembourrage ??
              const EdgeInsets.all(DimensionsApplication.espacementMoyen),
          decoration: BoxDecoration(
            borderRadius: rayon,
            border: Border.all(color: CouleursApplication.bordure),
          ),
          child: enfant,
        ),
      ),
    );
  }
}
