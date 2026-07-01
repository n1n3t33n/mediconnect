/// Dimensions et espacements standard de MediConnect.
///
/// Centraliser les valeurs (marges, rayons, hauteurs) garantit une interface
/// cohérente et facile à ajuster globalement.
class DimensionsApplication {
  DimensionsApplication._();

  // --- Espacements ---
  static const double espacementTresPetit = 4;
  static const double espacementPetit = 8;
  static const double espacementMoyen = 16;
  static const double espacementGrand = 24;
  static const double espacementTresGrand = 32;

  // --- Rayons de bordure ---
  static const double rayonPetit = 8;
  static const double rayonMoyen = 12;
  static const double rayonGrand = 16;
  static const double rayonComplet = 999;

  // --- Composants ---
  static const double hauteurBouton = 52;
  static const double largeurMaxContenu = 480;
}
