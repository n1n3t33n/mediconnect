import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../modeles/modele_ordonnance.dart';
import 'formatage_date.dart';

/// Construit le document PDF d'une ordonnance numérique (cf. cahier §7).
///
/// Le PDF est horodaté et porte un bloc de « signature électronique » simulée
/// (médecin, numéro d'ordre, code de vérification, lien de contrôle). Les polices
/// standard (Helvetica) sont utilisées afin de rester hors-ligne et léger.
class GenerateurPdfOrdonnance {
  GenerateurPdfOrdonnance._();

  static const PdfColor _primaire = PdfColor.fromInt(0xFF0B8FAC);
  static const PdfColor _texteSecondaire = PdfColor.fromInt(0xFF5C6B73);
  static const PdfColor _bordure = PdfColor.fromInt(0xFFE0E6E9);
  static const PdfColor _fondClair = PdfColor.fromInt(0xFFE1F3F8);

  /// Génère les octets du PDF prêts à être affichés, imprimés ou partagés.
  static Future<Uint8List> construire(Ordonnance ordonnance) async {
    final document = pw.Document(
      title: 'Ordonnance ${ordonnance.codeVerification}',
      author: 'MediConnect',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _enTete(),
          pw.SizedBox(height: 20),
          _blocParticipants(ordonnance),
          pw.SizedBox(height: 20),
          _titreSection('Prescription'),
          pw.SizedBox(height: 8),
          ..._medicaments(ordonnance),
          if (ordonnance.remarques != null &&
              ordonnance.remarques!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _titreSection('Remarques'),
            pw.SizedBox(height: 6),
            pw.Text(ordonnance.remarques!),
          ],
          pw.SizedBox(height: 24),
          _blocSignature(ordonnance),
        ],
        footer: (context) => _piedDePage(context),
      ),
    );

    return document.save();
  }

  static pw.Widget _enTete() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'MediConnect',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _primaire,
              ),
            ),
            pw.Text(
              'Santé connectée - Côte d\'Ivoire',
              style: pw.TextStyle(fontSize: 10, color: _texteSecondaire),
            ),
          ],
        ),
        pw.Text(
          'ORDONNANCE MÉDICALE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _primaire,
          ),
        ),
      ],
    );
  }

  static pw.Widget _blocParticipants(Ordonnance ordonnance) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _encadre(
            titre: 'Médecin',
            lignes: [
              ordonnance.medecinNom,
              ordonnance.specialite,
              if (ordonnance.etablissement != null)
                ordonnance.etablissement!,
              if (ordonnance.numeroOrdre != null)
                'Ordre n° ${ordonnance.numeroOrdre}',
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: _encadre(
            titre: 'Patient',
            lignes: [
              ordonnance.patientNom,
              'Émise le ${FormatageDate.dateHeure(ordonnance.date)}',
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _encadre({
    required String titre,
    required List<String> lignes,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _bordure),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titre.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _texteSecondaire,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 4),
          for (final ligne in lignes)
            pw.Text(ligne, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _titreSection(String titre) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: _fondClair,
      child: pw.Text(
        titre,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _primaire,
        ),
      ),
    );
  }

  static List<pw.Widget> _medicaments(Ordonnance ordonnance) {
    final widgets = <pw.Widget>[];
    for (var i = 0; i < ordonnance.medicaments.length; i++) {
      final m = ordonnance.medicaments[i];
      final details = <String>[
        m.posologie,
        if (m.duree != null && m.duree!.trim().isNotEmpty)
          'Durée : ${m.duree}',
        if (m.instructions != null && m.instructions!.trim().isNotEmpty)
          m.instructions!,
      ];
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${i + 1}. ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      m.nom,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      details.join('  -  '),
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  static pw.Widget _blocSignature(Ordonnance ordonnance) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _fondClair,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Signé électroniquement',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _primaire,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${ordonnance.medecinNom}'
            '${ordonnance.numeroOrdre != null ? ' - Ordre n° ${ordonnance.numeroOrdre}' : ''}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Le ${FormatageDate.dateHeure(ordonnance.date)}',
            style: pw.TextStyle(fontSize: 10, color: _texteSecondaire),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Code de vérification : ${ordonnance.codeVerification}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Vérifiable sur ${ordonnance.lienVerification}',
            style: pw.TextStyle(fontSize: 9, color: _texteSecondaire),
          ),
        ],
      ),
    );
  }

  static pw.Widget _piedDePage(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Page ${context.pageNumber}/${context.pagesCount} - Document généré par MediConnect',
        style: pw.TextStyle(fontSize: 8, color: _texteSecondaire),
      ),
    );
  }
}
