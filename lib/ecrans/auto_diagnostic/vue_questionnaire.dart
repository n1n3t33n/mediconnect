import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/option_selectionnable.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_auto_diagnostic.dart';
import '../../modeles/modele_question_diagnostic.dart';

/// Vue d'une question du questionnaire adaptatif, avec barre de progression et
/// navigation précédent / suivant.
class VueQuestionnaire extends StatelessWidget {
  const VueQuestionnaire({super.key});

  @override
  Widget build(BuildContext context) {
    final fournisseur = context.watch<FournisseurAutoDiagnostic>();
    final question = fournisseur.questionCourante;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _progression(context, fournisseur),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DimensionsApplication.espacementGrand,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: DimensionsApplication.largeurMaxContenu,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question.intitule,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (question.aide != null) ...[
                      const SizedBox(
                          height: DimensionsApplication.espacementTresPetit),
                      Text(
                        question.aide!,
                        style: textTheme.bodySmall?.copyWith(
                          color: CouleursApplication.texteSecondaire,
                        ),
                      ),
                    ],
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    _corpsQuestion(context, fournisseur, question),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                  ],
                ),
              ),
            ),
          ),
        ),
        _navigation(context, fournisseur),
      ],
    );
  }

  Widget _progression(BuildContext context, FournisseurAutoDiagnostic f) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DimensionsApplication.espacementGrand,
        DimensionsApplication.espacementMoyen,
        DimensionsApplication.espacementGrand,
        DimensionsApplication.espacementPetit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${f.indexCourant + 1} sur ${f.nombreQuestions}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CouleursApplication.texteSecondaire,
                ),
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(DimensionsApplication.rayonComplet),
            child: LinearProgressIndicator(
              value: f.progression,
              minHeight: 8,
              backgroundColor: CouleursApplication.bordure,
              color: CouleursApplication.primaire,
            ),
          ),
        ],
      ),
    );
  }

  Widget _corpsQuestion(
    BuildContext context,
    FournisseurAutoDiagnostic f,
    QuestionDiagnostic question,
  ) {
    switch (question.type) {
      case TypeReponse.choixUnique:
        final selection = f.reponsePour(question.code) as String?;
        return Column(
          children: [
            for (final option in question.options)
              OptionSelectionnable(
                libelle: option.libelle,
                selectionnee: selection == option.code,
                multiple: false,
                onTap: () => f.definirReponse(question.code, option.code),
              ),
          ],
        );
      case TypeReponse.choixMultiple:
        final selection =
            (f.reponsePour(question.code) as List?)?.cast<String>() ??
                const <String>[];
        return Column(
          children: [
            for (final option in question.options)
              OptionSelectionnable(
                libelle: option.libelle,
                selectionnee: selection.contains(option.code),
                multiple: true,
                onTap: () => f.basculerOption(question.code, option.code),
              ),
          ],
        );
      case TypeReponse.echelle:
        return _echelle(context, f, question);
    }
  }

  Widget _echelle(
    BuildContext context,
    FournisseurAutoDiagnostic f,
    QuestionDiagnostic question,
  ) {
    final valeur = f.reponsePour(question.code) as int?;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var n = 1; n <= 5; n++)
              _bulleEchelle(
                n,
                valeur == n,
                () => f.definirReponse(question.code, n),
              ),
          ],
        ),
        const SizedBox(height: DimensionsApplication.espacementPetit),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Légère',
                style: Theme.of(context).textTheme.bodySmall),
            Text('Très forte',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _bulleEchelle(int valeur, bool selectionnee, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectionnee
              ? CouleursApplication.primaire
              : CouleursApplication.surface,
          border: Border.all(
            color: selectionnee
                ? CouleursApplication.primaire
                : CouleursApplication.bordure,
            width: selectionnee ? 2 : 1,
          ),
        ),
        child: Text(
          '$valeur',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selectionnee ? Colors.white : CouleursApplication.textePrincipal,
          ),
        ),
      ),
    );
  }

  Widget _navigation(BuildContext context, FournisseurAutoDiagnostic f) {
    return Padding(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      child: Row(
        children: [
          if (!f.estPremiereQuestion) ...[
            Expanded(
              child: BoutonSecondaire(
                libelle: 'Précédent',
                onPressed: f.precedent,
              ),
            ),
            const SizedBox(width: DimensionsApplication.espacementMoyen),
          ],
          Expanded(
            child: BoutonPrincipal(
              libelle:
                  f.estDerniereQuestion ? 'Voir mon orientation' : 'Suivant',
              onPressed: f.questionCouranteRepondue
                  ? () => f.estDerniereQuestion ? f.terminer() : f.suivant()
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
