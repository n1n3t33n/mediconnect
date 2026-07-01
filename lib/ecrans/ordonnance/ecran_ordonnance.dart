import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../modeles/modele_ordonnance.dart';
import '../../utilitaires/formatage_date.dart';
import '../../utilitaires/generateur_pdf_ordonnance.dart';
import 'ecran_apercu_ordonnance.dart';
import 'ecran_partage_ordonnance.dart';

/// Affiche une ordonnance finalisée (réception patient / relecture médecin) et
/// donne accès au PDF horodaté, à l'impression et au partage (QR / lien).
class EcranOrdonnance extends StatelessWidget {
  const EcranOrdonnance({super.key, required this.ordonnance});

  final Ordonnance ordonnance;

  Future<void> _partagerPdf(BuildContext context) async {
    final octets = await GenerateurPdfOrdonnance.construire(ordonnance);
    await Printing.sharePdf(
      bytes: octets,
      filename: 'ordonnance_${ordonnance.codeVerification}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordonnance')),
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
                  _enTete(context),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _blocPrescription(context),
                  if (ordonnance.remarques != null &&
                      ordonnance.remarques!.trim().isNotEmpty) ...[
                    const SizedBox(
                        height: DimensionsApplication.espacementMoyen),
                    _blocRemarques(context),
                  ],
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _blocSignature(context),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonPrincipal(
                    libelle: 'Aperçu / Imprimer le PDF',
                    icone: Icons.picture_as_pdf_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EcranApercuOrdonnance(ordonnance: ordonnance),
                      ),
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementPetit),
                  BoutonSecondaire(
                    libelle: 'Partager le PDF',
                    icone: Icons.ios_share,
                    onPressed: () => _partagerPdf(context),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementPetit),
                  BoutonSecondaire(
                    libelle: 'Partager par QR / lien',
                    icone: Icons.qr_code_2,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EcranPartageOrdonnance(ordonnance: ordonnance),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _enTete(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: CouleursApplication.primaire),
              const SizedBox(width: DimensionsApplication.espacementPetit),
              Text(
                'Ordonnance médicale',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: DimensionsApplication.espacementGrand),
          _ligne(Icons.medical_services_outlined, 'Médecin',
              '${ordonnance.medecinNom} · ${ordonnance.specialite}'),
          if (ordonnance.etablissement != null) ...[
            const SizedBox(height: DimensionsApplication.espacementPetit),
            _ligne(Icons.local_hospital_outlined, 'Établissement',
                ordonnance.etablissement!),
          ],
          const SizedBox(height: DimensionsApplication.espacementPetit),
          _ligne(Icons.person_outline, 'Patient', ordonnance.patientNom),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          _ligne(Icons.event_outlined, 'Émise le',
              FormatageDate.dateHeure(ordonnance.date)),
        ],
      ),
    );
  }

  Widget _blocPrescription(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prescription',
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          for (var i = 0; i < ordonnance.medicaments.length; i++) ...[
            if (i > 0)
              const Divider(height: DimensionsApplication.espacementGrand),
            _medicament(context, i + 1, ordonnance.medicaments[i]),
          ],
        ],
      ),
    );
  }

  Widget _medicament(BuildContext context, int numero, LigneMedicament m) {
    final textTheme = Theme.of(context).textTheme;
    final details = <String>[
      m.posologie,
      if (m.duree != null && m.duree!.trim().isNotEmpty) 'Durée : ${m.duree}',
      if (m.instructions != null && m.instructions!.trim().isNotEmpty)
        m.instructions!,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$numero. ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.nom,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                details.join('  •  '),
                style: textTheme.bodyMedium?.copyWith(
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _blocRemarques(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remarques',
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(ordonnance.remarques!),
        ],
      ),
    );
  }

  Widget _blocSignature(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CarteApplication(
      rembourrage: const EdgeInsets.all(DimensionsApplication.espacementMoyen),
      enfant: Container(
        padding: const EdgeInsets.all(DimensionsApplication.espacementMoyen),
        decoration: BoxDecoration(
          color: CouleursApplication.primaireClair,
          borderRadius:
              BorderRadius.circular(DimensionsApplication.rayonMoyen),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    color: CouleursApplication.primaireFonce, size: 20),
                const SizedBox(width: DimensionsApplication.espacementPetit),
                Text(
                  'Signé électroniquement',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CouleursApplication.primaireFonce,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DimensionsApplication.espacementPetit),
            Text(
              ordonnance.numeroOrdre != null
                  ? '${ordonnance.medecinNom} · Ordre n° ${ordonnance.numeroOrdre}'
                  : ordonnance.medecinNom,
            ),
            Text(
              'Code de vérification : ${ordonnance.codeVerification}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              ordonnance.lienVerification,
              style: textTheme.bodySmall?.copyWith(
                color: CouleursApplication.texteSecondaire,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligne(IconData icone, String libelle, String valeur) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 20, color: CouleursApplication.primaire),
        const SizedBox(width: DimensionsApplication.espacementMoyen),
        Text('$libelle : ',
            style: const TextStyle(color: CouleursApplication.texteSecondaire)),
        Expanded(
          child: Text(valeur,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
