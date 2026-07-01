import 'dart:async';

import 'package:flutter/foundation.dart';

import '../modeles/modele_consultation.dart';
import '../services/service_teleconsultation.dart';

/// État de l'appel de téléconsultation.
enum EtatAppel { connexion, enCours, reconnexion, termine }

/// Gestion d'état d'un appel de téléconsultation **simulé**.
///
/// Gère l'établissement de l'appel, le minuteur de durée, les bascules
/// micro/caméra, la dégradation vidéo → audio (bande passante faible) et la
/// reprise après coupure sans perdre la durée écoulée (cf. cahier 4.4 §16).
class FournisseurTeleconsultation extends ChangeNotifier {
  FournisseurTeleconsultation({ServiceTeleconsultation? service})
      : _service = service ?? ServiceTeleconsultation();

  final ServiceTeleconsultation _service;

  Consultation? _consultation;
  EtatAppel _etat = EtatAppel.connexion;
  bool _microActif = true;
  bool _cameraActive = true;
  bool _modeAudioSeul = false;
  int _dureeSecondes = 0;
  Timer? _minuteur;

  Consultation? get consultation => _consultation;
  EtatAppel get etat => _etat;
  bool get microActif => _microActif;
  bool get cameraActive => _cameraActive;
  bool get modeAudioSeul => _modeAudioSeul;
  int get dureeSecondes => _dureeSecondes;

  String get dureeLisible {
    final minutes = (_dureeSecondes ~/ 60).toString().padLeft(2, '0');
    final secondes = (_dureeSecondes % 60).toString().padLeft(2, '0');
    return '$minutes:$secondes';
  }

  /// Démarre l'appel : enregistre la consultation (en cours) puis simule
  /// l'établissement de la connexion.
  Future<void> demarrer(Consultation consultation) async {
    _consultation = await _service.creerConsultation(consultation);
    _etat = EtatAppel.connexion;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    if (_etat == EtatAppel.termine) return;
    _etat = EtatAppel.enCours;
    _lancerMinuteur();
    notifyListeners();
  }

  void basculerMicro() {
    _microActif = !_microActif;
    notifyListeners();
  }

  void basculerCamera() {
    _cameraActive = !_cameraActive;
    notifyListeners();
  }

  /// Bascule en audio seul (dégradation en cas de bande passante insuffisante).
  void basculerModeAudio() {
    _modeAudioSeul = !_modeAudioSeul;
    if (_modeAudioSeul) _cameraActive = false;
    notifyListeners();
  }

  /// Simule une coupure réseau puis une reprise : l'appel reprend sans perdre
  /// la durée écoulée.
  Future<void> simulerCoupure() async {
    if (_etat != EtatAppel.enCours) return;
    _minuteur?.cancel();
    _etat = EtatAppel.reconnexion;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    if (_etat == EtatAppel.termine) return;
    _etat = EtatAppel.enCours;
    _lancerMinuteur();
    notifyListeners();
  }

  /// Termine l'appel, met à jour la durée et (optionnellement) la synthèse.
  Future<Consultation?> terminer({String? synthese}) async {
    _minuteur?.cancel();
    _etat = EtatAppel.termine;
    notifyListeners();
    if (_consultation == null) return null;
    return _service.terminerConsultation(
      _consultation!.id,
      dureeSecondes: _dureeSecondes,
      synthese: synthese,
    );
  }

  void _lancerMinuteur() {
    _minuteur?.cancel();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) {
      _dureeSecondes++;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }
}
