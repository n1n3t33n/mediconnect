// Tests unitaires du service d'authentification simulé (Étape 3).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediconnect/modeles/modele_utilisateur.dart';
import 'package:mediconnect/services/service_authentification.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Connexion réussie avec le compte médecin de démonstration (validé)',
      () async {
    final service = ServiceAuthentification();
    final utilisateur =
        await service.connexionMotDePasse('0700000001', 'medecin123');

    expect(utilisateur.role, RoleUtilisateur.medecin);
    expect(utilisateur.estActif, isTrue);
  });

  test('Un mot de passe incorrect lève une ExceptionAuthentification', () async {
    final service = ServiceAuthentification();

    expect(
      () => service.connexionMotDePasse('0700000002', 'mauvais'),
      throwsA(isA<ExceptionAuthentification>()),
    );
  });

  test('Inscription patient : SMS vérifié, création puis connexion persistante',
      () async {
    final service = ServiceAuthentification();
    const telephone = '0700001234';

    final code = await service.envoyerCodeSms(telephone);
    expect(service.verifierCodeSms(telephone, code), isTrue);

    final patient = await service.inscrirePatient(
      nom: 'Test Patient',
      telephone: telephone,
      motDePasse: 'motdepasse',
      ville: 'Bouaké',
    );
    expect(patient.estPatient, isTrue);

    // Un nouveau service relit le même stockage : la connexion doit réussir.
    final autreService = ServiceAuthentification();
    final reconnecte =
        await autreService.connexionMotDePasse(telephone, 'motdepasse');
    expect(reconnecte.nom, 'Test Patient');
  });

  test('Un médecin nouvellement inscrit ne peut pas se connecter (en attente)',
      () async {
    final service = ServiceAuthentification();
    await service.inscrireMedecin(
      nom: 'Dr Test',
      telephone: '0700009999',
      motDePasse: 'motdepasse',
      specialite: 'Cardiologie',
      numeroOrdre: 'CI-999',
      etablissement: 'Clinique du Plateau',
    );

    expect(
      () => service.connexionMotDePasse('0700009999', 'motdepasse'),
      throwsA(isA<ExceptionAuthentification>()),
    );
  });
}
