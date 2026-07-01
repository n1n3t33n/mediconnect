import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_nouveau_mot_de_passe.dart';
import 'ecran_verification_sms.dart';

/// Récupération de compte (cf. cahier 4.1) : saisie du numéro, renvoi d'un
/// code SMS, puis définition d'un nouveau mot de passe.
class EcranRecuperationCompte extends StatefulWidget {
  const EcranRecuperationCompte({super.key});

  @override
  State<EcranRecuperationCompte> createState() =>
      _EcranRecuperationCompteState();
}

class _EcranRecuperationCompteState extends State<EcranRecuperationCompte> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurTelephone = TextEditingController();

  @override
  void dispose() {
    _controleurTelephone.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    final auth = context.read<FournisseurAuthentification>();
    final telephone = _controleurTelephone.text.trim();

    if (!await auth.telephoneExiste(telephone)) {
      if (!mounted) return;
      _afficher('Aucun compte associé à ce numéro.');
      return;
    }

    final code = await auth.envoyerCodeSms(telephone);
    if (!mounted || code == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EcranVerificationSms(
          telephone: telephone,
          codeInitial: code,
          libelleAction: 'Vérifier le code',
          onCodeValide: () async => true,
          onSucces: (context) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EcranNouveauMotDePasse(telephone: telephone),
            ),
          ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Récupération de compte')),
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
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    const EnteteAuthentification(
                      titre: 'Mot de passe oublié',
                      sousTitre:
                          'Saisissez votre numéro pour recevoir un code de vérification.',
                      icone: Icons.lock_reset_outlined,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementTresGrand),
                    ChampTexte(
                      libelle: 'Numéro de téléphone',
                      indication: 'Ex. 07 00 00 00 00',
                      icone: Icons.phone_outlined,
                      typeClavier: TextInputType.phone,
                      controleur: _controleurTelephone,
                      formateurs: [FilteringTextInputFormatter.digitsOnly],
                      validateur: Validateurs.telephone,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: 'Envoyer le code',
                      icone: Icons.sms_outlined,
                      enChargement: auth.enChargement,
                      onPressed: _envoyerCode,
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
