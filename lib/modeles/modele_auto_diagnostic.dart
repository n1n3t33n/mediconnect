import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';

/// Niveau de criticité issu de l'auto-diagnostic (aide à l'orientation,
/// jamais un diagnostic médical).
enum NiveauCriticite { faible, moyen, eleve, urgence }

extension DetailsCriticite on NiveauCriticite {
  String get titre => switch (this) {
        NiveauCriticite.faible => 'À surveiller',
        NiveauCriticite.moyen => 'Consultation recommandée',
        NiveauCriticite.eleve => 'Consultation rapide recommandée',
        NiveauCriticite.urgence => 'Urgence possible',
      };

  String get description => switch (this) {
        NiveauCriticite.faible =>
          'Vos symptômes semblent bénins pour le moment. Surveillez leur '
              'évolution et reposez-vous ; consultez si la situation s\'aggrave.',
        NiveauCriticite.moyen =>
          'Une téléconsultation avec un médecin est conseillée pour évaluer '
              'votre situation.',
        NiveauCriticite.eleve =>
          'Vos réponses suggèrent de consulter un médecin rapidement. Une '
              'téléconsultation prioritaire est conseillée.',
        NiveauCriticite.urgence =>
          'Vos réponses signalent des signes potentiellement graves. '
              'Rapprochez-vous immédiatement d\'un service d\'urgence physique.',
      };

  Color get couleur => switch (this) {
        NiveauCriticite.faible => CouleursApplication.succes,
        NiveauCriticite.moyen => CouleursApplication.primaire,
        NiveauCriticite.eleve => CouleursApplication.avertissement,
        NiveauCriticite.urgence => CouleursApplication.danger,
      };

  IconData get icone => switch (this) {
        NiveauCriticite.faible => Icons.check_circle_outline,
        NiveauCriticite.moyen => Icons.info_outline,
        NiveauCriticite.eleve => Icons.warning_amber_outlined,
        NiveauCriticite.urgence => Icons.emergency_outlined,
      };

  bool get estUrgence => this == NiveauCriticite.urgence;
}

/// Résultat d'un auto-diagnostic : orientation indicative + niveau de criticité.
class ResultatAutoDiagnostic {
  ResultatAutoDiagnostic({
    required this.niveau,
    required this.symptomesSignales,
    required this.symptomeCritiquePresent,
    required this.recommandations,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final NiveauCriticite niveau;
  final List<String> symptomesSignales;
  final bool symptomeCritiquePresent;
  final List<String> recommandations;
  final DateTime date;
}
