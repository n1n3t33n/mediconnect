import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_verification_sms.dart';

/// Inscription d'un patient (cf. cahier 4.1) : nom, téléphone, ville, date de
/// naissance, mot de passe. La création est confirmée par un code SMS.
class EcranInscriptionPatient extends StatefulWidget {
  const EcranInscriptionPatient({super.key});

  @override
  State<EcranInscriptionPatient> createState() =>
      _EcranInscriptionPatientState();
}

class _EcranInscriptionPatientState extends State<EcranInscriptionPatient> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurNom = TextEditingController();
  final _controleurTelephone = TextEditingController();
  final _controleurVille = TextEditingController();
  final _controleurMotDePasse = TextEditingController();
  DateTime? _dateNaissance;

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurTelephone.dispose();
    _controleurVille.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(maintenant.year - 20),
      firstDate: DateTime(1900),
      lastDate: maintenant,
      helpText: 'Date de naissance',
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  Future<void> _continuer() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    final auth = context.read<FournisseurAuthentification>();
    final telephone = _controleurTelephone.text.trim();

    if (await auth.telephoneExiste(telephone)) {
      if (!mounted) return;
      _afficher('Ce numéro de téléphone est déjà utilisé.');
      return;
    }

    final code = await auth.envoyerCodeSms(telephone);
    if (!mounted || code == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EcranVerificationSms(
          telephone: telephone,
          codeInitial: code,
          libelleAction: 'Créer mon compte',
          onCodeValide: () => auth.inscrirePatient(
            nom: _controleurNom.text.trim(),
            telephone: telephone,
            motDePasse: _controleurMotDePasse.text,
            ville: _controleurVille.text.trim(),
            dateNaissance: _dateNaissance,
          ),
          onSucces: (context) =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }

  void _afficher(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();
    final dateLisible = _dateNaissance == null
        ? 'Date de naissance (optionnel)'
        : DateFormat('dd/MM/yyyy').format(_dateNaissance!);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription patient')),
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
                    const EnteteAuthentification(
                      titre: 'Créer un compte patient',
                      sousTitre: 'Quelques informations pour commencer.',
                      icone: Icons.personal_injury_outlined,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    ChampTexte(
                      libelle: 'Nom complet',
                      icone: Icons.person_outline,
                      controleur: _controleurNom,
                      validateur: Validateurs.champObligatoire,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Numéro de téléphone',
                      indication: 'Ex. 07 00 00 00 00',
                      icone: Icons.phone_outlined,
                      typeClavier: TextInputType.phone,
                      controleur: _controleurTelephone,
                      formateurs: [FilteringTextInputFormatter.digitsOnly],
                      validateur: Validateurs.telephone,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Ville',
                      icone: Icons.location_city_outlined,
                      controleur: _controleurVille,
                      validateur: Validateurs.champObligatoire,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    InkWell(
                      onTap: _choisirDate,
                      borderRadius: BorderRadius.circular(
                        DimensionsApplication.rayonMoyen,
                      ),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        child: Text(dateLisible),
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Mot de passe',
                      icone: Icons.lock_outline,
                      estMotDePasse: true,
                      controleur: _controleurMotDePasse,
                      validateur: Validateurs.motDePasse,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: 'Continuer',
                      icone: Icons.arrow_forward,
                      enChargement: auth.enChargement,
                      onPressed: _continuer,
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
}
