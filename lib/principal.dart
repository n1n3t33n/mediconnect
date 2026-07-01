import 'package:flutter/material.dart';

import 'config/constantes_application.dart';
import 'config/theme_application.dart';
import 'ecrans/accueil/ecran_onboarding.dart';

/// Point d'entrée de l'application MediConnect.
///
/// Étape 2 — Onboarding animé : l'application démarre sur l'écran d'accueil
/// animé (Rive). L'authentification sera branchée à l'Étape 3.
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
      home: const EcranOnboarding(),
    );
  }
}
