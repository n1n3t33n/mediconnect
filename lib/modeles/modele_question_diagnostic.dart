/// Type de réponse attendu pour une question du questionnaire d'auto-diagnostic.
enum TypeReponse { choixUnique, choixMultiple, echelle }

/// Une option de réponse. [critique] signale un symptôme d'alerte (« red flag »)
/// qui pèse fortement dans l'évaluation de la criticité.
class OptionSymptome {
  const OptionSymptome(this.code, this.libelle, {this.critique = false});

  final String code;
  final String libelle;
  final bool critique;
}

/// Une question du questionnaire d'auto-diagnostic.
///
/// Le caractère **adaptatif** est porté par [condition] : une question n'est
/// affichée que si la condition (évaluée sur les réponses déjà données) est
/// vraie. Les questions sans condition sont toujours affichées.
class QuestionDiagnostic {
  const QuestionDiagnostic({
    required this.code,
    required this.intitule,
    required this.type,
    this.options = const [],
    this.aide,
    this.condition,
  });

  final String code;
  final String intitule;
  final String? aide;
  final TypeReponse type;
  final List<OptionSymptome> options;
  final bool Function(Map<String, dynamic> reponses)? condition;

  bool estVisible(Map<String, dynamic> reponses) =>
      condition?.call(reponses) ?? true;
}
