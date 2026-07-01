import '../modeles/modele_question_diagnostic.dart';

/// Codes des questions listant des symptômes (dépendantes de la zone du corps).
const List<String> codesQuestionsSymptomes = [
  'symptomes_tete',
  'symptomes_poitrine',
  'symptomes_ventre',
  'symptomes_general',
];

/// Définition du questionnaire d'auto-diagnostic **adaptatif**.
///
/// Les questions de symptômes dépendent de la zone du corps sélectionnée, et
/// une question de signes d'alerte n'apparaît que si un symptôme critique a été
/// signalé.
final List<QuestionDiagnostic> questionnaireSymptomes = [
  QuestionDiagnostic(
    code: 'zone',
    intitule: 'Quelle partie du corps est concernée ?',
    type: TypeReponse.choixUnique,
    options: const [
      OptionSymptome('tete', 'Tête'),
      OptionSymptome('poitrine', 'Poitrine / respiration'),
      OptionSymptome('ventre', 'Ventre / digestion'),
      OptionSymptome('general', 'État général (fièvre, fatigue…)'),
    ],
  ),
  QuestionDiagnostic(
    code: 'symptomes_tete',
    intitule: 'Quels symptômes ressentez-vous ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    condition: (r) => r['zone'] == 'tete',
    options: const [
      OptionSymptome('mal_tete', 'Mal de tête'),
      OptionSymptome('vertiges', 'Vertiges / étourdissements'),
      OptionSymptome('trouble_vision', 'Troubles de la vision'),
      OptionSymptome('perte_conscience', 'Perte de conscience', critique: true),
      OptionSymptome('raideur_nuque', 'Raideur de la nuque avec fièvre',
          critique: true),
    ],
  ),
  QuestionDiagnostic(
    code: 'symptomes_poitrine',
    intitule: 'Quels symptômes ressentez-vous ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    condition: (r) => r['zone'] == 'poitrine',
    options: const [
      OptionSymptome('douleur_thoracique', 'Douleur dans la poitrine',
          critique: true),
      OptionSymptome('essoufflement', 'Difficulté à respirer', critique: true),
      OptionSymptome('palpitations', 'Palpitations'),
      OptionSymptome('toux', 'Toux'),
    ],
  ),
  QuestionDiagnostic(
    code: 'symptomes_ventre',
    intitule: 'Quels symptômes ressentez-vous ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    condition: (r) => r['zone'] == 'ventre',
    options: const [
      OptionSymptome('douleur_abdo', 'Douleur au ventre'),
      OptionSymptome('nausees', 'Nausées / vomissements'),
      OptionSymptome('diarrhee', 'Diarrhée'),
      OptionSymptome('sang_selles', 'Sang dans les selles ou vomissements',
          critique: true),
    ],
  ),
  QuestionDiagnostic(
    code: 'symptomes_general',
    intitule: 'Quels symptômes ressentez-vous ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    condition: (r) => r['zone'] == 'general',
    options: const [
      OptionSymptome('fievre', 'Fièvre'),
      OptionSymptome('fatigue', 'Fatigue intense'),
      OptionSymptome('frissons', 'Frissons'),
      OptionSymptome('courbatures', 'Courbatures'),
    ],
  ),
  QuestionDiagnostic(
    code: 'duree',
    intitule: 'Depuis combien de temps ressentez-vous ces symptômes ?',
    type: TypeReponse.choixUnique,
    options: const [
      OptionSymptome('moins_24h', 'Moins de 24 heures'),
      OptionSymptome('j1_3', '1 à 3 jours'),
      OptionSymptome('j3_7', '3 à 7 jours'),
      OptionSymptome('plus_semaine', 'Plus d\'une semaine'),
    ],
  ),
  const QuestionDiagnostic(
    code: 'intensite',
    intitule: 'Quelle est l\'intensité de vos symptômes ?',
    aide: '1 = légère, 5 = très forte.',
    type: TypeReponse.echelle,
  ),
  QuestionDiagnostic(
    code: 'signes_alerte',
    intitule: 'Présentez-vous l\'un de ces signes d\'alerte ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    condition: symptomeCritiquePresent,
    options: const [
      OptionSymptome('respire_repos', 'Difficulté à respirer au repos',
          critique: true),
      OptionSymptome('douleur_intense', 'Douleur intense et persistante',
          critique: true),
      OptionSymptome('confusion', 'Confusion ou somnolence inhabituelle',
          critique: true),
      OptionSymptome('levres_bleues', 'Lèvres ou ongles bleutés',
          critique: true),
      OptionSymptome('aucun_signe', 'Aucun de ces signes'),
    ],
  ),
  QuestionDiagnostic(
    code: 'antecedents',
    intitule: 'Avez-vous des antécédents médicaux ?',
    aide: 'Plusieurs choix possibles.',
    type: TypeReponse.choixMultiple,
    options: const [
      OptionSymptome('diabete', 'Diabète'),
      OptionSymptome('hypertension', 'Hypertension'),
      OptionSymptome('asthme', 'Asthme / problème respiratoire'),
      OptionSymptome('cardiaque', 'Maladie cardiaque'),
      OptionSymptome('grossesse', 'Grossesse'),
      OptionSymptome('aucun', 'Aucun'),
    ],
  ),
];

/// Vrai si au moins un symptôme marqué « critique » a été sélectionné dans les
/// questions de symptômes (utilisé pour déclencher la question de signes
/// d'alerte, puis l'évaluation de la criticité).
bool symptomeCritiquePresent(Map<String, dynamic> reponses) {
  for (final question in questionnaireSymptomes) {
    if (!codesQuestionsSymptomes.contains(question.code)) continue;
    final selection = (reponses[question.code] as List?)?.cast<String>() ??
        const <String>[];
    for (final option in question.options) {
      if (option.critique && selection.contains(option.code)) return true;
    }
  }
  return false;
}
