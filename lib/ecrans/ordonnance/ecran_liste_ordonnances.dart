import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/carte_ordonnance.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../modeles/modele_ordonnance.dart';
import '../../services/service_ordonnance.dart';
import 'ecran_ordonnance.dart';

/// Liste « Mes ordonnances » : le patient y retrouve ses ordonnances reçues, le
/// médecin celles qu'il a émises (cf. cahier §7 : réception patient).
class EcranListeOrdonnances extends StatefulWidget {
  const EcranListeOrdonnances({super.key});

  @override
  State<EcranListeOrdonnances> createState() => _EcranListeOrdonnancesState();
}

class _EcranListeOrdonnancesState extends State<EcranListeOrdonnances> {
  final _service = ServiceOrdonnance();
  late Future<List<Ordonnance>> _futur;
  bool _estMedecin = false;

  @override
  void initState() {
    super.initState();
    final utilisateur =
        context.read<FournisseurAuthentification>().utilisateurCourant;
    _estMedecin = utilisateur?.estMedecin ?? false;
    _futur = utilisateur == null
        ? Future.value(const [])
        : _estMedecin
            ? _service.ordonnancesMedecin(utilisateur.id)
            : _service.ordonnancesPatient(utilisateur.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes ordonnances')),
      body: SafeArea(
        child: FutureBuilder<List<Ordonnance>>(
          future: _futur,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final ordonnances = snapshot.data ?? const [];
            if (ordonnances.isEmpty) {
              return _vide(context);
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.all(DimensionsApplication.espacementGrand),
              itemCount: ordonnances.length,
              separatorBuilder: (_, __) => const SizedBox(
                height: DimensionsApplication.espacementMoyen,
              ),
              itemBuilder: (context, i) => CarteOrdonnance(
                ordonnance: ordonnances[i],
                estMedecin: _estMedecin,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EcranOrdonnance(ordonnance: ordonnances[i]),
                  ),
                ),
              ),
            );
          },
        ),
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
            const Icon(Icons.receipt_long_outlined,
                size: 56, color: CouleursApplication.texteTertiaire),
            const SizedBox(height: DimensionsApplication.espacementMoyen),
            Text(
              'Aucune ordonnance pour le moment.',
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
