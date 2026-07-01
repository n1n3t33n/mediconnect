import 'package:flutter/material.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../modeles/modele_demande_consultation.dart';
import '../../utilitaires/formatage_date.dart';

/// Confirmation après création d'une demande de consultation.
class EcranConfirmationDemande extends StatelessWidget {
  const EcranConfirmationDemande({
    super.key,
    required this.demande,
    required this.miseEnFileAttente,
  });

  final DemandeConsultation demande;

  /// Vrai si la mise en relation immédiate a été placée en file d'attente
  /// (aucun médecin libre à l'instant).
  final bool miseEnFileAttente;

  String get _message {
    if (demande.type == TypeMiseEnRelation.creneau) {
      final quand = demande.creneau == null
          ? ''
          : ' pour le ${FormatageDate.creneau(demande.creneau!)}';
      return 'Votre rendez-vous avec ${demande.medecinNom} est réservé$quand.';
    }
    if (miseEnFileAttente) {
      return 'Aucun médecin n\'est libre à l\'instant. Vous êtes placé(e) en '
          'file d\'attente : ${demande.medecinNom} vous répondra dès que '
          'possible.';
    }
    return 'Votre demande a été envoyée à ${demande.medecinNom}. Le médecin va '
        'vous prendre en charge.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final couleur = miseEnFileAttente
        ? CouleursApplication.avertissement
        : CouleursApplication.succes;
    final icone = miseEnFileAttente
        ? Icons.hourglass_top_outlined
        : Icons.check_circle_outline;

    return Scaffold(
      appBar: AppBar(title: const Text('Demande envoyée')),
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
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  Icon(icone, size: 88, color: couleur),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  Text(
                    demande.type.libelle,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementPetit),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: CouleursApplication.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  if (demande.resumeAutoDiagnostic != null) ...[
                    CarteApplication(
                      enfant: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.assignment_turned_in_outlined,
                              color: CouleursApplication.primaire),
                          SizedBox(width: DimensionsApplication.espacementPetit),
                          Expanded(
                            child: Text(
                              'Votre auto-diagnostic a été joint à la demande '
                              'pour le médecin.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                  ],
                  CarteApplication(
                    enfant: Row(
                      children: const [
                        Icon(Icons.videocam_outlined,
                            color: CouleursApplication.accent),
                        SizedBox(width: DimensionsApplication.espacementPetit),
                        Expanded(
                          child: Text(
                            'La téléconsultation sera disponible à l\'étape '
                            'suivante.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonPrincipal(
                    libelle: 'Terminer',
                    icone: Icons.check,
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
}
