import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/carte_application.dart';
import '../../composants/carte_medecin.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_recherche_medecin.dart';
import 'ecran_fiche_medecin.dart';

/// Recherche et mise en relation avec un médecin (cf. cahier 4.3).
///
/// Liste filtrable par spécialité, établissement et disponibilité immédiate.
class EcranRechercheMedecin extends StatelessWidget {
  const EcranRechercheMedecin({super.key, this.resumeAutoDiagnostic});

  /// Résumé d'auto-diagnostic à transmettre au médecin (si le parcours vient
  /// de l'auto-diagnostic).
  final String? resumeAutoDiagnostic;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FournisseurRechercheMedecin(),
      child: _ContenuRecherche(resumeAutoDiagnostic: resumeAutoDiagnostic),
    );
  }
}

class _ContenuRecherche extends StatelessWidget {
  const _ContenuRecherche({this.resumeAutoDiagnostic});

  final String? resumeAutoDiagnostic;

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FournisseurRechercheMedecin>();

    return Scaffold(
      appBar: AppBar(title: const Text('Trouver un médecin')),
      body: SafeArea(
        child: Column(
          children: [
            _filtres(context, f),
            if (resumeAutoDiagnostic != null) _bandeauAutoDiagnostic(),
            Expanded(
              child: f.resultats.isEmpty
                  ? _aucunResultat(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(
                        DimensionsApplication.espacementGrand,
                      ),
                      itemCount: f.resultats.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: DimensionsApplication.espacementMoyen,
                      ),
                      itemBuilder: (context, i) {
                        final medecin = f.resultats[i];
                        return CarteMedecin(
                          medecin: medecin,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EcranFicheMedecin(
                                medecin: medecin,
                                resumeAutoDiagnostic: resumeAutoDiagnostic,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtres(BuildContext context, FournisseurRechercheMedecin f) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DimensionsApplication.espacementGrand,
        DimensionsApplication.espacementMoyen,
        DimensionsApplication.espacementGrand,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _menuDeroulant(
                  libelle: 'Spécialité',
                  valeur: f.specialite,
                  options: f.specialitesDisponibles,
                  onChange: f.definirSpecialite,
                ),
              ),
              const SizedBox(width: DimensionsApplication.espacementMoyen),
              Expanded(
                child: _menuDeroulant(
                  libelle: 'Établissement',
                  valeur: f.etablissement,
                  options: f.etablissementsDisponibles,
                  onChange: f.definirEtablissement,
                ),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Row(
            children: [
              FilterChip(
                label: const Text('Disponible maintenant'),
                selected: f.disponibleSeulement,
                onSelected: f.definirDisponibleSeulement,
                selectedColor: CouleursApplication.primaireClair,
                checkmarkColor: CouleursApplication.primaireFonce,
              ),
              const Spacer(),
              if (f.filtresActifs)
                TextButton.icon(
                  onPressed: f.reinitialiser,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Réinitialiser'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuDeroulant({
    required String libelle,
    required String? valeur,
    required List<String> options,
    required ValueChanged<String?> onChange,
  }) {
    return DropdownButtonFormField<String?>(
      value: valeur,
      isExpanded: true,
      decoration: InputDecoration(labelText: libelle),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Toutes')),
        for (final option in options)
          DropdownMenuItem<String?>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChange,
    );
  }

  Widget _bandeauAutoDiagnostic() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DimensionsApplication.espacementGrand,
        DimensionsApplication.espacementMoyen,
        DimensionsApplication.espacementGrand,
        0,
      ),
      child: CarteApplication(
        enfant: Row(
          children: const [
            Icon(Icons.assignment_turned_in_outlined,
                color: CouleursApplication.primaire),
            SizedBox(width: DimensionsApplication.espacementPetit),
            Expanded(
              child: Text(
                'Le résultat de votre auto-diagnostic sera transmis au médecin '
                'choisi.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aucunResultat(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off,
                size: 56, color: CouleursApplication.texteTertiaire),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            Text(
              'Aucun médecin ne correspond à vos critères.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CouleursApplication.texteSecondaire,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
