import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/bouton_secondaire.dart';
import '../../composants/carte_application.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/couleurs_application.dart';
import '../../config/constantes_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_choix_role.dart';
import 'ecran_recuperation_compte.dart';
import 'ecran_verification_sms.dart';

/// Écran de connexion : par mot de passe ou par code SMS (cf. cahier 4.1).
class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurTelephone = TextEditingController();
  final _controleurMotDePasse = TextEditingController();

  @override
  void dispose() {
    _controleurTelephone.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  void _retourAccueil() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _connexionMotDePasse() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    final auth = context.read<FournisseurAuthentification>();
    final succes = await auth.connexionMotDePasse(
      _controleurTelephone.text.trim(),
      _controleurMotDePasse.text,
    );
    if (!mounted) return;
    if (succes) {
      _retourAccueil();
    } else {
      _afficher(auth.messageErreur ?? 'Connexion impossible.');
    }
  }

  Future<void> _connexionParSms() async {
    // Seul le numéro est requis pour la connexion par SMS.
    if (Validateurs.telephone(_controleurTelephone.text) != null) {
      _afficher('Saisissez d\'abord un numéro de téléphone valide.');
      return;
    }
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
          libelleAction: 'Se connecter',
          onCodeValide: () => auth.connexionParTelephone(telephone),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
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
                    EnteteAuthentification(
                      titre: 'Bon retour',
                      sousTitre: 'Connectez-vous à ${ConstantesApplication.nomApplication}.',
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
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Mot de passe',
                      icone: Icons.lock_outline,
                      estMotDePasse: true,
                      controleur: _controleurMotDePasse,
                      validateur: Validateurs.motDePasse,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EcranRecuperationCompte(),
                          ),
                        ),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementPetit),
                    BoutonPrincipal(
                      libelle: 'Se connecter',
                      icone: Icons.login,
                      enChargement: auth.enChargement,
                      onPressed: _connexionMotDePasse,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementPetit),
                    BoutonSecondaire(
                      libelle: 'Se connecter par code SMS',
                      icone: Icons.sms_outlined,
                      onPressed: auth.enChargement ? null : _connexionParSms,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    _lienInscription(),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    _bandeauComptesDemo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lienInscription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Pas encore de compte ?'),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EcranChoixRole()),
          ),
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }

  Widget _bandeauComptesDemo() {
    return CarteApplication(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: CouleursApplication.accent),
              SizedBox(width: DimensionsApplication.espacementPetit),
              Text(
                'Comptes de démonstration',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: DimensionsApplication.espacementPetit),
          const Text('Patient : 0700000002 / patient123'),
          const Text('Médecin : 0700000001 / medecin123'),
        ],
      ),
    );
  }
}
