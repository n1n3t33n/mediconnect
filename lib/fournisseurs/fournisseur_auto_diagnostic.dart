import 'package:flutter/foundation.dart';

import '../modeles/modele_auto_diagnostic.dart';
import '../modeles/modele_question_diagnostic.dart';
import '../services/questionnaire_symptomes.dart';
import '../services/service_auto_diagnostic.dart';

/// Phase courante du flux d'auto-diagnostic.
enum PhaseAutoDiagnostic { intro, questionnaire, resultat }

/// Gestion d'état du flux d'auto-diagnostic (Provider).
///
/// Pilote la progression dans le questionnaire adaptatif, mémorise les réponses
/// et déclenche l'évaluation finale.
class FournisseurAutoDiagnostic extends ChangeNotifier {
  FournisseurAutoDiagnostic({ServiceAutoDiagnostic? service})
      : _service = service ?? ServiceAutoDiagnostic();

  final ServiceAutoDiagnostic _service;
  final Map<String, dynamic> _reponses = {};
  int _indexCourant = 0;
  ResultatAutoDiagnostic? _resultat;
  bool _demarre = false;

  PhaseAutoDiagnostic get phase {
    if (_resultat != null) return PhaseAutoDiagnostic.resultat;
    if (_demarre) return PhaseAutoDiagnostic.questionnaire;
    return PhaseAutoDiagnostic.intro;
  }

  /// Questions actuellement visibles compte tenu des réponses (adaptatif).
  List<QuestionDiagnostic> get questionsVisibles =>
      questionnaireSymptomes.where((q) => q.estVisible(_reponses)).toList();

  int get nombreQuestions => questionsVisibles.length;
  int get indexCourant => _indexCourant;

  QuestionDiagnostic get questionCourante =>
      questionsVisibles[_indexCourant.clamp(0, questionsVisibles.length - 1)];

  ResultatAutoDiagnostic? get resultat => _resultat;

  double get progression =>
      nombreQuestions == 0 ? 0 : (_indexCourant + 1) / nombreQuestions;

  bool get estPremiereQuestion => _indexCourant == 0;
  bool get estDerniereQuestion => _indexCourant >= questionsVisibles.length - 1;

  dynamic reponsePour(String code) => _reponses[code];

  bool get questionCouranteRepondue {
    final question = questionCourante;
    final reponse = _reponses[question.code];
    if (reponse == null) return false;
    if (question.type == TypeReponse.choixMultiple) {
      return (reponse as List).isNotEmpty;
    }
    return true;
  }

  void demarrer() {
    _demarre = true;
    notifyListeners();
  }

  void definirReponse(String code, dynamic valeur) {
    _reponses[code] = valeur;
    notifyListeners();
  }

  /// Ajoute ou retire une option d'une réponse à choix multiple.
  void basculerOption(String code, String optionCode) {
    final selection =
        (_reponses[code] as List?)?.cast<String>().toList() ?? <String>[];
    if (selection.contains(optionCode)) {
      selection.remove(optionCode);
    } else {
      selection.add(optionCode);
    }
    _reponses[code] = selection;
    notifyListeners();
  }

  void suivant() {
    if (!estDerniereQuestion) {
      _indexCourant++;
      notifyListeners();
    }
  }

  void precedent() {
    if (_indexCourant > 0) {
      _indexCourant--;
      notifyListeners();
    }
  }

  void terminer() {
    _resultat = _service.evaluer(_reponsesVisibles());
    notifyListeners();
  }

  void recommencer() {
    _reponses.clear();
    _indexCourant = 0;
    _resultat = null;
    _demarre = false;
    notifyListeners();
  }

  /// Réponses limitées aux questions actuellement visibles (ignore d'éventuelles
  /// réponses devenues obsolètes après un changement de zone du corps).
  Map<String, dynamic> _reponsesVisibles() {
    final visibles = <String, dynamic>{};
    for (final question in questionsVisibles) {
      if (_reponses.containsKey(question.code)) {
        visibles[question.code] = _reponses[question.code];
      }
    }
    return visibles;
  }
}
