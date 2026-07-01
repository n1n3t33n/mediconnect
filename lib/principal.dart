import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/constantes_application.dart';
import 'config/theme_application.dart';
import 'ecrans/accueil/portail_authentification.dart';
import 'fournisseurs/fournisseur_authentification.dart';

/// Point d'entrée de l'application MediConnect.
///
/// Étape 3 — Authentification : le fournisseur d'authentification est branché
/// à la racine, et l'aiguillage (onboarding / accueil connecté) est géré par
/// [PortailAuthentification].
void main() {
  runApp(const ApplicationMediConnect());
}

/// Racine de l'application MediConnect.
class ApplicationMediConnect extends StatelessWidget {
  const ApplicationMediConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FournisseurAuthentification(),
      child: MaterialApp(
        title: ConstantesApplication.nomApplication,
        debugShowCheckedModeBanner: false,
        theme: ThemeApplication.clair,
        home: const PortailAuthentification(),
      ),
    );
  }
}
