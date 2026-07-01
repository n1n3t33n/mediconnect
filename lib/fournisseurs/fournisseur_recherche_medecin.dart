import 'package:flutter/foundation.dart';

import '../modeles/modele_medecin.dart';
import '../services/service_medecins.dart';

/// Gestion d'état de la recherche de médecins : filtres (spécialité,
/// établissement, disponibilité immédiate) et résultats.
class FournisseurRechercheMedecin extends ChangeNotifier {
  FournisseurRechercheMedecin({ServiceMedecins? service})
      : _service = service ?? ServiceMedecins() {
    _resultats = _service.tousLesMedecins();
  }

  final ServiceMedecins _service;

  String? _specialite;
  String? _etablissement;
  bool _disponibleSeulement = false;
  late List<MedecinDisponible> _resultats;

  String? get specialite => _specialite;
  String? get etablissement => _etablissement;
  bool get disponibleSeulement => _disponibleSeulement;
  List<MedecinDisponible> get resultats => _resultats;

  List<String> get specialitesDisponibles => _service.specialites();
  List<String> get etablissementsDisponibles => _service.etablissements();

  bool get filtresActifs =>
      _specialite != null || _etablissement != null || _disponibleSeulement;

  void definirSpecialite(String? valeur) {
    _specialite = valeur;
    _appliquer();
  }

  void definirEtablissement(String? valeur) {
    _etablissement = valeur;
    _appliquer();
  }

  void definirDisponibleSeulement(bool valeur) {
    _disponibleSeulement = valeur;
    _appliquer();
  }

  void reinitialiser() {
    _specialite = null;
    _etablissement = null;
    _disponibleSeulement = false;
    _appliquer();
  }

  void _appliquer() {
    _resultats = _service.filtrer(
      specialite: _specialite,
      etablissement: _etablissement,
      disponibleSeulement: _disponibleSeulement,
    );
    notifyListeners();
  }
}
