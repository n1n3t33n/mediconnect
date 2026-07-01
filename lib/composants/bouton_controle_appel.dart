import 'package:flutter/material.dart';

/// Bouton rond de contrôle pendant un appel (micro, caméra, raccrocher…).
class BoutonControleAppel extends StatelessWidget {
  const BoutonControleAppel({
    super.key,
    required this.icone,
    required this.onPressed,
    this.libelle,
    this.couleurIcone = Colors.white,
    this.couleurFond = Colors.white24,
    this.taille = 56,
  });

  final IconData icone;
  final VoidCallback? onPressed;
  final String? libelle;
  final Color couleurIcone;
  final Color couleurFond;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: couleurFond,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: taille,
              height: taille,
              child: Icon(icone, color: couleurIcone),
            ),
          ),
        ),
        if (libelle != null) ...[
          const SizedBox(height: 6),
          Text(
            libelle!,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
