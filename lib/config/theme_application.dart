import 'package:flutter/material.dart';

import 'couleurs_application.dart';
import 'dimensions_application.dart';
import 'typographie_application.dart';

/// Thème global (clair) de MediConnect.
///
/// Assemble la palette, la typographie et les dimensions en un [ThemeData]
/// unique appliqué à toute l'application. Les widgets natifs héritent ainsi
/// automatiquement de l'identité visuelle.
class ThemeApplication {
  ThemeApplication._();

  static ThemeData get clair {
    final schemaCouleurs = ColorScheme.fromSeed(
      seedColor: CouleursApplication.primaire,
      brightness: Brightness.light,
    ).copyWith(
      primary: CouleursApplication.primaire,
      onPrimary: Colors.white,
      secondary: CouleursApplication.accent,
      onSecondary: Colors.white,
      error: CouleursApplication.danger,
      surface: CouleursApplication.surface,
      onSurface: CouleursApplication.textePrincipal,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: schemaCouleurs);

    return base.copyWith(
      scaffoldBackgroundColor: CouleursApplication.fond,
      textTheme: TypographieApplication.themeTexte(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: CouleursApplication.surface,
        foregroundColor: CouleursApplication.textePrincipal,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CouleursApplication.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DimensionsApplication.espacementMoyen,
          vertical: 14,
        ),
        border: _bordureChamp(CouleursApplication.bordure),
        enabledBorder: _bordureChamp(CouleursApplication.bordure),
        focusedBorder: _bordureChamp(CouleursApplication.primaire, epaisseur: 1.6),
        errorBorder: _bordureChamp(CouleursApplication.danger),
        focusedErrorBorder: _bordureChamp(CouleursApplication.danger, epaisseur: 1.6),
        labelStyle: const TextStyle(color: CouleursApplication.texteSecondaire),
        hintStyle: const TextStyle(color: CouleursApplication.texteTertiaire),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApplication.primaire,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, DimensionsApplication.hauteurBouton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CouleursApplication.primaire,
          minimumSize: const Size(0, DimensionsApplication.hauteurBouton),
          side: const BorderSide(color: CouleursApplication.primaire),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CouleursApplication.primaire,
        ),
      ),
    );
  }

  static OutlineInputBorder _bordureChamp(Color couleur, {double epaisseur = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(DimensionsApplication.rayonMoyen),
      borderSide: BorderSide(color: couleur, width: epaisseur),
    );
  }
}
