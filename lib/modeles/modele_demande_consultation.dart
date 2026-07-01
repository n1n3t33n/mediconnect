/// Type de mise en relation demandée par le patient.
enum TypeMiseEnRelation { immediate, creneau }

extension LibelleTypeMiseEnRelation on TypeMiseEnRelation {
  String get libelle => switch (this) {
        TypeMiseEnRelation.immediate => 'Mise en relation immédiate',
        TypeMiseEnRelation.creneau => 'Créneau programmé',
      };
}

/// Statut d'une demande de consultation.
enum StatutDemande { enAttente, acceptee, terminee, annulee }

extension LibelleStatutDemande on StatutDemande {
  String get libelle => switch (this) {
        StatutDemande.enAttente => 'En attente',
        StatutDemande.acceptee => 'Acceptée',
        StatutDemande.terminee => 'Terminée',
        StatutDemande.annulee => 'Annulée',
      };
}

/// Demande de consultation créée par un patient auprès d'un médecin.
///
/// Porte le résumé de l'auto-diagnostic (cf. cahier 4.3 §12 : le médecin doit
/// avoir accès au pré-diagnostic).
class DemandeConsultation {
  DemandeConsultation({
    required this.id,
    required this.medecinId,
    required this.medecinNom,
    required this.specialite,
    required this.patientId,
    required this.patientNom,
    required this.type,
    required this.statut,
    this.creneau,
    this.resumeAutoDiagnostic,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  final String id;
  final String medecinId;
  final String medecinNom;
  final String specialite;
  final String patientId;
  final String patientNom;
  final TypeMiseEnRelation type;
  final StatutDemande statut;
  final DateTime? creneau;
  final String? resumeAutoDiagnostic;
  final DateTime dateCreation;

  Map<String, dynamic> versJson() => {
        'id': id,
        'medecinId': medecinId,
        'medecinNom': medecinNom,
        'specialite': specialite,
        'patientId': patientId,
        'patientNom': patientNom,
        'type': type.name,
        'statut': statut.name,
        'creneau': creneau?.toIso8601String(),
        'resumeAutoDiagnostic': resumeAutoDiagnostic,
        'dateCreation': dateCreation.toIso8601String(),
      };

  factory DemandeConsultation.depuisJson(Map<String, dynamic> json) {
    return DemandeConsultation(
      id: json['id'] as String,
      medecinId: json['medecinId'] as String,
      medecinNom: json['medecinNom'] as String,
      specialite: json['specialite'] as String,
      patientId: json['patientId'] as String,
      patientNom: json['patientNom'] as String,
      type: TypeMiseEnRelation.values.byName(json['type'] as String),
      statut: StatutDemande.values.byName(json['statut'] as String),
      creneau: json['creneau'] == null
          ? null
          : DateTime.parse(json['creneau'] as String),
      resumeAutoDiagnostic: json['resumeAutoDiagnostic'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );
  }
}
