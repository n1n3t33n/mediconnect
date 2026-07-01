/// Statut d'une consultation (session de téléconsultation).
enum StatutConsultation { enCours, terminee }

/// Type de consultation (cf. modèle de données : standard / renouvellement).
enum TypeConsultation { standard, renouvellement }

extension LibelleTypeConsultation on TypeConsultation {
  String get libelle => switch (this) {
        TypeConsultation.standard => 'Consultation standard',
        TypeConsultation.renouvellement => 'Renouvellement d\'ordonnance',
      };
}

/// Une consultation réalisée (ou en cours) entre un patient et un médecin.
///
/// Porte la synthèse rédigée par le médecin en fin de consultation et le lien
/// vers le résumé d'auto-diagnostic.
class Consultation {
  Consultation({
    required this.id,
    required this.patientId,
    required this.patientNom,
    required this.medecinId,
    required this.medecinNom,
    required this.specialite,
    required this.statut,
    this.type = TypeConsultation.standard,
    this.synthese,
    this.resumeAutoDiagnostic,
    this.dureeSecondes = 0,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final String id;
  final String patientId;
  final String patientNom;
  final String medecinId;
  final String medecinNom;
  final String specialite;
  final StatutConsultation statut;
  final TypeConsultation type;
  final String? synthese;
  final String? resumeAutoDiagnostic;
  final int dureeSecondes;
  final DateTime date;

  bool get aSynthese => synthese != null && synthese!.trim().isNotEmpty;

  Consultation copierAvec({
    StatutConsultation? statut,
    String? synthese,
    int? dureeSecondes,
  }) {
    return Consultation(
      id: id,
      patientId: patientId,
      patientNom: patientNom,
      medecinId: medecinId,
      medecinNom: medecinNom,
      specialite: specialite,
      statut: statut ?? this.statut,
      type: type,
      synthese: synthese ?? this.synthese,
      resumeAutoDiagnostic: resumeAutoDiagnostic,
      dureeSecondes: dureeSecondes ?? this.dureeSecondes,
      date: date,
    );
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'patientId': patientId,
        'patientNom': patientNom,
        'medecinId': medecinId,
        'medecinNom': medecinNom,
        'specialite': specialite,
        'statut': statut.name,
        'type': type.name,
        'synthese': synthese,
        'resumeAutoDiagnostic': resumeAutoDiagnostic,
        'dureeSecondes': dureeSecondes,
        'date': date.toIso8601String(),
      };

  factory Consultation.depuisJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientNom: json['patientNom'] as String,
      medecinId: json['medecinId'] as String,
      medecinNom: json['medecinNom'] as String,
      specialite: json['specialite'] as String,
      statut: StatutConsultation.values.byName(json['statut'] as String),
      type: TypeConsultation.values.byName(json['type'] as String),
      synthese: json['synthese'] as String?,
      resumeAutoDiagnostic: json['resumeAutoDiagnostic'] as String?,
      dureeSecondes: (json['dureeSecondes'] as num?)?.toInt() ?? 0,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
