import 'package:flutter/material.dart';

import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../modeles/modele_consultation.dart';
import '../../utilitaires/formatage_date.dart';

/// Détail d'une consultation : participants, synthèse du médecin, pré-diagnostic
/// et (à venir) ordonnance.
class EcranDetailConsultation extends StatelessWidget {
  const EcranDetailConsultation({super.key, required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final dureeMin = (consultation.dureeSecondes / 60).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DimensionsApplication.largeurMaxContenu,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CarteApplication(
                    enfant: Column(
                      children: [
                        _ligne(Icons.person_outline, 'Patient',
                            consultation.patientNom),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.medical_services_outlined, 'Médecin',
                            '${consultation.medecinNom} · ${consultation.specialite}'),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.event_outlined, 'Date',
                            FormatageDate.dateHeure(consultation.date)),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.timer_outlined, 'Durée',
                            '$dureeMin min · ${consultation.type.libelle}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _bloc(
                    context,
                    titre: 'Synthèse du médecin',
                    icone: Icons.notes_outlined,
                    contenu: consultation.aSynthese
                        ? consultation.synthese!
                        : 'Synthèse en attente du médecin.',
                  ),
                  if (consultation.resumeAutoDiagnostic != null) ...[
                    const SizedBox(
                        height: DimensionsApplication.espacementMoyen),
                    _bloc(
                      context,
                      titre: 'Pré-diagnostic transmis',
                      icone: Icons.assignment_outlined,
                      contenu: consultation.resumeAutoDiagnostic!,
                    ),
                  ],
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _bloc(
                    context,
                    titre: 'Ordonnance',
                    icone: Icons.receipt_long_outlined,
                    contenu:
                        'La génération et la réception d\'ordonnance arrivent à '
                        'l\'étape suivante.',
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonSecondaire(
                    libelle: 'Retour à l\'accueil',
                    icone: Icons.home_outlined,
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bloc(
    BuildContext context, {
    required String titre,
    required IconData icone,
    required String contenu,
  }) {
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: CouleursApplication.primaire),
              const SizedBox(width: DimensionsApplication.espacementPetit),
              Text(
                titre,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(contenu),
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String libelle, String valeur) {
    return Row(
      children: [
        Icon(icone, size: 20, color: CouleursApplication.primaire),
        const SizedBox(width: DimensionsApplication.espacementMoyen),
        Text('$libelle : ',
            style: const TextStyle(color: CouleursApplication.texteSecondaire)),
        Expanded(
          child: Text(valeur,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
