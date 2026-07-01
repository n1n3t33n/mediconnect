// Test de fumée de l'aiguillage initial (Étape 3).
//
// Vérifie que, sans session enregistrée, l'application affiche bien l'onboarding
// après le chargement de session. Le fournisseur d'authentification s'appuie sur
// SharedPreferences : on installe donc des valeurs simulées avant le test.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediconnect/principal.dart';

void main() {
  testWidgets('Sans session, l\'onboarding s\'affiche après chargement',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ApplicationMediConnect());
    // Laisse le chargement asynchrone de la session se terminer.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Bienvenue sur MediConnect'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });
}
