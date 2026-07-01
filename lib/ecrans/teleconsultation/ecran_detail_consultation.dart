import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../modeles/modele_consultation.dart';
import '../../modeles/modele_ordonnance.dart';
import '../../services/service_ordonnance.dart';
import '../../utilitaires/formatage_date.dart';
import '../ordonnance/ecran_ordonnance.dart';
import '../ordonnance/ecran_redaction_ordonnance.dart';

/// Détail d'une consultation : participants, synthèse du médecin, pré-diagnostic
/// et ordonnance (rédaction côté médecin, réception côté patient).
class EcranDetailConsultation extends StatefulWidget {
  const EcranDetailConsultation({super.key, required this.consultation});

  final Consultation consultation;

  @override
  State<EcranDetailConsultation> createState() =>
      _EcranDetailConsultationState();
}

class _EcranDetailConsultationState extends State<EcranDetailConsultation> {
  final _serviceOrdonnance = ServiceOrdonnance();
  late Future<Ordonnance?> _futurOrdonnance;

  @override
  void initState() {
    super.initState();
    _recharger();
  }

  void _recharger() {
    setState(() {
      _futurOrdonnance = _serviceOrdonnance
          .ordonnancePourConsultation(widget.consultation.id);
    });
  }

  Future<void> _redigerOrdonnance() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EcranRedactionOrdonnance(consultation: widget.consultation),
      ),
    );
    if (mounted) _recharger();
  }

  @override
  Widget build(BuildContext context) {
    final consultation = widget.consultation;
    final dureeMin = (consultation.dureeSecondes / 60).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation')),
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
                  CarteApplication(
                    enfant: Column(
                      children: [
                        _ligne(Icons.person_outline, 'Patient',
                            consultation.patientNom),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.medical_services_outlined, 'Médecin',
                            '${consultation.medecinNom} · ${consultation.specialite}'),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.event_outlined, 'Date',
                            FormatageDate.dateHeure(consultation.date)),
                        const Divider(
                            height: DimensionsApplication.espacementGrand),
                        _ligne(Icons.timer_outlined, 'Durée',
                            '$dureeMin min · ${consultation.type.libelle}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _bloc(
                    context,
                    titre: 'Synthèse du médecin',
                    icone: Icons.notes_outlined,
                    contenu: consultation.aSynthese
                        ? consultation.synthese!
                        : 'Synthèse en attente du médecin.',
                  ),
                  if (consultation.resumeAutoDiagnostic != null) ...[
                    const SizedBox(
                        height: DimensionsApplication.espacementMoyen),
                    _bloc(
                      context,
                      titre: 'Pré-diagnostic transmis',
                      icone: Icons.assignment_outlined,
                      contenu: consultation.resumeAutoDiagnostic!,
                    ),
                  ],
                  const SizedBox(height: DimensionsApplication.espacementMoyen),
                  _sectionOrdonnance(context),
                  const SizedBox(height: DimensionsApplication.espacementGrand),
                  BoutonSecondaire(
                    libelle: 'Retour à l\'accueil',
                    icone: Icons.home_outlined,
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionOrdonnance(BuildContext context) {
    final estMedecin = context
            .read<FournisseurAuthentification>()
            .utilisateurCourant
            ?.estMedecin ??
        false;

    return FutureBuilder<Ordonnance?>(
      future: _futurOrdonnance,
      builder: (context, snapshot) {
        final enChargement =
            snapshot.connectionState != ConnectionState.done;
        final ordonnance = snapshot.data;

        return CarteApplication(
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 20, color: CouleursApplication.primaire),
                  const SizedBox(width: DimensionsApplication.espacementPetit),
                  Text(
                    'Ordonnance',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: DimensionsApplication.espacementPetit),
              if (enChargement)
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: DimensionsApplication.espacementPetit),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (ordonnance != null) ...[
                Text(
                  '${ordonnance.medicaments.length} médicament'
                  '${ordonnance.medicaments.length > 1 ? 's' : ''} · '
                  'émise le ${FormatageDate.dateHeure(ordonnance.date)}',
                ),
                const SizedBox(height: DimensionsApplication.espacementMoyen),
                BoutonPrincipal(
                  libelle: 'Voir l\'ordonnance',
                  icone: Icons.visibility_outlined,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EcranOrdonnance(ordonnance: ordonnance),
                    ),
                  ),
                ),
              ] else if (estMedecin) ...[
                const Text('Aucune ordonnance émise pour cette consultation.'),
                const SizedBox(height: DimensionsApplication.espacementMoyen),
                BoutonPrincipal(
                  libelle: 'Rédiger une ordonnance',
                  icone: Icons.edit_outlined,
                  onPressed: _redigerOrdonnance,
                ),
              ] else
                const Text(
                  'Aucune ordonnance n\'a encore été émise pour cette '
                  'consultation.',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bloc(
    BuildContext context, {
    required String titre,
    required IconData icone,
    required String contenu,
  }) {
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: CouleursApplication.primaire),
              const SizedBox(width: DimensionsApplication.espacementPetit),
              Text(
                titre,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          Text(contenu),
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String libelle, String valeur) {
    return Row(
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
