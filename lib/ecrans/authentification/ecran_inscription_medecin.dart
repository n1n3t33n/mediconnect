import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_verification_sms.dart';

/// Inscription d'un médecin (cf. cahier 4.1) : nom, téléphone, spécialité,
/// numéro d'ordre, établissement. Le compte est créé « en attente » et devra
/// être validé par un administrateur avant activation.
class EcranInscriptionMedecin extends StatefulWidget {
  const EcranInscriptionMedecin({super.key});

  @override
  State<EcranInscriptionMedecin> createState() =>
      _EcranInscriptionMedecinState();
}

class _EcranInscriptionMedecinState extends State<EcranInscriptionMedecin> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurNom = TextEditingController();
  final _controleurTelephone = TextEditingController();
  final _controleurSpecialite = TextEditingController();
  final _controleurNumeroOrdre = TextEditingController();
  final _controleurEtablissement = TextEditingController();
  final _controleurMotDePasse = TextEditingController();

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurTelephone.dispose();
    _controleurSpecialite.dispose();
    _controleurNumeroOrdre.dispose();
    _controleurEtablissement.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
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
          libelleAction: 'Créer mon compte médecin',
          onCodeValide: () => auth.inscrireMedecin(
            nom: _controleurNom.text.trim(),
            telephone: telephone,
            motDePasse: _controleurMotDePasse.text,
            specialite: _controleurSpecialite.text.trim(),
            numeroOrdre: _controleurNumeroOrdre.text.trim(),
            etablissement: _controleurEtablissement.text.trim(),
          ),
          onSucces: _confirmerEnAttente,
        ),
      ),
    );
  }

  Future<void> _confirmerEnAttente(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.hourglass_top_outlined),
        title: const Text('Compte en attente'),
        content: const Text(
          'Votre compte médecin a bien été créé. Il doit être validé par un '
          'administrateur avant que vous puissiez vous connecter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _afficher(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription médecin')),
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
                      titre: 'Créer un compte médecin',
                      sousTitre:
                          'Votre inscription sera vérifiée par un administrateur.',
                      icone: Icons.medical_information_outlined,
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
                      libelle: 'Spécialité',
                      indication: 'Ex. Médecine générale',
                      icone: Icons.medical_services_outlined,
                      controleur: _controleurSpecialite,
                      validateur: Validateurs.champObligatoire,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Numéro d\'ordre des médecins',
                      icone: Icons.badge_outlined,
                      controleur: _controleurNumeroOrdre,
                      validateur: Validateurs.champObligatoire,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Établissement de rattachement',
                      icone: Icons.local_hospital_outlined,
                      controleur: _controleurEtablissement,
                      validateur: Validateurs.champObligatoire,
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
