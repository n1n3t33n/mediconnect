import 'package:flutter/material.dart';

/// Palette de couleurs de MediConnect.
///
/// Identité santé (bleu-vert médical, rassurant) avec un accent orange
/// rappelant la Côte d'Ivoire. C'est la source unique de vérité des couleurs :
/// aucun code couleur ne doit être écrit « en dur » ailleurs dans l'application.
class CouleursApplication {
  CouleursApplication._();

  // --- Couleur principale : bleu-vert médical ---
  static const Color primaire = Color(0xFF0B8FAC);
  static const Color primaireFonce = Color(0xFF086C82);
  static const Color primaireClair = Color(0xFFE1F3F8);

  // --- Accent : orange (Côte d'Ivoire), pour les mises en avant ---
  static const Color accent = Color(0xFFF39200);
  static const Color accentClair = Color(0xFFFDEBD3);

  // --- Couleurs d'état ---
  static const Color succes = Color(0xFF2E9E5B);
  static const Color succesClair = Color(0xFFE3F5EA);
  static const Color avertissement = Color(0xFFF5A623);
  static const Color avertissementClair = Color(0xFFFDF1DC);
  static const Color danger = Color(0xFFE23B3B);
  static const Color dangerClair = Color(0xFFFCE4E4);

  // --- Neutres ---
  static const Color fond = Color(0xFFF6F8F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textePrincipal = Color(0xFF1A2A33);
  static const Color texteSecondaire = Color(0xFF5C6B73);
  static const Color texteTertiaire = Color(0xFF95A3AB);
  static const Color bordure = Color(0xFFE0E6E9);
}
