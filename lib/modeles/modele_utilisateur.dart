/// Rôle d'un compte sur la plateforme MediConnect.
enum RoleUtilisateur { patient, medecin, administrateur }

extension LibelleRole on RoleUtilisateur {
  String get libelle => switch (this) {
        RoleUtilisateur.patient => 'Patient',
        RoleUtilisateur.medecin => 'Médecin',
        RoleUtilisateur.administrateur => 'Administrateur',
      };
}

/// Statut de validation d'un compte médecin par un administrateur
/// (cf. cahier des charges 4.1 : le compte médecin doit être validé avant
/// activation).
enum StatutValidationMedecin { enAttente, valide, refuse }

extension LibelleStatut on StatutValidationMedecin {
  String get libelle => switch (this) {
        StatutValidationMedecin.enAttente => 'En attente de validation',
        StatutValidationMedecin.valide => 'Compte validé',
        StatutValidationMedecin.refuse => 'Inscription refusée',
      };
}

/// Représente un utilisateur de MediConnect (patient, médecin ou administrateur).
///
/// Les champs spécifiques au médecin (spécialité, numéro d'ordre, établissement,
/// statut de validation) sont optionnels et ne sont renseignés que pour les
/// comptes médecin.
///
/// Note : le mot de passe est stocké en clair pour ce prototype simulé — à ne
/// jamais faire en production (chiffrement/hachage côté serveur requis).
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.role,
    required this.nom,
    required this.telephone,
    this.motDePasse,
    this.ville,
    this.dateNaissance,
    this.specialite,
    this.numeroOrdre,
    this.etablissement,
    this.statutValidation,
  });

  final String id;
  final RoleUtilisateur role;
  final String nom;
  final String telephone;
  final String? motDePasse;

  // --- Champs patient ---
  final String? ville;
  final DateTime? dateNaissance;

  // --- Champs médecin ---
  final String? specialite;
  final String? numeroOrdre;
  final String? etablissement;
  final StatutValidationMedecin? statutValidation;

  bool get estPatient => role == RoleUtilisateur.patient;
  bool get estMedecin => role == RoleUtilisateur.medecin;
  bool get estAdministrateur => role == RoleUtilisateur.administrateur;

  /// Vrai si le compte est utilisable (les médecins doivent être validés).
  bool get estActif =>
      !estMedecin || statutValidation == StatutValidationMedecin.valide;

  Utilisateur copierAvec({
    String? nom,
    String? motDePasse,
    String? ville,
    DateTime? dateNaissance,
    String? specialite,
    String? numeroOrdre,
    String? etablissement,
    StatutValidationMedecin? statutValidation,
  }) {
    return Utilisateur(
      id: id,
      role: role,
      nom: nom ?? this.nom,
      telephone: telephone,
      motDePasse: motDePasse ?? this.motDePasse,
      ville: ville ?? this.ville,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      specialite: specialite ?? this.specialite,
      numeroOrdre: numeroOrdre ?? this.numeroOrdre,
      etablissement: etablissement ?? this.etablissement,
      statutValidation: statutValidation ?? this.statutValidation,
    );
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'role': role.name,
        'nom': nom,
        'telephone': telephone,
        'motDePasse': motDePasse,
        'ville': ville,
        'dateNaissance': dateNaissance?.toIso8601String(),
        'specialite': specialite,
        'numeroOrdre': numeroOrdre,
        'etablissement': etablissement,
        'statutValidation': statutValidation?.name,
      };

  factory Utilisateur.depuisJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as String,
      role: RoleUtilisateur.values.byName(json['role'] as String),
      nom: json['nom'] as String,
      telephone: json['telephone'] as String,
      motDePasse: json['motDePasse'] as String?,
      ville: json['ville'] as String?,
      dateNaissance: json['dateNaissance'] == null
          ? null
          : DateTime.parse(json['dateNaissance'] as String),
      specialite: json['specialite'] as String?,
      numeroOrdre: json['numeroOrdre'] as String?,
      etablissement: json['etablissement'] as String?,
      statutValidation: json['statutValidation'] == null
          ? null
          : StatutValidationMedecin.values
              .byName(json['statutValidation'] as String),
    );
  }
}
