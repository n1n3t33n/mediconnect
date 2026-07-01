import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../modeles/modele_utilisateur.dart';

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
                  CarteApplication(
                    enfant: Row(
                      children: const [
                        Icon(Icons.construction_outlined,
                            color: CouleursApplication.accent),
                        SizedBox(width: DimensionsApplication.espacementPetit),
                        Expanded(
                          child: Text(
                            'Les fonctionnalités (auto-diagnostic, recherche de '
                            'médecin, téléconsultation…) arrivent dans les '
                            'prochaines étapes.',
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
