// Tests unitaires du service de recherche de médecins (Étape 5).

import 'package:flutter_test/flutter_test.dart';

import 'package:mediconnect/services/service_medecins.dart';

void main() {
  final service = ServiceMedecins();

  test('La liste propose plusieurs médecins et spécialités', () {
    expect(service.tousLesMedecins().length, greaterThan(3));
    expect(service.specialites(), contains('Médecine générale'));
  });

  test('Filtrage par spécialité', () {
    final resultats = service.filtrer(specialite: 'Cardiologie');
    expect(resultats, isNotEmpty);
    expect(resultats.every((m) => m.specialite == 'Cardiologie'), isTrue);
  });

  test('Filtrage par disponibilité immédiate', () {
    final resultats = service.filtrer(disponibleSeulement: true);
    expect(resultats, isNotEmpty);
    expect(resultats.every((m) => m.disponibleImmediatement), isTrue);
  });

  test('Filtrage combiné spécialité + établissement', () {
    final resultats = service.filtrer(
      specialite: 'Médecine générale',
      etablissement: 'CHU de Cocody',
    );
    expect(
      resultats.every((m) =>
          m.specialite == 'Médecine générale' &&
          m.etablissement == 'CHU de Cocody'),
      isTrue,
    );
  });
}
