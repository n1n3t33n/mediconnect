import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';
import '../config/dimensions_application.dart';

/// En-tête réutilisable des écrans d'authentification :
/// icône, titre et sous-titre optionnel.
class EnteteAuthentification extends StatelessWidget {
  const EnteteAuthentification({
    super.key,
    required this.titre,
    this.sousTitre,
    this.icone = Icons.health_and_safety,
  });

  final String titre;
  final String? sousTitre;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icone, size: 64, color: CouleursApplication.primaire),
        const SizedBox(height: DimensionsApplication.espacementMoyen),
        Text(
          titre,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (sousTitre != null) ...[
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(
            sousTitre!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: CouleursApplication.texteSecondaire,
            ),
          ),
        ],
      ],
    );
  }
}
