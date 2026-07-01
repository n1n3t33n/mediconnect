// Test de fumée de l'onboarding (Étape 2).
//
// Vérifie que l'application démarre sur l'écran d'accueil animé et affiche la
// première page d'onboarding ainsi que le bouton de progression.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediconnect/principal.dart';

void main() {
  testWidgets('L\'onboarding affiche la première page et le bouton Suivant',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ApplicationMediConnect());
    await tester.pump();

    expect(find.text('Bienvenue sur MediConnect'), findsOneWidget);
    expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });
}
