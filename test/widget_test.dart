// Test de fumée minimal pour l'Étape 0.
//
// Vérifie que l'application démarre et affiche l'écran de démarrage provisoire
// MediConnect. Les tests des parcours patient/médecin seront ajoutés aux étapes
// fonctionnelles correspondantes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediconnect/principal.dart';

void main() {
  testWidgets('L\'écran de démarrage affiche le nom MediConnect',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ApplicationMediConnect());

    expect(find.text('MediConnect'), findsOneWidget);
    expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
  });
}
