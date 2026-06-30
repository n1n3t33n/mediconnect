import 'package:flutter/material.dart';

/// Point d'entrée de l'application MediConnect.
///
/// À ce stade (Étape 0 — Initialisation), l'application n'affiche qu'un écran
/// de démarrage provisoire. Le thème complet est mis en place à l'Étape 1 et
/// l'onboarding animé à l'Étape 2.
void main() {
  runApp(const ApplicationMediConnect());
}

/// Racine de l'application MediConnect.
class ApplicationMediConnect extends StatelessWidget {
  const ApplicationMediConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B8FAC)),
        useMaterial3: true,
      ),
      home: const EcranDemarrage(),
    );
  }
}

/// Écran de démarrage provisoire affiché tant que les écrans réels
/// (onboarding, authentification…) ne sont pas développés.
class EcranDemarrage extends StatelessWidget {
  const EcranDemarrage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.health_and_safety, size: 96, color: Color(0xFF0B8FAC)),
            SizedBox(height: 16),
            Text(
              'MediConnect',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Santé connectée — Côte d\'Ivoire',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
