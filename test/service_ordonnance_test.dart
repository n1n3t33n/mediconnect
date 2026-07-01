// Tests unitaires du service d'ordonnances et du générateur PDF (Étape 7).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediconnect/modeles/modele_ordonnance.dart';
import 'package:mediconnect/services/service_ordonnance.dart';
import 'package:mediconnect/utilitaires/generateur_pdf_ordonnance.dart';

Ordonnance _ordonnance({String consultationId = 'c1'}) => Ordonnance.nouvelle(
      consultationId: consultationId,
      patientId: 'p1',
      patientNom: 'Aya Kouamé',
      medecinId: 'm1',
      medecinNom: 'Dr. Koffi',
      specialite: 'Médecine générale',
      numeroOrdre: 'CI-12345',
      etablissement: 'CHU de Cocody',
      remarques: 'Repos et hydratation.',
      medicaments: const [
        LigneMedicament(
          nom: 'Paracétamol 500 mg',
          posologie: '1 comprimé matin et soir',
          duree: '5 jours',
          instructions: 'Pendant les repas',
        ),
        LigneMedicament(
          nom: 'Vitamine C',
          posologie: '1 comprimé par jour',
        ),
      ],
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Créer une ordonnance puis la retrouver par consultation et par patient',
      () async {
    final service = ServiceOrdonnance();
    final creee = await service.creerOrdonnance(_ordonnance());

    final parConsultation =
        await service.ordonnancePourConsultation('c1');
    expect(parConsultation, isNotNull);
    expect(parConsultation!.id, creee.id);
    expect(parConsultation.medicaments.length, 2);

    final parPatient = await service.ordonnancesPatient('p1');
    expect(parPatient.length, 1);

    final parMedecin = await service.ordonnancesMedecin('m1');
    expect(parMedecin.length, 1);
  });

  test('ordonnancePourConsultation renvoie null si aucune ordonnance', () async {
    final service = ServiceOrdonnance();
    expect(await service.ordonnancePourConsultation('inexistante'), isNull);
  });

  test('Chaque ordonnance porte un code de vérification et un lien', () {
    final ordonnance = _ordonnance();
    expect(ordonnance.codeVerification, startsWith('MC-'));
    expect(ordonnance.lienVerification, contains(ordonnance.codeVerification));
  });

  test('Le générateur produit un PDF non vide', () async {
    final octets = await GenerateurPdfOrdonnance.construire(_ordonnance());
    expect(octets, isNotEmpty);
  });
}
