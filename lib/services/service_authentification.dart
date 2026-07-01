import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../modeles/modele_utilisateur.dart';

/// Erreur d'authentification portant un message affichable à l'utilisateur.
class ExceptionAuthentification implements Exception {
  ExceptionAuthentification(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Service d'authentification **simulé** de MediConnect.
///
/// Aucun serveur réel : les comptes sont persistés localement via
/// [SharedPreferences] et l'envoi de SMS est simulé (le code est renvoyé pour
/// être affiché à des fins de démonstration). Des comptes de démonstration sont
/// pré-créés au premier lancement pour faciliter les tests et la soutenance.
class ServiceAuthentification {
  static const String _cleUtilisateurs = 'mediconnect_utilisateurs';
  static const String _cleSession = 'mediconnect_session';

  final Map<String, String> _codesSms = {};
  final Random _aleatoire = Random();
  SharedPreferences? _prefsCache;

  Future<SharedPreferences> get _prefs async =>
      _prefsCache ??= await SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // Stockage local des comptes
  // ---------------------------------------------------------------------------

  Future<List<Utilisateur>> _chargerUtilisateurs() async {
    final prefs = await _prefs;
    final brut = prefs.getString(_cleUtilisateurs);
    if (brut == null) {
      final demo = _comptesDemonstration();
      await _sauvegarderUtilisateurs(demo);
      return demo;
    }
    return (jsonDecode(brut) as List)
        .map((e) => Utilisateur.depuisJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _sauvegarderUtilisateurs(List<Utilisateur> utilisateurs) async {
    final prefs = await _prefs;
    await prefs.setString(
      _cleUtilisateurs,
      jsonEncode(utilisateurs.map((u) => u.versJson()).toList()),
    );
  }

  Utilisateur? _trouverParTelephone(
    List<Utilisateur> utilisateurs,
    String telephone,
  ) {
    for (final u in utilisateurs) {
      if (u.telephone == telephone) return u;
    }
    return null;
  }

  /// Comptes pré-créés pour la démonstration.
  List<Utilisateur> _comptesDemonstration() => [
        const Utilisateur(
          id: 'demo-admin',
          role: RoleUtilisateur.administrateur,
          nom: 'Administrateur MediConnect',
          telephone: '0700000000',
          motDePasse: 'admin123',
        ),
        Utilisateur(
          id: 'demo-medecin',
          role: RoleUtilisateur.medecin,
          nom: 'Dr. Koffi',
          telephone: '0700000001',
          motDePasse: 'medecin123',
          specialite: 'Médecine générale',
          numeroOrdre: 'CI-12345',
          etablissement: 'CHU de Cocody',
          statutValidation: StatutValidationMedecin.valide,
        ),
        Utilisateur(
          id: 'demo-patient',
          role: RoleUtilisateur.patient,
          nom: 'Aya Kouamé',
          telephone: '0700000002',
          motDePasse: 'patient123',
          ville: 'Abidjan',
          dateNaissance: DateTime(2002, 5, 14),
        ),
      ];

  // ---------------------------------------------------------------------------
  // Vérification par SMS (simulée)
  // ---------------------------------------------------------------------------

  /// Génère et « envoie » un code à 6 chiffres. Le code est renvoyé afin de
  /// pouvoir être affiché (démonstration sans passerelle SMS réelle).
  Future<String> envoyerCodeSms(String telephone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final code = (100000 + _aleatoire.nextInt(900000)).toString();
    _codesSms[telephone] = code;
    return code;
  }

  bool verifierCodeSms(String telephone, String code) =>
      _codesSms[telephone] == code.trim();

  // ---------------------------------------------------------------------------
  // Inscription
  // ---------------------------------------------------------------------------

  Future<Utilisateur> inscrirePatient({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String ville,
    DateTime? dateNaissance,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final utilisateurs = await _chargerUtilisateurs();
    if (_trouverParTelephone(utilisateurs, telephone) != null) {
      throw ExceptionAuthentification('Ce numéro de téléphone est déjà utilisé.');
    }
    final utilisateur = Utilisateur(
      id: _nouvelId(),
      role: RoleUtilisateur.patient,
      nom: nom,
      telephone: telephone,
      motDePasse: motDePasse,
      ville: ville,
      dateNaissance: dateNaissance,
    );
    utilisateurs.add(utilisateur);
    await _sauvegarderUtilisateurs(utilisateurs);
    await enregistrerSession(utilisateur);
    return utilisateur;
  }

  /// Inscrit un médecin. Le compte est créé « en attente » : il devra être
  /// validé par un administrateur (Étape 9) avant de pouvoir se connecter.
  Future<Utilisateur> inscrireMedecin({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String specialite,
    required String numeroOrdre,
    required String etablissement,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final utilisateurs = await _chargerUtilisateurs();
    if (_trouverParTelephone(utilisateurs, telephone) != null) {
      throw ExceptionAuthentification('Ce numéro de téléphone est déjà utilisé.');
    }
    final utilisateur = Utilisateur(
      id: _nouvelId(),
      role: RoleUtilisateur.medecin,
      nom: nom,
      telephone: telephone,
      motDePasse: motDePasse,
      specialite: specialite,
      numeroOrdre: numeroOrdre,
      etablissement: etablissement,
      statutValidation: StatutValidationMedecin.enAttente,
    );
    utilisateurs.add(utilisateur);
    await _sauvegarderUtilisateurs(utilisateurs);
    // Pas de session : le médecin ne peut pas se connecter tant qu'il n'est
    // pas validé.
    return utilisateur;
  }

  // ---------------------------------------------------------------------------
  // Connexion
  // ---------------------------------------------------------------------------

  Future<Utilisateur> connexionMotDePasse(
    String telephone,
    String motDePasse,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final utilisateurs = await _chargerUtilisateurs();
    final utilisateur = _trouverParTelephone(utilisateurs, telephone);
    if (utilisateur == null) {
      throw ExceptionAuthentification('Aucun compte associé à ce numéro.');
    }
    if (utilisateur.motDePasse != motDePasse) {
      throw ExceptionAuthentification('Mot de passe incorrect.');
    }
    _verifierActivation(utilisateur);
    await enregistrerSession(utilisateur);
    return utilisateur;
  }

  /// Connexion par code SMS : à appeler après [verifierCodeSms].
  Future<Utilisateur> connexionParTelephone(String telephone) async {
    final utilisateurs = await _chargerUtilisateurs();
    final utilisateur = _trouverParTelephone(utilisateurs, telephone);
    if (utilisateur == null) {
      throw ExceptionAuthentification('Aucun compte associé à ce numéro.');
    }
    _verifierActivation(utilisateur);
    await enregistrerSession(utilisateur);
    return utilisateur;
  }

  void _verifierActivation(Utilisateur utilisateur) {
    if (!utilisateur.estActif) {
      throw ExceptionAuthentification(
        'Votre compte médecin est en attente de validation par un administrateur.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Récupération de compte
  // ---------------------------------------------------------------------------

  Future<bool> telephoneExiste(String telephone) async {
    final utilisateurs = await _chargerUtilisateurs();
    return _trouverParTelephone(utilisateurs, telephone) != null;
  }

  Future<void> definirNouveauMotDePasse(
    String telephone,
    String motDePasse,
  ) async {
    final utilisateurs = await _chargerUtilisateurs();
    final index = utilisateurs.indexWhere((u) => u.telephone == telephone);
    if (index == -1) {
      throw ExceptionAuthentification('Aucun compte associé à ce numéro.');
    }
    utilisateurs[index] = utilisateurs[index].copierAvec(motDePasse: motDePasse);
    await _sauvegarderUtilisateurs(utilisateurs);
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<void> enregistrerSession(Utilisateur utilisateur) async {
    final prefs = await _prefs;
    await prefs.setString(_cleSession, utilisateur.id);
  }

  Future<Utilisateur?> chargerSession() async {
    final prefs = await _prefs;
    final id = prefs.getString(_cleSession);
    if (id == null) return null;
    final utilisateurs = await _chargerUtilisateurs();
    for (final u in utilisateurs) {
      if (u.id == id) return u;
    }
    return null;
  }

  Future<void> deconnexion() async {
    final prefs = await _prefs;
    await prefs.remove(_cleSession);
  }

  String _nouvelId() => DateTime.now().microsecondsSinceEpoch.toString();
}
