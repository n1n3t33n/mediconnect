import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// Option sélectionnable réutilisable (case à cocher ou bouton radio) pour les
/// questions du questionnaire d'auto-diagnostic.
class OptionSelectionnable extends StatelessWidget {
  const OptionSelectionnable({
    super.key,
    required this.libelle,
    required this.selectionnee,
    required this.multiple,
    required this.onTap,
  });

  final String libelle;
  final bool selectionnee;

  /// `true` : sélection multiple (case à cocher) ; `false` : choix unique (radio).
  final bool multiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(DimensionsApplication.rayonMoyen);
    final icone = multiple
        ? (selectionnee ? Icons.check_box : Icons.check_box_outline_blank)
        : (selectionnee
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked);

    return Padding(
      padding: const EdgeInsets.only(bottom: DimensionsApplication.espacementPetit),
      child: Material(
        color: selectionnee
            ? CouleursApplication.primaireClair
            : CouleursApplication.surface,
        borderRadius: rayon,
        child: InkWell(
          onTap: onTap,
          borderRadius: rayon,
          child: Container(
            padding: const EdgeInsets.all(DimensionsApplication.espacementMoyen),
            decoration: BoxDecoration(
              borderRadius: rayon,
              border: Border.all(
                color: selectionnee
                    ? CouleursApplication.primaire
                    : CouleursApplication.bordure,
                width: selectionnee ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icone,
                  color: selectionnee
                      ? CouleursApplication.primaire
                      : CouleursApplication.texteTertiaire,
                ),
                const SizedBox(width: DimensionsApplication.espacementMoyen),
                Expanded(
                  child: Text(
                    libelle,
                    style: TextStyle(
                      fontWeight:
                          selectionnee ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
