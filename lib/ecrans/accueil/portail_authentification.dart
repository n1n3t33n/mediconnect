import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constantes_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import 'ecran_accueil_connecte.dart';
import 'ecran_onboarding.dart';

/// Aiguillage racine selon l'état d'authentification :
/// - chargement de la session → écran de démarrage ;
/// - non connecté → onboarding ;
/// - connecté → accueil connecté.
class PortailAuthentification extends StatelessWidget {
  const PortailAuthentification({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();

    if (!auth.initialise) return const _EcranDemarrage();
    return auth.estConnecte
        ? const EcranAccueilConnecte()
        : const EcranOnboarding();
  }
}

/// Écran de démarrage statique affiché pendant le chargement de la session.
class _EcranDemarrage extends StatelessWidget {
  const _EcranDemarrage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 88,
              color: CouleursApplication.primaire,
            ),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            Text(
              ConstantesApplication.nomApplication,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CouleursApplication.primaireFonce,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
