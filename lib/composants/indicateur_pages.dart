import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// Indicateur de progression (points) animé pour un [PageView].
///
/// Le point de la page active s'allonge pour matérialiser la position courante.
class IndicateurPages extends StatelessWidget {
  const IndicateurPages({
    super.key,
    required this.nombre,
    required this.indexActif,
  });

  final int nombre;
  final int indexActif;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(nombre, (index) {
        final actif = index == indexActif;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(
            horizontal: DimensionsApplication.espacementTresPetit,
          ),
          height: 8,
          width: actif ? 24 : 8,
          decoration: BoxDecoration(
            color: actif
                ? CouleursApplication.primaire
                : CouleursApplication.bordure,
            borderRadius:
                BorderRadius.circular(DimensionsApplication.rayonComplet),
          ),
        );
      }),
    );
  }
}
