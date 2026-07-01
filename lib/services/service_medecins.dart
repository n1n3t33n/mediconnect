import '../modeles/modele_medecin.dart';

/// Fournit la liste des médecins (données de démonstration) et les fonctions de
/// filtrage utilisées par la recherche.
///
/// Dans une version réelle, ces données proviendraient du backend et du réseau
/// d'établissements partenaires.
class ServiceMedecins {
  List<MedecinDisponible>? _cache;

  List<MedecinDisponible> tousLesMedecins() => _cache ??= _seed();

  /// Spécialités distinctes, triées.
  List<String> specialites() {
    final ensemble =
        tousLesMedecins().map((m) => m.specialite).toSet().toList()..sort();
    return ensemble;
  }

  /// Établissements distincts, triés.
  List<String> etablissements() {
    final ensemble =
        tousLesMedecins().map((m) => m.etablissement).toSet().toList()..sort();
    return ensemble;
  }

  /// Filtre par spécialité, établissement et disponibilité immédiate.
  List<MedecinDisponible> filtrer({
    String? specialite,
    String? etablissement,
    bool disponibleSeulement = false,
  }) {
    return tousLesMedecins().where((m) {
      if (specialite != null &&
          specialite.isNotEmpty &&
          m.specialite != specialite) {
        return false;
      }
      if (etablissement != null &&
          etablissement.isNotEmpty &&
          m.etablissement != etablissement) {
        return false;
      }
      if (disponibleSeulement && !m.disponibleImmediatement) return false;
      return true;
    }).toList();
  }

  MedecinDisponible? parId(String id) {
    for (final m in tousLesMedecins()) {
      if (m.id == id) return m;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Données de démonstration
  // ---------------------------------------------------------------------------

  /// Construit un créneau à [joursPlus] jours de maintenant, à l'heure [heure].
  static DateTime _creneau(int joursPlus, int heure) {
    final base = DateTime.now().add(Duration(days: joursPlus));
    return DateTime(base.year, base.month, base.day, heure);
  }

  List<MedecinDisponible> _seed() => [
        MedecinDisponible(
          id: 'demo-medecin',
          nom: 'Dr. Koffi',
          specialite: 'Médecine générale',
          etablissement: 'CHU de Cocody',
          ville: 'Abidjan',
          note: 4.7,
          nombreAvis: 128,
          disponibleImmediatement: true,
          creneaux: [_creneau(0, 20), _creneau(1, 10), _creneau(1, 18)],
        ),
        MedecinDisponible(
          id: 'med-aya',
          nom: 'Dr. Aya N\'Guessan',
          specialite: 'Pédiatrie',
          etablissement: 'Clinique PISAM',
          ville: 'Abidjan',
          note: 4.9,
          nombreAvis: 86,
          disponibleImmediatement: false,
          creneaux: [_creneau(1, 9), _creneau(2, 15), _creneau(3, 11)],
        ),
        MedecinDisponible(
          id: 'med-bakary',
          nom: 'Dr. Bakary Traoré',
          specialite: 'Cardiologie',
          etablissement: 'CHU de Treichville',
          ville: 'Abidjan',
          note: 4.5,
          nombreAvis: 54,
          disponibleImmediatement: false,
          creneaux: [_creneau(2, 8), _creneau(2, 17), _creneau(4, 10)],
        ),
        MedecinDisponible(
          id: 'med-fatou',
          nom: 'Dr. Fatou Diallo',
          specialite: 'Dermatologie',
          etablissement: 'Polyclinique Sainte-Anne-Marie',
          ville: 'Abidjan',
          note: 4.6,
          nombreAvis: 73,
          disponibleImmediatement: true,
          creneaux: [_creneau(0, 21), _creneau(1, 14)],
        ),
        MedecinDisponible(
          id: 'med-yao',
          nom: 'Dr. Yao Kouassi',
          specialite: 'Médecine générale',
          etablissement: 'Hôpital Général d\'Abobo',
          ville: 'Abidjan',
          note: 4.3,
          nombreAvis: 41,
          disponibleImmediatement: true,
          creneaux: [_creneau(0, 19), _creneau(1, 12), _creneau(2, 9)],
        ),
        MedecinDisponible(
          id: 'med-mariam',
          nom: 'Dr. Mariam Coulibaly',
          specialite: 'Gynécologie',
          etablissement: 'Clinique PISAM',
          ville: 'Abidjan',
          note: 4.8,
          nombreAvis: 95,
          disponibleImmediatement: false,
          creneaux: [_creneau(1, 16), _creneau(3, 10)],
        ),
        MedecinDisponible(
          id: 'med-serge',
          nom: 'Dr. Serge Brou',
          specialite: 'Médecine générale',
          etablissement: 'CHU de Bouaké',
          ville: 'Bouaké',
          note: 4.2,
          nombreAvis: 30,
          disponibleImmediatement: true,
          creneaux: [_creneau(0, 22), _creneau(2, 20)],
        ),
      ];
}
