import '../modeles/modele_auto_diagnostic.dart';
import '../modeles/modele_question_diagnostic.dart';
import 'questionnaire_symptomes.dart';

/// Évalue les réponses de l'auto-diagnostic pour produire une orientation
/// indicative et un niveau de criticité.
///
/// L'évaluation est purement indicative (règles simples) et ne constitue **pas**
/// un diagnostic médical.
class ServiceAutoDiagnostic {
  /// Antécédents qui aggravent la prudence en présence d'un symptôme critique.
  static const Set<String> _antecedentsAggravants = {
    'diabete',
    'hypertension',
    'cardiaque',
    'asthme',
    'grossesse',
  };

  ResultatAutoDiagnostic evaluer(Map<String, dynamic> reponses) {
    final symptomesSignales = <String>[];
    var symptomeCritique = false;
    var score = 0;

    for (final question in questionnaireSymptomes) {
      if (question.type != TypeReponse.choixMultiple) continue;
      if (question.code == 'antecedents') continue;

      final selection =
          (reponses[question.code] as List?)?.cast<String>() ?? const [];
      for (final option in question.options) {
        if (!selection.contains(option.code)) continue;
        if (option.code == 'aucun_signe') continue;
        symptomesSignales.add(option.libelle);
        if (option.critique) {
          symptomeCritique = true;
          score += 3;
        }
      }
    }

    final intensite = (reponses['intensite'] as int?) ?? 1;
    score += (intensite - 1).clamp(0, 4);

    if (reponses['duree'] == 'plus_semaine') score += 1;

    final antecedents =
        (reponses['antecedents'] as List?)?.cast<String>() ?? const [];
    if (symptomeCritique && antecedents.any(_antecedentsAggravants.contains)) {
      score += 1;
    }

    final niveau = _niveauDepuisScore(score);
    return ResultatAutoDiagnostic(
      niveau: niveau,
      symptomesSignales: symptomesSignales,
      symptomeCritiquePresent: symptomeCritique,
      recommandations: _recommandations(niveau),
    );
  }

  NiveauCriticite _niveauDepuisScore(int score) {
    if (score >= 7) return NiveauCriticite.urgence;
    if (score >= 4) return NiveauCriticite.eleve;
    if (score >= 2) return NiveauCriticite.moyen;
    return NiveauCriticite.faible;
  }

  List<String> _recommandations(NiveauCriticite niveau) => switch (niveau) {
        NiveauCriticite.urgence => [
            'Contactez immédiatement un service d\'urgence.',
            'Ne restez pas seul(e) si possible.',
            'Ne conduisez pas vous-même en cas de malaise.',
          ],
        NiveauCriticite.eleve => [
            'Demandez une téléconsultation prioritaire dès que possible.',
            'Surveillez l\'apparition de nouveaux signes.',
          ],
        NiveauCriticite.moyen => [
            'Prenez une téléconsultation avec un médecin.',
            'Hydratez-vous et reposez-vous en attendant.',
          ],
        NiveauCriticite.faible => [
            'Reposez-vous et surveillez l\'évolution des symptômes.',
            'Consultez si les symptômes persistent ou s\'aggravent.',
          ],
      };
}
