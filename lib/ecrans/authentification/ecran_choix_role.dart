import 'package:flutter/material.dart';

import '../../composants/carte_application.dart';
import '../../composants/entete_authentification.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import 'ecran_inscription_medecin.dart';
import 'ecran_inscription_patient.dart';

/// Choix du type de compte à créer : patient ou médecin.
class EcranChoixRole extends StatelessWidget {
  const EcranChoixRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
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
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  const EnteteAuthentification(
                    titre: 'Qui êtes-vous ?',
                    sousTitre: 'Choisissez le type de compte à créer.',
                    icone: Icons.group_outlined,
                  ),
                  const SizedBox(height: DimensionsApplication.espacementTresGrand),
                  _carteRole(
                    context,
                    titre: 'Patient',
                    description:
                        'Réaliser un auto-diagnostic, consulter un médecin et '
                        'recevoir une ordonnance.',
                    icone: Icons.personal_injury_outlined,
                    couleur: CouleursApplication.primaire,
                    destination: const EcranInscriptionPatient(),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _carteRole(
                    context,
                    titre: 'Médecin',
                    description:
                        'Recevoir des demandes, mener des téléconsultations et '
                        'émettre des ordonnances.',
                    icone: Icons.medical_information_outlined,
                    couleur: CouleursApplication.succes,
                    destination: const EcranInscriptionMedecin(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _carteRole(
    BuildContext context, {
    required String titre,
    required String description,
    required IconData icone,
    required Color couleur,
    required Widget destination,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => destination),
      ),
      enfant: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: couleur),
          ),
          const SizedBox(width: DimensionsApplication.espacementMoyen),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DimensionsApplication.espacementTresPetit),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: CouleursApplication.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: CouleursApplication.texteTertiaire),
        ],
      ),
    );
  }
}
