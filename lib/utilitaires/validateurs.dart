/// Validateurs de formulaire réutilisables pour MediConnect.
///
/// Chaque fonction renvoie `null` si la valeur est valide, sinon un message
/// d'erreur en français à afficher sous le champ.
class Validateurs {
  Validateurs._();

  static String? champObligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  static String? telephone(String? valeur) {
    final obligatoire = champObligatoire(valeur);
    if (obligatoire != null) return obligatoire;
    final chiffres = valeur!.replaceAll(RegExp(r'\D'), '');
    if (chiffres.length < 8) {
      return 'Numéro de téléphone invalide.';
    }
    return null;
  }

  static String? motDePasse(String? valeur) {
    final obligatoire = champObligatoire(valeur);
    if (obligatoire != null) return obligatoire;
    if (valeur!.length < 6) {
      return 'Au moins 6 caractères.';
    }
    return null;
  }

  static String? codeSms(String? valeur) {
    final obligatoire = champObligatoire(valeur);
    if (obligatoire != null) return obligatoire;
    if (valeur!.trim().length != 6) {
      return 'Le code contient 6 chiffres.';
    }
    return null;
  }
}
