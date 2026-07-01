/// Médecin proposé dans la recherche et la mise en relation.
///
/// Regroupe les informations affichées sur la fiche et la carte : identité,
/// spécialité, établissement, note moyenne, disponibilité et créneaux à venir.
class MedecinDisponible {
  const MedecinDisponible({
    required this.id,
    required this.nom,
    required this.specialite,
    required this.etablissement,
    required this.ville,
    required this.note,
    required this.nombreAvis,
    required this.disponibleImmediatement,
    required this.creneaux,
  });

  final String id;
  final String nom;
  final String specialite;
  final String etablissement;
  final String ville;
  final double note;
  final int nombreAvis;
  final bool disponibleImmediatement;

  /// Créneaux programmables à venir, triés du plus proche au plus lointain.
  final List<DateTime> creneaux;

  DateTime? get prochainCreneau => creneaux.isEmpty ? null : creneaux.first;

  /// Initiales pour l'avatar (ex. « Dr. Aya Koffi » → « AK »).
  String get initiales {
    final mots = nom
        .replaceAll('Dr.', '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty)
        .toList();
    if (mots.isEmpty) return '?';
    if (mots.length == 1) return mots.first.substring(0, 1).toUpperCase();
    return (mots.first.substring(0, 1) + mots.last.substring(0, 1))
        .toUpperCase();
  }
}
