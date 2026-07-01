import 'package:flutter/foundation.dart';

import '../modeles/modele_demande_consultation.dart';
import '../modeles/modele_medecin.dart';
import '../modeles/modele_utilisateur.dart';
import '../services/service_consultations.dart';

/// Gestion d'état des demandes de consultation (mise en relation).
///
/// Fourni globalement : partagé entre le parcours patient (création) et, plus
/// tard, l'espace médecin (réception des demandes).
class FournisseurConsultations extends ChangeNotifier {
  FournisseurConsultations({ServiceConsultations? service})
      : _service = service ?? ServiceConsultations();

  final ServiceConsultations _service;

  bool _enChargement = false;
  bool get enChargement => _enChargement;

  /// Crée une demande de consultation pour le patient auprès du médecin choisi.
  ///
  /// Renvoie la demande créée, ou `null` en cas d'erreur.
  Future<DemandeConsultation?> creerDemande({
    required MedecinDisponible medecin,
    required Utilisateur patient,
    required TypeMiseEnRelation type,
    DateTime? creneau,
    String? resumeAutoDiagnostic,
  }) async {
    _enChargement = true;
    notifyListeners();
    try {
      final demande = DemandeConsultation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        medecinId: medecin.id,
        medecinNom: medecin.nom,
        specialite: medecin.specialite,
        patientId: patient.id,
        patientNom: patient.nom,
        type: type,
        statut: StatutDemande.enAttente,
        creneau: creneau,
        resumeAutoDiagnostic: resumeAutoDiagnostic,
      );
      await _service.creer(demande);
      _enChargement = false;
      notifyListeners();
      return demande;
    } catch (_) {
      _enChargement = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<DemandeConsultation>> demandesDuPatient(String patientId) =>
      _service.demandesDuPatient(patientId);

  Future<List<DemandeConsultation>> demandesDuMedecin(String medecinId) =>
      _service.demandesDuMedecin(medecinId);
}
