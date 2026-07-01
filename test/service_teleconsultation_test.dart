// Tests unitaires du service de téléconsultation / historique (Étape 6).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediconnect/modeles/modele_consultation.dart';
import 'package:mediconnect/services/service_teleconsultation.dart';

Consultation _consultation(String id) => Consultation(
      id: id,
      patientId: 'p1',
      patientNom: 'Aya Kouamé',
      medecinId: 'm1',
      medecinNom: 'Dr. Koffi',
      specialite: 'Médecine générale',
      statut: StatutConsultation.enCours,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Créer, terminer avec synthèse, puis retrouver dans l\'historique',
      () async {
    final service = ServiceTeleconsultation();
    await service.creerConsultation(_consultation('c1'));

    final maj = await service.terminerConsultation(
      'c1',
      dureeSecondes: 120,
      synthese: 'Rien à signaler, repos conseillé.',
    );

    expect(maj, isNotNull);
    expect(maj!.statut, StatutConsultation.terminee);
    expect(maj.aSynthese, isTrue);

    final historique = await service.historiquePatient('p1');
    expect(historique.length, 1);
    expect(historique.first.dureeSecondes, 120);
  });

  test('enregistrerSynthese met à jour la synthèse et clôt la consultation',
      () async {
    final service = ServiceTeleconsultation();
    await service.creerConsultation(_consultation('c2'));

    final maj = await service.enregistrerSynthese('c2', 'Repos conseillé.');

    expect(maj, isNotNull);
    expect(maj!.synthese, 'Repos conseillé.');
    expect(maj.statut, StatutConsultation.terminee);
  });
}
