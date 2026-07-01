import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../modeles/modele_ordonnance.dart';
import '../../utilitaires/generateur_pdf_ordonnance.dart';

/// Aperçu du PDF horodaté de l'ordonnance, avec impression et partage intégrés
/// (barre d'actions du composant [PdfPreview], multiplateforme).
class EcranApercuOrdonnance extends StatelessWidget {
  const EcranApercuOrdonnance({super.key, required this.ordonnance});

  final Ordonnance ordonnance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aperçu de l\'ordonnance')),
      body: PdfPreview(
        build: (format) => GenerateurPdfOrdonnance.construire(ordonnance),
        pdfFileName: 'ordonnance_${ordonnance.codeVerification}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}
