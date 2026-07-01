/// Constantes générales de l'application MediConnect.
///
/// Textes d'identité, unités et valeurs métier de référence, regroupés pour
/// éviter leur duplication dans le code.
class ConstantesApplication {
  ConstantesApplication._();

  // --- Identité ---
  static const String nomApplication = 'MediConnect';
  static const String slogan = 'Santé connectée — Côte d\'Ivoire';

  // --- Paiement ---
  static const String devise = 'FCFA';

  /// Tarif indicatif d'une consultation simple (cible < 3000 FCFA, cf. persona Aya).
  static const int tarifConsultationSimple = 2500;

  // --- Avertissement légal réutilisé sur l'auto-diagnostic ---
  static const String avertissementAutoDiagnostic =
      'Cette orientation ne remplace pas un avis médical. '
      'En cas de symptômes graves, contactez un service d\'urgence.';
}
