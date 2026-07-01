import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'couleurs_application.dart';

/// Typographie de MediConnect.
///
/// Utilise la police Poppins (lisible et chaleureuse) pour l'ensemble des
/// styles de texte, avec les couleurs neutres par défaut de l'application.
class TypographieApplication {
  TypographieApplication._();

  /// Construit le thème de texte à partir d'un [TextTheme] de base
  /// (fourni par [ThemeData]) en appliquant la police et les couleurs.
  static TextTheme themeTexte(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base).apply(
      bodyColor: CouleursApplication.textePrincipal,
      displayColor: CouleursApplication.textePrincipal,
    );
  }
}
