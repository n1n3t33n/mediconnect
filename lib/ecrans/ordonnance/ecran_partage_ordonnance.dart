import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../modeles/modele_ordonnance.dart';
import '../../utilitaires/generateur_pdf_ordonnance.dart';

/// Partage d'une ordonnance : QR code et lien de vérification, plus partage du
/// PDF (cf. cahier §7 : partage QR / lien).
class EcranPartageOrdonnance extends StatelessWidget {
  const EcranPartageOrdonnance({super.key, required this.ordonnance});

  final Ordonnance ordonnance;

  Future<void> _copierLien(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: ordonnance.lienVerification));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lien copié dans le presse-papiers.')),
    );
  }

  Future<void> _partagerPdf() async {
    final octets = await GenerateurPdfOrdonnance.construire(ordonnance);
    await Printing.sharePdf(
      bytes: octets,
      filename: 'ordonnance_${ordonnance.codeVerification}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Partager l\'ordonnance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DimensionsApplication.largeurMaxContenu,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Le patient peut scanner ce QR code ou ouvrir le lien pour '
                    'retrouver et vérifier son ordonnance.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: CouleursApplication.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  CarteApplication(
                    rembourrage: const EdgeInsets.all(
                        DimensionsApplication.espacementGrand),
                    enfant: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              DimensionsApplication.espacementMoyen),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                DimensionsApplication.rayonMoyen),
                            border: Border.all(
                                color: CouleursApplication.bordure),
                          ),
                          child: QrImageView(
                            data: ordonnance.lienVerification,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(
                            height: DimensionsApplication.espacementMoyen),
                        Text(
                          'Code de vérification',
                          style: textTheme.bodySmall?.copyWith(
                            color: CouleursApplication.texteSecondaire,
                          ),
                        ),
                        Text(
                          ordonnance.codeVerification,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: CouleursApplication.primaireFonce,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  CarteApplication(
                    enfant: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ordonnance.lienVerification,
                            style: textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copier le lien',
                          icon: const Icon(Icons.copy_outlined,
                              color: CouleursApplication.primaire),
                          onPressed: () => _copierLien(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonPrincipal(
                    libelle: 'Partager le PDF',
                    icone: Icons.ios_share,
                    onPressed: _partagerPdf,
                  ),
                  const SizedBox(height: DimensionsApplication.espacementPetit),
                  BoutonSecondaire(
                    libelle: 'Copier le lien',
                    icone: Icons.link,
                    onPressed: () => _copierLien(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
