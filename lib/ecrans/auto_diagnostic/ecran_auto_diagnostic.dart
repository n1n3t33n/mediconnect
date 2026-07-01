import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../fournisseurs/fournisseur_auto_diagnostic.dart';
import 'vue_intro_auto_diagnostic.dart';
import 'vue_questionnaire.dart';
import 'vue_resultat_auto_diagnostic.dart';

/// Écran conteneur de l'auto-diagnostic : aiguille entre l'introduction, le
/// questionnaire adaptatif et le résultat selon la phase du flux.
class EcranAutoDiagnostic extends StatelessWidget {
  const EcranAutoDiagnostic({super.key});

  @override
  Widget build(BuildContext context) {
    final phase = context.watch<FournisseurAutoDiagnostic>().phase;

    final (String titre, Widget corps) = switch (phase) {
      PhaseAutoDiagnostic.intro => (
          'Auto-diagnostic',
          const VueIntroAutoDiagnostic(),
        ),
      PhaseAutoDiagnostic.questionnaire => (
          'Questionnaire',
          const VueQuestionnaire(),
        ),
      PhaseAutoDiagnostic.resultat => (
          'Votre orientation',
          const VueResultatAutoDiagnostic(),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: SafeArea(child: corps),
    );
  }
}
