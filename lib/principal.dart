import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/constantes_application.dart';
import 'config/theme_application.dart';
import 'ecrans/accueil/portail_authentification.dart';
import 'fournisseurs/fournisseur_authentification.dart';
import 'fournisseurs/fournisseur_consultations.dart';

/// Point d'entrée de l'application MediConnect.
///
/// Les fournisseurs globaux (authentification, demandes de consultation) sont
/// branchés à la racine ; l'aiguillage (onboarding / accueil connecté) est géré
/// par [PortailAuthentification].
void main() {
  runApp(const ApplicationMediConnect());
}

/// Racine de l'application MediConnect.
class ApplicationMediConnect extends StatelessWidget {
  const ApplicationMediConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FournisseurAuthentification()),
        ChangeNotifierProvider(create: (_) => FournisseurConsultations()),
      ],
      child: MaterialApp(
        title: ConstantesApplication.nomApplication,
        debugShowCheckedModeBanner: false,
        theme: ThemeApplication.clair,
        home: const PortailAuthentification(),
      ),
    );
  }
}
