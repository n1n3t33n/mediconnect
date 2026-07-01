import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';
import '../modeles/modele_ordonnance.dart';
import '../utilitaires/formatage_date.dart';
import 'carte_application.dart';

/// Résumé cliquable d'une ordonnance, utilisé dans les listes « Mes
/// ordonnances ».
class CarteOrdonnance extends StatelessWidget {
  const CarteOrdonnance({
    super.key,
    required this.ordonnance,
    required this.estMedecin,
    required this.onTap,
  });

  final Ordonnance ordonnance;

  /// Vrai si l'utilisateur qui consulte la liste est le médecin émetteur (on
  /// affiche alors le nom du patient plutôt que celui du médecin).
  final bool estMedecin;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titre = estMedecin ? ordonnance.patientNom : ordonnance.medecinNom;
    final nbMedicaments = ordonnance.medicaments.length;

    return CarteApplication(
      onTap: onTap,
      enfant: Row(
        children: [
          const CircleAvatar(
            backgroundColor: CouleursApplication.primaireClair,
            child: Icon(
              Icons.receipt_long_outlined,
              color: CouleursApplication.primaireFonce,
            ),
          ),
          const SizedBox(width: DimensionsApplication.espacementMoyen),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  FormatageDate.dateHeure(ordonnance.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: CouleursApplication.texteSecondaire,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$nbMedicaments médicament${nbMedicaments > 1 ? 's' : ''}',
                  style: textTheme.bodySmall?.copyWith(
                    color: CouleursApplication.primaire,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: CouleursApplication.texteTertiaire),
        ],
      ),
    );
  }
}
