import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// Bouton d'action secondaire (contour) de MediConnect.
///
/// Utilisé pour les actions non prioritaires, en complément d'un
/// [BoutonPrincipal]. Occupe toute la largeur disponible par défaut.
class BoutonSecondaire extends StatelessWidget {
  const BoutonSecondaire({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.pleineLargeur = true,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool pleineLargeur;

  @override
  Widget build(BuildContext context) {
    final bouton = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: CouleursApplication.primaire,
        side: const BorderSide(color: CouleursApplication.primaire),
        minimumSize: const Size(0, DimensionsApplication.hauteurBouton),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Row(
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
