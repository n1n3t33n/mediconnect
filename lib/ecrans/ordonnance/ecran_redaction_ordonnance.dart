import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../composants/champ_texte.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../modeles/modele_consultation.dart';
import '../../modeles/modele_ordonnance.dart';
import '../../services/service_ordonnance.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_ordonnance.dart';

/// Rédaction d'une ordonnance par le médecin à l'issue d'une consultation
/// (cf. cahier §7 : génération de l'ordonnance).
class EcranRedactionOrdonnance extends StatefulWidget {
  const EcranRedactionOrdonnance({super.key, required this.consultation});

  final Consultation consultation;

  @override
  State<EcranRedactionOrdonnance> createState() =>
      _EcranRedactionOrdonnanceState();
}

/// Brouillon d'une ligne de médicament : regroupe les contrôleurs de saisie.
class _LigneBrouillon {
  final nom = TextEditingController();
  final posologie = TextEditingController();
  final duree = TextEditingController();
  final instructions = TextEditingController();

  void liberer() {
    nom.dispose();
    posologie.dispose();
    duree.dispose();
    instructions.dispose();
  }
}

class _EcranRedactionOrdonnanceState extends State<EcranRedactionOrdonnance> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurRemarques = TextEditingController();
  final _service = ServiceOrdonnance();
  final List<_LigneBrouillon> _lignes = [_LigneBrouillon()];
  bool _enCours = false;

  @override
  void dispose() {
    _controleurRemarques.dispose();
    for (final ligne in _lignes) {
      ligne.liberer();
    }
    super.dispose();
  }

  void _ajouterLigne() {
    setState(() => _lignes.add(_LigneBrouillon()));
  }

  void _supprimerLigne(int index) {
    setState(() {
      _lignes.removeAt(index).liberer();
    });
  }

  Future<void> _generer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    final utilisateur =
        context.read<FournisseurAuthentification>().utilisateurCourant;
    if (utilisateur == null) return;

    setState(() => _enCours = true);

    final medicaments = _lignes
        .map(
          (l) => LigneMedicament(
            nom: l.nom.text.trim(),
            posologie: l.posologie.text.trim(),
            duree: l.duree.text.trim().isEmpty ? null : l.duree.text.trim(),
            instructions: l.instructions.text.trim().isEmpty
                ? null
                : l.instructions.text.trim(),
          ),
        )
        .toList();

    final consultation = widget.consultation;
    final ordonnance = Ordonnance.nouvelle(
      consultationId: consultation.id,
      patientId: consultation.patientId,
      patientNom: consultation.patientNom,
      medecinId: consultation.medecinId,
      medecinNom: consultation.medecinNom,
      specialite: consultation.specialite,
      medicaments: medicaments,
      numeroOrdre: utilisateur.numeroOrdre,
      etablissement: utilisateur.etablissement,
      remarques: _controleurRemarques.text.trim().isEmpty
          ? null
          : _controleurRemarques.text.trim(),
    );

    await _service.creerOrdonnance(ordonnance);
    if (!mounted) return;
    setState(() => _enCours = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EcranOrdonnance(ordonnance: ordonnance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rédiger une ordonnance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DimensionsApplication.largeurMaxContenu,
              ),
              child: Form(
                key: _cleFormulaire,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ordonnance pour ${widget.consultation.patientNom}',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementPetit),
                    Text(
                      'Ajoutez les médicaments prescrits. L\'ordonnance sera '
                      'horodatée et signée électroniquement, puis transmise au '
                      'patient.',
                      style: textTheme.bodySmall?.copyWith(
                        color: CouleursApplication.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    for (var i = 0; i < _lignes.length; i++) ...[
                      _carteMedicament(i, textTheme),
                      const SizedBox(
                          height: DimensionsApplication.espacementMoyen),
                    ],
                    BoutonSecondaire(
                      libelle: 'Ajouter un médicament',
                      icone: Icons.add,
                      onPressed: _ajouterLigne,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    TextFormField(
                      controller: _controleurRemarques,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Remarques / conseils (optionnel)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: 'Générer l\'ordonnance',
                      icone: Icons.receipt_long,
                      enChargement: _enCours,
                      onPressed: _generer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _carteMedicament(int index, TextTheme textTheme) {
    final ligne = _lignes[index];
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Médicament ${index + 1}',
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (_lignes.length > 1)
                IconButton(
                  tooltip: 'Supprimer',
                  icon: const Icon(Icons.delete_outline,
                      color: CouleursApplication.danger),
                  onPressed: () => _supprimerLigne(index),
                ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          ChampTexte(
            libelle: 'Nom du médicament',
            indication: 'Ex. Paracétamol 500 mg',
            controleur: ligne.nom,
            icone: Icons.medication_outlined,
            validateur: Validateurs.champObligatoire,
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          ChampTexte(
            libelle: 'Posologie',
            indication: 'Ex. 1 comprimé matin et soir',
            controleur: ligne.posologie,
            validateur: Validateurs.champObligatoire,
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          ChampTexte(
            libelle: 'Durée (optionnel)',
            indication: 'Ex. 5 jours',
            controleur: ligne.duree,
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          ChampTexte(
            libelle: 'Instructions (optionnel)',
            indication: 'Ex. à prendre pendant les repas',
            controleur: ligne.instructions,
          ),
        ],
      ),
    );
  }
}
