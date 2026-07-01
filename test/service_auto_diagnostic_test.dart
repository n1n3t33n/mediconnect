// Tests unitaires de l'évaluation d'auto-diagnostic (Étape 4).

import 'package:flutter_test/flutter_test.dart';

import 'package:mediconnect/modeles/modele_auto_diagnostic.dart';
import 'package:mediconnect/services/service_auto_diagnostic.dart';

void main() {
  final service = ServiceAutoDiagnostic();

  test('Symptômes bénins → orientation « à surveiller » (faible)', () {
    final resultat = service.evaluer({
      'zone': 'general',
      'symptomes_general': ['fatigue'],
      'duree': 'j1_3',
      'intensite': 1,
      'antecedents': ['aucun'],
    });

    expect(resultat.niveau, NiveauCriticite.faible);
    expect(resultat.symptomeCritiquePresent, isFalse);
  });

  test('Douleur thoracique + essoufflement + signe d\'alerte → urgence', () {
    final resultat = service.evaluer({
      'zone': 'poitrine',
      'symptomes_poitrine': ['douleur_thoracique', 'essoufflement'],
      'duree': 'moins_24h',
      'intensite': 5,
      'signes_alerte': ['respire_repos'],
      'antecedents': ['cardiaque'],
    });

    expect(resultat.niveau, NiveauCriticite.urgence);
    expect(resultat.symptomeCritiquePresent, isTrue);
  });

  test('Un symptôme critique isolé déclenche au moins une consultation rapide',
      () {
    final resultat = service.evaluer({
      'zone': 'poitrine',
      'symptomes_poitrine': ['douleur_thoracique'],
      'duree': 'moins_24h',
      'intensite': 2,
    });

    expect(resultat.niveau, NiveauCriticite.eleve);
    expect(resultat.symptomeCritiquePresent, isTrue);
  });
}
