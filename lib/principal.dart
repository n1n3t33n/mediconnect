import 'package:flutter/material.dart';

import 'config/constantes_application.dart';
import 'config/couleurs_application.dart';
import 'config/dimensions_application.dart';
import 'config/theme_application.dart';
import 'composants/bouton_principal.dart';
import 'composants/bouton_secondaire.dart';
import 'composants/carte_application.dart';
import 'composants/champ_texte.dart';

/// Point d'entrée de l'application MediConnect.
///
/// Étape 1 — Design system & thème : l'application applique désormais le thème
/// global et affiche une vitrine des composants réutilisables. L'onboarding
/// animé (Rive) remplacera cet écran à l'Étape 2.
void main() {
  runApp(const ApplicationMediConnect());
}

/// Racine de l'application MediConnect.
class ApplicationMediConnect extends StatelessWidget {
  const ApplicationMediConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ConstantesApplication.nomApplication,
      debugShowCheckedModeBanner: false,
      theme: ThemeApplication.clair,
      home: const EcranVitrineDesign(),
    );
  }
}

/// Écran provisoire présentant l'identité visuelle et les composants de base
/// (design system de l'Étape 1). Sera remplacé par l'onboarding à l'Étape 2.
class EcranVitrineDesign extends StatelessWidget {
  const EcranVitrineDesign({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DimensionsApplication.largeurMaxContenu,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  const Icon(
                    Icons.health_and_safety,
                    size: 88,
                    color: CouleursApplication.primaire,
                  ),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  Text(
                    ConstantesApplication.nomApplication,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CouleursApplication.primaireFonce,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementTresPetit),
                  Text(
                    ConstantesApplication.slogan,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: CouleursApplication.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementTresGrand),
                  CarteApplication(
                    enfant: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Composants de base',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                            height: DimensionsApplication.espacementMoyen),
                        const ChampTexte(
                          libelle: 'Numéro de téléphone',
                          indication: 'Ex. 07 00 00 00 00',
                          icone: Icons.phone_outlined,
                          typeClavier: TextInputType.phone,
                        ),
                        const SizedBox(
                            height: DimensionsApplication.espacementMoyen),
                        BoutonPrincipal(
                          libelle: 'Commencer',
                          icone: Icons.arrow_forward,
                          onPressed: () => _afficherMessage(context),
                        ),
                        const SizedBox(
                            height: DimensionsApplication.espacementPetit),
                        BoutonSecondaire(
                          libelle: 'En savoir plus',
                          onPressed: () => _afficherMessage(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _afficherMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité disponible à une étape ultérieure.')),
    );
  }
}
