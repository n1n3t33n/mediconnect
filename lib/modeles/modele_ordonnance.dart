// Modèle d'une ordonnance numérique (cf. cahier des charges §7).
//
// Une ordonnance est rattachée à une consultation. Elle est horodatée et
// « signée » électroniquement de façon simulée : la signature est matérialisée
// par le nom du médecin, son numéro d'ordre et un code de vérification unique
// (repris dans le PDF et le QR code de partage).

/// Une ligne de prescription : un médicament et sa posologie.
class LigneMedicament {
  const LigneMedicament({
    required this.nom,
    required this.posologie,
    this.duree,
    this.instructions,
  });

  /// Nom du médicament (ex. « Paracétamol 500 mg »).
  final String nom;

  /// Posologie (ex. « 1 comprimé matin et soir »).
  final String posologie;

  /// Durée du traitement (ex. « 5 jours »).
  final String? duree;

  /// Instructions complémentaires (ex. « à prendre pendant les repas »).
  final String? instructions;

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'posologie': posologie,
        'duree': duree,
        'instructions': instructions,
      };

  factory LigneMedicament.depuisJson(Map<String, dynamic> json) {
    return LigneMedicament(
      nom: json['nom'] as String,
      posologie: json['posologie'] as String,
      duree: json['duree'] as String?,
      instructions: json['instructions'] as String?,
    );
  }
}

/// Une ordonnance numérique rédigée par un médecin à l'issue d'une consultation.
class Ordonnance {
  Ordonnance({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.patientNom,
    required this.medecinId,
    required this.medecinNom,
    required this.specialite,
    required this.medicaments,
    required this.codeVerification,
    this.numeroOrdre,
    this.etablissement,
    this.remarques,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final String id;
  final String consultationId;
  final String patientId;
  final String patientNom;
  final String medecinId;
  final String medecinNom;
  final String specialite;
  final List<LigneMedicament> medicaments;

  /// Code de vérification unique servant de « signature » et d'identifiant de
  /// partage (encodé dans le QR code et le lien).
  final String codeVerification;

  final String? numeroOrdre;
  final String? etablissement;

  /// Remarques / conseils du médecin (repos, hydratation…).
  final String? remarques;

  /// Horodatage de génération de l'ordonnance.
  final DateTime date;

  /// Lien public (simulé) de vérification de l'ordonnance.
  String get lienVerification =>
      'https://mediconnect.ci/verifier/$codeVerification';

  /// Crée une nouvelle ordonnance en générant automatiquement l'identifiant, le
  /// code de vérification et l'horodatage.
  factory Ordonnance.nouvelle({
    required String consultationId,
    required String patientId,
    required String patientNom,
    required String medecinId,
    required String medecinNom,
    required String specialite,
    required List<LigneMedicament> medicaments,
    String? numeroOrdre,
    String? etablissement,
    String? remarques,
  }) {
    final maintenant = DateTime.now();
    return Ordonnance(
      id: maintenant.microsecondsSinceEpoch.toString(),
      consultationId: consultationId,
      patientId: patientId,
      patientNom: patientNom,
      medecinId: medecinId,
      medecinNom: medecinNom,
      specialite: specialite,
      medicaments: medicaments,
      codeVerification: _genererCode(maintenant),
      numeroOrdre: numeroOrdre,
      etablissement: etablissement,
      remarques: remarques,
      date: maintenant,
    );
  }

  static String _genererCode(DateTime base) {
    final brut =
        base.microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    final rembourre = brut.padLeft(8, '0');
    final derniers = rembourre.substring(rembourre.length - 8);
    return 'MC-${derniers.substring(0, 4)}-${derniers.substring(4, 8)}';
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'consultationId': consultationId,
        'patientId': patientId,
        'patientNom': patientNom,
        'medecinId': medecinId,
        'medecinNom': medecinNom,
        'specialite': specialite,
        'medicaments': medicaments.map((m) => m.versJson()).toList(),
        'codeVerification': codeVerification,
        'numeroOrdre': numeroOrdre,
        'etablissement': etablissement,
        'remarques': remarques,
        'date': date.toIso8601String(),
      };

  factory Ordonnance.depuisJson(Map<String, dynamic> json) {
    return Ordonnance(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String,
      patientId: json['patientId'] as String,
      patientNom: json['patientNom'] as String,
      medecinId: json['medecinId'] as String,
      medecinNom: json['medecinNom'] as String,
      specialite: json['specialite'] as String,
      medicaments: (json['medicaments'] as List)
          .map((e) => LigneMedicament.depuisJson(e as Map<String, dynamic>))
          .toList(),
      codeVerification: json['codeVerification'] as String,
      numeroOrdre: json['numeroOrdre'] as String?,
      etablissement: json['etablissement'] as String?,
      remarques: json['remarques'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
