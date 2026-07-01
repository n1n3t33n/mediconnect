import 'package:flutter/material.dart';

import '../config/couleurs_application.dart';

/// Affiche une note moyenne sous forme d'étoile + valeur, avec un nombre d'avis
/// optionnel (cf. cahier 4.3 : note moyenne si avis activés).
class NoteEtoiles extends StatelessWidget {
  const NoteEtoiles({
    super.key,
    required this.note,
    this.nombreAvis,
    this.taille = 16,
  });

  final double note;
  final int? nombreAvis;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: taille + 2, color: CouleursApplication.accent),
        const SizedBox(width: 4),
        Text(
          note.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: taille),
        ),
        if (nombreAvis != null)
          Text(
            ' ($nombreAvis avis)',
            style: TextStyle(
              fontSize: taille - 2,
              color: CouleursApplication.texteSecondaire,
            ),
          ),
      ],
    );
  }
}
