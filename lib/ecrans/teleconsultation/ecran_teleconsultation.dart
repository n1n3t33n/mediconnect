import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_controle_appel.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../fournisseurs/fournisseur_teleconsultation.dart';
import '../../modeles/modele_consultation.dart';
import 'ecran_detail_consultation.dart';
import 'ecran_synthese_consultation.dart';

/// Fond sombre de l'écran d'appel.
const Color _fondAppel = Color(0xFF07333F);

/// Écran de téléconsultation (appel audio/vidéo **simulé**).
class EcranTeleconsultation extends StatelessWidget {
  const EcranTeleconsultation({super.key, required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FournisseurTeleconsultation()..demarrer(consultation),
      child: const _VueAppel(),
    );
  }
}

class _VueAppel extends StatelessWidget {
  const _VueAppel();

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FournisseurTeleconsultation>();
    final consultation = f.consultation;
    final estMedecin =
        context.read<FournisseurAuthentification>().utilisateurCourant?.estMedecin ??
            false;
    // Le participant affiché est « l'autre » : le médecin côté patient, le
    // patient côté médecin.
    final nomParticipant = estMedecin
        ? (consultation?.patientNom ?? 'Patient')
        : (consultation?.medecinNom ?? 'Médecin');
    final sousTitre =
        estMedecin ? 'Patient' : (consultation?.specialite ?? '');

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _fondAppel,
        body: SafeArea(
          child: Column(
            children: [
              _enTete(context, f, nomParticipant, sousTitre),
              Expanded(child: _zoneVideo(context, f, nomParticipant)),
              _controles(context, f, estMedecin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _enTete(
    BuildContext context,
    FournisseurTeleconsultation f,
    String nomParticipant,
    String sousTitre,
  ) {
    final statut = switch (f.etat) {
      EtatAppel.connexion => 'Connexion…',
      EtatAppel.reconnexion => 'Reconnexion…',
      EtatAppel.enCours => f.dureeLisible,
      EtatAppel.termine => 'Terminé',
    };

    return Padding(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomParticipant,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sousTitre.isNotEmpty)
                  Text(sousTitre,
                      style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                f.etat == EtatAppel.enCours
                    ? Icons.circle
                    : Icons.circle_outlined,
                size: 10,
                color: f.etat == EtatAppel.enCours
                    ? CouleursApplication.succes
                    : CouleursApplication.avertissement,
              ),
              const SizedBox(width: 6),
              Text(statut, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneVideo(
    BuildContext context,
    FournisseurTeleconsultation f,
    String nomParticipant,
  ) {
    if (f.etat == EtatAppel.connexion) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: DimensionsApplication.espacementMoyen),
            Text('Établissement de l\'appel…',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white12,
                child: Icon(
                  f.modeAudioSeul ? Icons.graphic_eq : Icons.videocam_outlined,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: DimensionsApplication.espacementMoyen),
              Text(
                f.modeAudioSeul ? 'Mode audio seul' : 'Vidéo (simulée)',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        if (f.etat == EtatAppel.reconnexion)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: CouleursApplication.avertissement,
              child: Padding(
                padding: EdgeInsets.all(DimensionsApplication.espacementPetit),
                child: Text(
                  'Connexion instable — reprise de l\'appel…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        Positioned(
          right: DimensionsApplication.espacementMoyen,
          bottom: DimensionsApplication.espacementMoyen,
          child: Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius:
                  BorderRadius.circular(DimensionsApplication.rayonMoyen),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              f.cameraActive ? Icons.person : Icons.videocam_off,
              color: Colors.white54,
            ),
          ),
        ),
        Positioned(
          left: DimensionsApplication.espacementMoyen,
          bottom: DimensionsApplication.espacementMoyen,
          child: TextButton.icon(
            onPressed: () => _afficherPreDiagnostic(context, f.consultation),
            icon: const Icon(Icons.assignment_outlined, color: Colors.white),
            label: const Text('Pré-diagnostic',
                style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.white10),
          ),
        ),
      ],
    );
  }

  Widget _controles(
    BuildContext context,
    FournisseurTeleconsultation f,
    bool estMedecin,
  ) {
    final actif = f.etat == EtatAppel.enCours || f.etat == EtatAppel.reconnexion;
    return Padding(
      padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BoutonControleAppel(
                icone: f.microActif ? Icons.mic : Icons.mic_off,
                libelle: f.microActif ? 'Micro' : 'Muet',
                couleurFond: f.microActif ? Colors.white24 : Colors.white,
                couleurIcone:
                    f.microActif ? Colors.white : CouleursApplication.textePrincipal,
                onPressed: actif ? f.basculerMicro : null,
              ),
              BoutonControleAppel(
                icone: f.cameraActive ? Icons.videocam : Icons.videocam_off,
                libelle: 'Caméra',
                couleurFond: f.cameraActive ? Colors.white24 : Colors.white,
                couleurIcone: f.cameraActive
                    ? Colors.white
                    : CouleursApplication.textePrincipal,
                onPressed: actif && !f.modeAudioSeul ? f.basculerCamera : null,
              ),
              BoutonControleAppel(
                icone: f.modeAudioSeul ? Icons.videocam : Icons.graphic_eq,
                libelle: f.modeAudioSeul ? 'Vidéo' : 'Audio',
                onPressed: actif ? f.basculerModeAudio : null,
              ),
              BoutonControleAppel(
                icone: Icons.wifi_off,
                libelle: 'Coupure',
                onPressed: actif ? f.simulerCoupure : null,
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementGrand),
          BoutonControleAppel(
            icone: Icons.call_end,
            libelle: 'Raccrocher',
            taille: 68,
            couleurFond: CouleursApplication.danger,
            onPressed: () => _raccrocher(context, estMedecin),
          ),
        ],
      ),
    );
  }

  Future<void> _raccrocher(BuildContext context, bool estMedecin) async {
    final f = context.read<FournisseurTeleconsultation>();

    if (estMedecin) {
      final consultation = await f.terminer();
      if (!context.mounted || consultation == null) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              EcranSyntheseConsultation(consultation: consultation),
        ),
      );
    } else {
      // Côté patient : le médecin est censé rédiger la synthèse. Pour la
      // démonstration, une synthèse simulée est enregistrée.
      final consultation = await f.terminer(synthese: _syntheseSimulee());
      if (!context.mounted || consultation == null) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EcranDetailConsultation(consultation: consultation),
        ),
      );
    }
  }

  String _syntheseSimulee() {
    return 'Consultation réalisée par téléconsultation. Symptômes évalués, '
        'aucun signe de gravité immédiate identifié à distance. Repos, '
        'hydratation et surveillance conseillés. Reconsulter en cas '
        'd\'aggravation.';
  }

  void _afficherPreDiagnostic(BuildContext context, Consultation? consultation) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pré-diagnostic du patient',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            Text(
              consultation?.resumeAutoDiagnostic ??
                  'Aucun auto-diagnostic n\'a été transmis pour cette '
                      'consultation.',
            ),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            const Text(
              'L\'historique des consultations est disponible dans « Mes '
              'consultations ».',
              style: TextStyle(color: CouleursApplication.texteSecondaire),
            ),
          ],
        ),
      ),
    );
  }
}
