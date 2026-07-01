import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';
import '../modeles/modele_medecin.dart';
import '../utilitaires/formatage_date.dart';
import 'carte_application.dart';
import 'note_etoiles.dart';

/// Carte présentant un médecin dans la liste de recherche : identité,
/// spécialité, établissement, note et disponibilité.
class CarteMedecin extends StatelessWidget {
  const CarteMedecin({super.key, required this.medecin, required this.onTap});

  final MedecinDisponible medecin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CarteApplication(
      onTap: onTap,
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              const SizedBox(width: DimensionsApplication.espacementMoyen),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medecin.nom,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      medecin.specialite,
                      style: textTheme.bodyMedium?.copyWith(
                        color: CouleursApplication.primaire,
                      ),
                    ),
                    const SizedBox(
                        height: DimensionsApplication.espacementTresPetit),
                    Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined,
                            size: 15, color: CouleursApplication.texteTertiaire),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${medecin.etablissement} · ${medecin.ville}',
                            style: textTheme.bodySmall?.copyWith(
                              color: CouleursApplication.texteSecondaire,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          Row(
            children: [
              NoteEtoiles(note: medecin.note, nombreAvis: medecin.nombreAvis),
              const Spacer(),
              _badgeDisponibilite(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: CouleursApplication.primaireClair,
        shape: BoxShape.circle,
      ),
      child: Text(
        medecin.initiales,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: CouleursApplication.primaireFonce,
        ),
      ),
    );
  }

  Widget _badgeDisponibilite() {
    if (medecin.disponibleImmediatement) {
      return _puce(
        'Disponible maintenant',
        CouleursApplication.succes,
        Icons.circle,
      );
    }
    final prochain = medecin.prochainCreneau;
    return _puce(
      prochain == null
          ? 'Sur rendez-vous'
          : 'Dès ${FormatageDate.creneau(prochain)}',
      CouleursApplication.texteSecondaire,
      Icons.schedule,
    );
  }

  Widget _puce(String texte, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DimensionsApplication.rayonComplet),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 10, color: couleur),
          const SizedBox(width: 6),
          Text(
            texte,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}
