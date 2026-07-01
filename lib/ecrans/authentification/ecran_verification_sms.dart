import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/carte_application.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';

/// Écran de vérification du code SMS (simulé), réutilisé par les flux
/// d'inscription, de connexion par SMS et de récupération de compte.
class EcranVerificationSms extends StatefulWidget {
  const EcranVerificationSms({
    super.key,
    required this.telephone,
    required this.codeInitial,
    required this.libelleAction,
    required this.onCodeValide,
    required this.onSucces,
  });

  final String telephone;
  final String codeInitial;
  final String libelleAction;

  /// Action exécutée une fois le code validé ; renvoie `true` si elle réussit.
  final Future<bool> Function() onCodeValide;

  /// Appelée après succès complet (navigation à la charge de l'appelant).
  final void Function(BuildContext context) onSucces;

  @override
  State<EcranVerificationSms> createState() => _EcranVerificationSmsState();
}

class _EcranVerificationSmsState extends State<EcranVerificationSms> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurCode = TextEditingController();
  late String _codeDemo = widget.codeInitial;

  @override
  void dispose() {
    _controleurCode.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    final auth = context.read<FournisseurAuthentification>();

    if (!auth.verifierCodeSms(widget.telephone, _controleurCode.text)) {
      _afficher('Code incorrect. Vérifiez et réessayez.');
      return;
    }

    final succes = await widget.onCodeValide();
    if (!mounted) return;
    if (succes) {
      widget.onSucces(context);
    } else {
      _afficher(auth.messageErreur ?? 'L\'opération a échoué.');
    }
  }

  Future<void> _renvoyer() async {
    final code =
        await context.read<FournisseurAuthentification>().envoyerCodeSms(
              widget.telephone,
            );
    if (!mounted || code == null) return;
    setState(() => _codeDemo = code);
    _afficher('Un nouveau code a été envoyé.');
  }

  void _afficher(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
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
                    EnteteAuthentification(
                      titre: 'Code de vérification',
                      sousTitre: 'Entrez le code envoyé au ${widget.telephone}.',
                      icone: Icons.sms_outlined,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    _bandeauDemonstration(),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Code à 6 chiffres',
                      icone: Icons.lock_outline,
                      typeClavier: TextInputType.number,
                      controleur: _controleurCode,
                      formateurs: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validateur: Validateurs.codeSms,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: widget.libelleAction,
                      enChargement: auth.enChargement,
                      onPressed: _valider,
                    ),
                    TextButton(
                      onPressed: auth.enChargement ? null : _renvoyer,
                      child: const Text('Renvoyer le code'),
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

  Widget _bandeauDemonstration() {
    return CarteApplication(
      enfant: Row(
        children: [
          const Icon(Icons.info_outline, color: CouleursApplication.accent),
          const SizedBox(width: DimensionsApplication.espacementPetit),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text:
                        'Démonstration : aucun SMS réel n\'est envoyé. Code : ',
                  ),
                  TextSpan(
                    text: _codeDemo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CouleursApplication.primaireFonce,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
