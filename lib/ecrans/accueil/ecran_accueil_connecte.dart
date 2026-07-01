import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../fournisseurs/fournisseur_auto_diagnostic.dart';
import '../../modeles/modele_utilisateur.dart';
import '../auto_diagnostic/ecran_auto_diagnostic.dart';
import '../recherche_medecin/ecran_recherche_medecin.dart';

/// Écran d'accueil affiché après connexion.
///
/// Étape 3 : présente le profil de l'utilisateur connecté et permet la
/// déconnexion. Les tableaux de bord par rôle (patient, médecin, admin) seront
/// développés aux étapes suivantes.
class EcranAccueilConnecte extends StatelessWidget {
  const EcranAccueilConnecte({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();
    final utilisateur = auth.utilisateurCourant;
    final textTheme = Theme.of(context).textTheme;

    if (utilisateur == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<FournisseurAuthentification>().deconnexion(),
          ),
        ],
      ),
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
                  Text(
                    'Bonjour ${utilisateur.nom}',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementTresPetit),
                  Text(
                    'Vous êtes connecté en tant que ${utilisateur.role.libelle.toLowerCase()}.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: CouleursApplication.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  _carteProfil(context, utilisateur),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  if (utilisateur.estPatient) ...[
                    _carteAction(
                      context,
                      titre: 'Faire un auto-diagnostic',
                      description:
                          'Évaluez vos symptômes et obtenez une orientation.',
                      icone: Icons.fact_check_outlined,
                      couleur: CouleursApplication.primaire,
                      onTap: () => _ouvrirAutoDiagnostic(context),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    _carteAction(
                      context,
                      titre: 'Rechercher un médecin',
                      description:
                          'Filtrez par spécialité, établissement ou disponibilité.',
                      icone: Icons.search,
                      couleur: CouleursApplication.succes,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EcranRechercheMedecin(),
                        ),
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                  ],
                  CarteApplication(
                    enfant: Row(
                      children: const [
                        Icon(Icons.construction_outlined,
                            color: CouleursApplication.accent),
                        SizedBox(width: DimensionsApplication.espacementPetit),
                        Expanded(
                          child: Text(
                            'D\'autres fonctionnalités (recherche de médecin, '
                            'téléconsultation…) arrivent dans les prochaines '
                            'étapes.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonSecondaire(
                    libelle: 'Se déconnecter',
                    icone: Icons.logout,
                    onPressed: () =>
                        context.read<FournisseurAuthentification>().deconnexion(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _ouvrirAutoDiagnostic(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FournisseurAutoDiagnostic(),
          child: const EcranAutoDiagnostic(),
        ),
      ),
    );
  }

  Widget _carteAction(
    BuildContext context, {
    required String titre,
    required String description,
    required IconData icone,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      onTap: onTap,
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
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                    height: DimensionsApplication.espacementTresPetit),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: CouleursApplication.texteSecondaire,
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

  Widget _carteProfil(BuildContext context, Utilisateur utilisateur) {
    final lignes = <Widget>[
      _ligne(Icons.phone_outlined, 'Téléphone', utilisateur.telephone),
      _ligne(Icons.badge_outlined, 'Rôle', utilisateur.role.libelle),
    ];

    if (utilisateur.estPatient) {
      lignes.add(_ligne(
        Icons.location_city_outlined,
        'Ville',
        utilisateur.ville ?? '—',
      ));
    }

    if (utilisateur.estMedecin) {
      lignes
        ..add(_ligne(Icons.medical_services_outlined, 'Spécialité',
            utilisateur.specialite ?? '—'))
        ..add(_ligne(Icons.local_hospital_outlined, 'Établissement',
            utilisateur.etablissement ?? '—'))
        ..add(_ligne(
          Icons.verified_outlined,
          'Statut',
          utilisateur.statutValidation?.libelle ?? '—',
        ));
    }

    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lignes.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: DimensionsApplication.espacementPetit,
                ),
                child: Divider(height: 1),
              ),
            lignes[i],
          ],
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String libelle, String valeur) {
    return Row(
      children: [
        Icon(icone, size: 20, color: CouleursApplication.primaire),
        const SizedBox(width: DimensionsApplication.espacementMoyen),
        Text(
          '$libelle : ',
          style: const TextStyle(color: CouleursApplication.texteSecondaire),
        ),
        Expanded(
          child: Text(valeur, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
