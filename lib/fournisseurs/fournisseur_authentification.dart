import 'package:flutter/foundation.dart';

import '../modeles/modele_utilisateur.dart';
import '../services/service_authentification.dart';

/// Gestion d'état de l'authentification (Provider).
///
/// Expose l'utilisateur connecté et pilote les actions d'inscription, de
/// connexion, de vérification SMS et de récupération de compte en s'appuyant
/// sur [ServiceAuthentification].
class FournisseurAuthentification extends ChangeNotifier {
  FournisseurAuthentification({ServiceAuthentification? service})
      : _service = service ?? ServiceAuthentification() {
    _initialiser();
  }

  final ServiceAuthentification _service;

  Utilisateur? _utilisateurCourant;
  bool _initialise = false;
  bool _enChargement = false;
  String? _messageErreur;

  Utilisateur? get utilisateurCourant => _utilisateurCourant;
  bool get estConnecte => _utilisateurCourant != null;
  bool get initialise => _initialise;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  Future<void> _initialiser() async {
    _utilisateurCourant = await _service.chargerSession();
    _initialise = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Vérification SMS (simulée)
  // ---------------------------------------------------------------------------

  /// Envoie un code SMS et renvoie le code généré (pour affichage de démo),
  /// ou `null` en cas d'erreur.
  Future<String?> envoyerCodeSms(String telephone) async {
    _demarrerAction();
    try {
      final code = await _service.envoyerCodeSms(telephone);
      _terminerAction();
      return code;
    } catch (e) {
      _echouer(e);
      return null;
    }
  }

  bool verifierCodeSms(String telephone, String code) =>
      _service.verifierCodeSms(telephone, code);

  // ---------------------------------------------------------------------------
  // Connexion
  // ---------------------------------------------------------------------------

  Future<bool> connexionMotDePasse(String telephone, String motDePasse) =>
      _executerConnexion(
          () => _service.connexionMotDePasse(telephone, motDePasse));

  Future<bool> connexionParTelephone(String telephone) =>
      _executerConnexion(() => _service.connexionParTelephone(telephone));

  // ---------------------------------------------------------------------------
  // Inscription
  // ---------------------------------------------------------------------------

  Future<bool> inscrirePatient({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String ville,
    DateTime? dateNaissance,
  }) =>
      _executerConnexion(() => _service.inscrirePatient(
            nom: nom,
            telephone: telephone,
            motDePasse: motDePasse,
            ville: ville,
            dateNaissance: dateNaissance,
          ));

  /// Inscrit un médecin (compte en attente de validation). Ne connecte pas
  /// l'utilisateur : renvoie simplement le succès de l'opération.
  Future<bool> inscrireMedecin({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String specialite,
    required String numeroOrdre,
    required String etablissement,
  }) async {
    _demarrerAction();
    try {
      await _service.inscrireMedecin(
        nom: nom,
        telephone: telephone,
        motDePasse: motDePasse,
        specialite: specialite,
        numeroOrdre: numeroOrdre,
        etablissement: etablissement,
      );
      _terminerAction();
      return true;
    } catch (e) {
      _echouer(e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Récupération de compte
  // ---------------------------------------------------------------------------

  Future<bool> telephoneExiste(String telephone) =>
      _service.telephoneExiste(telephone);

  Future<bool> definirNouveauMotDePasse(
    String telephone,
    String motDePasse,
  ) async {
    _demarrerAction();
    try {
      await _service.definirNouveauMotDePasse(telephone, motDePasse);
      _terminerAction();
      return true;
    } catch (e) {
      _echouer(e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<void> deconnexion() async {
    await _service.deconnexion();
    _utilisateurCourant = null;
    notifyListeners();
  }

  void effacerErreur() {
    if (_messageErreur != null) {
      _messageErreur = null;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Aides internes
  // ---------------------------------------------------------------------------

  Future<bool> _executerConnexion(
    Future<Utilisateur> Function() action,
  ) async {
    _demarrerAction();
    try {
      _utilisateurCourant = await action();
      _terminerAction();
      return true;
    } catch (e) {
      _echouer(e);
      return false;
    }
  }

  void _demarrerAction() {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();
  }

  void _terminerAction() {
    _enChargement = false;
    notifyListeners();
  }

  void _echouer(Object erreur) {
    _messageErreur = erreur is ExceptionAuthentification
        ? erreur.message
        : 'Une erreur est survenue. Veuillez réessayer.';
    _enChargement = false;
    notifyListeners();
  }
}
