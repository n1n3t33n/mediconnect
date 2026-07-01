import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/carte_application.dart';
import '../../config/constantes_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_auto_diagnostic.dart';

/// Introduction du questionnaire d'auto-diagnostic : présentation et
/// avertissement (« ce n'est pas un diagnostic »).
class VueIntroAutoDiagnostic extends StatelessWidget {
  const VueIntroAutoDiagnostic({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DimensionsApplication.largeurMaxContenu,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DimensionsApplication.espacementMoyen),
              const Icon(
                Icons.fact_check_outlined,
                size: 72,
                color: CouleursApplication.primaire,
              ),
              const SizedBox(height: DimensionsApplication.espacementMoyen),
              Text(
                'Auto-diagnostic guidé',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DimensionsApplication.espacementPetit),
              Text(
                'Répondez à quelques questions sur vos symptômes pour obtenir '
                'une orientation adaptée. Cela prend environ 2 minutes.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
              const SizedBox(height: DimensionsApplication.espacementGrand),
              _avertissement(),
              const SizedBox(height: DimensionsApplication.espacementGrand),
              BoutonPrincipal(
                libelle: 'Commencer le questionnaire',
                icone: Icons.arrow_forward,
                onPressed: () =>
                    context.read<FournisseurAutoDiagnostic>().demarrer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avertissement() {
    return CarteApplication(
      enfant: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: CouleursApplication.avertissement),
          SizedBox(width: DimensionsApplication.espacementPetit),
          Expanded(
            child: Text(ConstantesApplication.avertissementAutoDiagnostic),
          ),
        ],
      ),
    );
  }
}
