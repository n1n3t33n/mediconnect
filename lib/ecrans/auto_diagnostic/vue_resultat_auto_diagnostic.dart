import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/constantes_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_auto_diagnostic.dart';
import '../../modeles/modele_auto_diagnostic.dart';

/// Résultat de l'auto-diagnostic : orientation indicative, alerte de criticité,
/// recommandations, contact d'urgence si nécessaire et avertissement.
class VueResultatAutoDiagnostic extends StatelessWidget {
  const VueResultatAutoDiagnostic({super.key});

  @override
  Widget build(BuildContext context) {
    final fournisseur = context.watch<FournisseurAutoDiagnostic>();
    final resultat = fournisseur.resultat;
    if (resultat == null) return const SizedBox.shrink();

    final afficherUrgence =
        resultat.niveau.estUrgence || resultat.symptomeCritiquePresent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DimensionsApplication.largeurMaxContenu,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _banniereOrientation(context, resultat),
              const SizedBox(height: DimensionsApplication.espacementMoyen),
              if (afficherUrgence) ...[
                _contactUrgence(context),
                const SizedBox(height: DimensionsApplication.espacementMoyen),
              ],
              _recommandations(context, resultat),
              if (resultat.symptomesSignales.isNotEmpty) ...[
                const SizedBox(height: DimensionsApplication.espacementMoyen),
                _symptomesSignales(context, resultat),
              ],
              const SizedBox(height: DimensionsApplication.espacementMoyen),
              _avertissement(),
              const SizedBox(height: DimensionsApplication.espacementGrand),
              BoutonPrincipal(
                libelle: 'Consulter un médecin',
                icone: Icons.video_call_outlined,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Recherche de médecin disponible à l\'étape suivante.',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DimensionsApplication.espacementPetit),
              BoutonSecondaire(
                libelle: 'Refaire le questionnaire',
                icone: Icons.refresh,
                onPressed: () =>
                    context.read<FournisseurAutoDiagnostic>().recommencer(),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Terminer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banniereOrientation(
    BuildContext context,
    ResultatAutoDiagnostic resultat,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final couleur = resultat.niveau.couleur;

    return Container(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(DimensionsApplication.rayonGrand),
        border: Border.all(color: couleur.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(resultat.niveau.icone, size: 56, color: couleur),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(
            resultat.niveau.titre,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(
            resultat.niveau.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _contactUrgence(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DimensionsApplication.espacementMoyen),
      decoration: BoxDecoration(
        color: CouleursApplication.dangerClair,
        borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
        border: Border.all(color: CouleursApplication.danger),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emergency_outlined, color: CouleursApplication.danger),
              SizedBox(width: DimensionsApplication.espacementPetit),
              Text(
                'Contacts d\'urgence',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CouleursApplication.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          const Text('SAMU : 185   ·   Pompiers : 180   ·   Police : 111'),
          const SizedBox(height: DimensionsApplication.espacementTresPetit),
          const Text(
            'En cas de signe grave, rendez-vous sans attendre au service '
            'd\'urgence le plus proche.',
          ),
        ],
      ),
    );
  }

  Widget _recommandations(
    BuildContext context,
    ResultatAutoDiagnostic resultat,
  ) {
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommandations',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          for (final recommandation in resultat.recommandations)
            Padding(
              padding: const EdgeInsets.only(
                bottom: DimensionsApplication.espacementTresPetit,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, size: 18,
                      color: CouleursApplication.primaire),
                  const SizedBox(width: DimensionsApplication.espacementPetit),
                  Expanded(child: Text(recommandation)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _symptomesSignales(
    BuildContext context,
    ResultatAutoDiagnostic resultat,
  ) {
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptômes signalés',
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
              for (final symptome in resultat.symptomesSignales)
                Chip(
                  label: Text(symptome),
                  backgroundColor: CouleursApplication.primaireClair,
                  side: BorderSide.none,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avertissement() {
    return CarteApplication(
      enfant: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: CouleursApplication.avertissement),
          SizedBox(width: DimensionsApplication.espacementPetit),
          Expanded(
            child: Text(ConstantesApplication.avertissementAutoDiagnostic),
          ),
        ],
      ),
    );
  }
}
