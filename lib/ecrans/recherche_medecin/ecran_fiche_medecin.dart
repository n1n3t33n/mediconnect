import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../composants/note_etoiles.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../fournisseurs/fournisseur_consultations.dart';
import '../../modeles/modele_demande_consultation.dart';
import '../../modeles/modele_medecin.dart';
import '../../utilitaires/formatage_date.dart';
import 'ecran_confirmation_demande.dart';

/// Fiche détaillée d'un médecin avec les deux modes de mise en relation :
/// immédiate (file d'attente si le médecin n'est pas libre) ou créneau réservé.
class EcranFicheMedecin extends StatelessWidget {
  const EcranFicheMedecin({
    super.key,
    required this.medecin,
    this.resumeAutoDiagnostic,
  });

  final MedecinDisponible medecin;
  final String? resumeAutoDiagnostic;

  Future<void> _creerDemande(
    BuildContext context, {
    required TypeMiseEnRelation type,
    DateTime? creneau,
  }) async {
    final patient = context.read<FournisseurAuthentification>().utilisateurCourant;
    if (patient == null) return;

    final demande =
        await context.read<FournisseurConsultations>().creerDemande(
              medecin: medecin,
              patient: patient,
              type: type,
              creneau: creneau,
              resumeAutoDiagnostic: resumeAutoDiagnostic,
            );
    if (!context.mounted || demande == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EcranConfirmationDemande(
          demande: demande,
          miseEnFileAttente:
              type == TypeMiseEnRelation.immediate && !medecin.disponibleImmediatement,
        ),
      ),
    );
  }

  Future<void> _reserverCreneau(BuildContext context) async {
    final creneau = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (_) => _FeuilleCreneaux(medecin: medecin),
    );
    if (creneau != null && context.mounted) {
      await _creerDemande(context,
          type: TypeMiseEnRelation.creneau, creneau: creneau);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enChargement = context.watch<FournisseurConsultations>().enChargement;

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche médecin')),
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
                  _entete(context),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  _informations(context),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _creneaux(context),
                  if (resumeAutoDiagnostic != null) ...[
                    const SizedBox(
                        height: DimensionsApplication.espacementMoyen),
                    _resume(),
                  ],
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonPrincipal(
                    libelle: 'Mise en relation immédiate',
                    icone: Icons.bolt,
                    enChargement: enChargement,
                    onPressed: () => _creerDemande(
                      context,
                      type: TypeMiseEnRelation.immediate,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementPetit),
                  BoutonSecondaire(
                    libelle: 'Réserver un créneau',
                    icone: Icons.event_available_outlined,
                    onPressed:
                        enChargement ? null : () => _reserverCreneau(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _entete(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: CouleursApplication.primaireClair,
            shape: BoxShape.circle,
          ),
          child: Text(
            medecin.initiales,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: CouleursApplication.primaireFonce,
            ),
          ),
        ),
        const SizedBox(height: DimensionsApplication.espacementMoyen),
        Text(
          medecin.nom,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          medecin.specialite,
          style: textTheme.titleMedium?.copyWith(
            color: CouleursApplication.primaire,
          ),
        ),
        const SizedBox(height: DimensionsApplication.espacementPetit),
        NoteEtoiles(note: medecin.note, nombreAvis: medecin.nombreAvis),
      ],
    );
  }

  Widget _informations(BuildContext context) {
    return CarteApplication(
      enfant: Column(
        children: [
          _ligne(Icons.local_hospital_outlined, 'Établissement',
              medecin.etablissement),
          const Divider(height: DimensionsApplication.espacementGrand),
          _ligne(Icons.location_city_outlined, 'Ville', medecin.ville),
          const Divider(height: DimensionsApplication.espacementGrand),
          _ligne(
            medecin.disponibleImmediatement
                ? Icons.check_circle_outline
                : Icons.schedule,
            'Disponibilité',
            medecin.disponibleImmediatement
                ? 'Disponible maintenant'
                : 'Sur rendez-vous',
          ),
        ],
      ),
    );
  }

  Widget _creneaux(BuildContext context) {
    if (medecin.creneaux.isEmpty) return const SizedBox.shrink();
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochains créneaux',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Wrap(
            spacing: DimensionsApplication.espacementPetit,
            runSpacing: DimensionsApplication.espacementPetit,
            children: [
              for (final creneau in medecin.creneaux)
                Chip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text(FormatageDate.creneau(creneau)),
                  backgroundColor: CouleursApplication.fond,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resume() {
    return CarteApplication(
      enfant: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.assignment_turned_in_outlined,
              color: CouleursApplication.primaire),
          SizedBox(width: DimensionsApplication.espacementPetit),
          Expanded(
            child: Text(
              'Votre auto-diagnostic sera partagé avec ce médecin avant la '
              'consultation.',
            ),
          ),
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

/// Feuille modale de sélection d'un créneau.
class _FeuilleCreneaux extends StatelessWidget {
  const _FeuilleCreneaux({required this.medecin});

  final MedecinDisponible medecin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choisir un créneau',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            for (final creneau in medecin.creneaux)
              ListTile(
                leading: const Icon(Icons.event_available_outlined,
                    color: CouleursApplication.primaire),
                title: Text(FormatageDate.creneau(creneau)),
                onTap: () => Navigator.of(context).pop(creneau),
              ),
          ],
        ),
      ),
    );
  }
}
