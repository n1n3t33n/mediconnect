import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/carte_application.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../modeles/modele_consultation.dart';
import '../../services/service_teleconsultation.dart';
import '../../utilitaires/formatage_date.dart';
import 'ecran_detail_consultation.dart';

/// Historique des consultations passées, par profil (cf. cahier 4.4 §15,
/// 5.1 §17). Adapté au rôle : le patient voit ses consultations, le médecin
/// les siennes.
class EcranHistoriqueConsultations extends StatefulWidget {
  const EcranHistoriqueConsultations({super.key});

  @override
  State<EcranHistoriqueConsultations> createState() =>
      _EcranHistoriqueConsultationsState();
}

class _EcranHistoriqueConsultationsState
    extends State<EcranHistoriqueConsultations> {
  final _service = ServiceTeleconsultation();
  late Future<List<Consultation>> _futur;

  @override
  void initState() {
    super.initState();
    final utilisateur =
        context.read<FournisseurAuthentification>().utilisateurCourant;
    _futur = utilisateur == null
        ? Future.value(const [])
        : utilisateur.estMedecin
            ? _service.historiqueMedecin(utilisateur.id)
            : _service.historiquePatient(utilisateur.id);
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur =
        context.read<FournisseurAuthentification>().utilisateurCourant;
    final estMedecin = utilisateur?.estMedecin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes consultations')),
      body: SafeArea(
        child: FutureBuilder<List<Consultation>>(
          future: _futur,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final consultations = snapshot.data ?? const [];
            if (consultations.isEmpty) {
              return _vide(context);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
              itemCount: consultations.length,
              separatorBuilder: (_, __) => const SizedBox(
                height: DimensionsApplication.espacementMoyen,
              ),
              itemBuilder: (context, i) =>
                  _carte(context, consultations[i], estMedecin),
            );
          },
        ),
      ),
    );
  }

  Widget _carte(BuildContext context, Consultation c, bool estMedecin) {
    final textTheme = Theme.of(context).textTheme;
    final titre = estMedecin ? c.patientNom : c.medecinNom;
    final enCours = c.statut == StatutConsultation.enCours;

    return CarteApplication(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EcranDetailConsultation(consultation: c),
        ),
      ),
      enfant: Row(
        children: [
          CircleAvatar(
            backgroundColor: CouleursApplication.primaireClair,
            child: Icon(
              estMedecin ? Icons.person_outline : Icons.medical_services_outlined,
              color: CouleursApplication.primaireFonce,
            ),
          ),
          const SizedBox(width: DimensionsApplication.espacementMoyen),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  FormatageDate.dateHeure(c.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: CouleursApplication.texteSecondaire,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enCours
                      ? 'En cours'
                      : c.aSynthese
                          ? 'Synthèse disponible'
                          : 'Terminée',
                  style: textTheme.bodySmall?.copyWith(
                    color: enCours
                        ? CouleursApplication.avertissement
                        : CouleursApplication.succes,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: CouleursApplication.texteTertiaire),
        ],
      ),
    );
  }

  Widget _vide(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history,
                size: 56, color: CouleursApplication.texteTertiaire),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            Text(
              'Aucune consultation pour le moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CouleursApplication.texteSecondaire,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
