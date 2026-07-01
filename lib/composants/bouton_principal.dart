import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// Bouton d'action principal (rempli) de MediConnect.
///
/// Gère un état de chargement (indicateur circulaire) et une icône optionnelle.
/// Par défaut, il occupe toute la largeur disponible.
class BoutonPrincipal extends StatelessWidget {
  const BoutonPrincipal({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.enChargement = false,
    this.pleineLargeur = true,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool enChargement;
  final bool pleineLargeur;

  @override
  Widget build(BuildContext context) {
    final bouton = ElevatedButton(
      onPressed: enChargement ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApplication.primaire,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            CouleursApplication.primaire.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(0, DimensionsApplication.hauteurBouton),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: enChargement
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 20),
                  const SizedBox(width: DimensionsApplication.espacementPetit),
                ],
                Text(libelle),
              ],
            ),
    );

    return pleineLargeur ? SizedBox(width: double.infinity, child: bouton) : bouton;
  }
}
