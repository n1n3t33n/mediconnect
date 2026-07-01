import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../composants/bouton_principal.dart';
import '../../composants/champ_texte.dart';
import '../../composants/entete_authentification.dart';
import '../../config/dimensions_application.dart';
import '../../fournisseurs/fournisseur_authentification.dart';
import '../../utilitaires/validateurs.dart';

/// Définition d'un nouveau mot de passe après vérification du code SMS
/// (fin du parcours de récupération de compte).
class EcranNouveauMotDePasse extends StatefulWidget {
  const EcranNouveauMotDePasse({super.key, required this.telephone});

  final String telephone;

  @override
  State<EcranNouveauMotDePasse> createState() => _EcranNouveauMotDePasseState();
}

class _EcranNouveauMotDePasseState extends State<EcranNouveauMotDePasse> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurMotDePasse = TextEditingController();
  final _controleurConfirmation = TextEditingController();

  @override
  void dispose() {
    _controleurMotDePasse.dispose();
    _controleurConfirmation.dispose();
    super.dispose();
  }

  Future<void> _reinitialiser() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    final auth = context.read<FournisseurAuthentification>();
    final succes = await auth.definirNouveauMotDePasse(
      widget.telephone,
      _controleurMotDePasse.text,
    );
    if (!mounted) return;
    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé. Vous pouvez vous connecter.'),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.messageErreur ?? 'Échec de la réinitialisation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FournisseurAuthentification>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
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
                      titre: 'Nouveau mot de passe',
                      sousTitre: 'Choisissez un nouveau mot de passe sécurisé.',
                      icone: Icons.password_outlined,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementTresGrand),
                    ChampTexte(
                      libelle: 'Nouveau mot de passe',
                      icone: Icons.lock_outline,
                      estMotDePasse: true,
                      controleur: _controleurMotDePasse,
                      validateur: Validateurs.motDePasse,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementMoyen),
                    ChampTexte(
                      libelle: 'Confirmer le mot de passe',
                      icone: Icons.lock_outline,
                      estMotDePasse: true,
                      controleur: _controleurConfirmation,
                      validateur: (valeur) => valeur != _controleurMotDePasse.text
                          ? 'Les mots de passe ne correspondent pas.'
                          : null,
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: 'Réinitialiser',
                      icone: Icons.check,
                      enChargement: auth.enChargement,
                      onPressed: _reinitialiser,
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
